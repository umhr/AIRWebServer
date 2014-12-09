package
{
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import header.CookieData;
	import jp.mztm.umhr.logging.Log;
	/**
	 * 参考
	 * http://help.adobe.com/ja_JP/FlashPlatform/reference/actionscript/3/flash/net/ServerSocket.html#includeExamplesSummary
	 * ...
	 * @author umhr
	 */
    public class Canvas extends Sprite
    {
        private var serverSocket:ServerSocket = new ServerSocket();
		private var _ipPort:TextArea;
		private var _cgi:CGI = new CGI();
        public function Canvas()
        {
            setupUI();
        }

        private function setupUI():void
        {
			_ipPort = new TextArea(this, 10, 10, "127.0.0.1:80");
			_ipPort.height = 22;
			_ipPort.autoHideScrollBar = true;
			new PushButton(this, 310, 10, "Bind", onBind);
			addChild(new Log(10, 40, 780, 560));
        }
        
        private function onBind( event:Event ):void
        {
            if ( serverSocket.bound ) { return };
			
			var ip:String = _ipPort.text.split(":")[0];
			var port:int = parseInt(_ipPort.text.split(":")[1]);
            serverSocket.bind( port, ip );
            serverSocket.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
            serverSocket.listen();
            Log.trace( "Bound to: " + serverSocket.localAddress + ":" + serverSocket.localPort);
        }
		
        private function onConnect( event:ServerSocketConnectEvent ):void
        {
            var socket:Socket = event.socket;
            socket.addEventListener( ProgressEvent.SOCKET_DATA, onClientSocketData2 );
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
            Log.trace( "Connection from " + socket.remoteAddress + ":" + socket.remotePort);
        }
		
		private function onError(e:Event):void 
		{
			trace(e.type);
		}
        
        private function onClientSocketData2( event:ProgressEvent ):void
        {
			try
                {
                    var bytes:ByteArray = new ByteArray();
					var socket:Socket = event.target as Socket;
                    socket.readBytes(bytes);
                    
					var requestData:RequestData = new RequestData(bytes);
                    var filePath:String = File.applicationDirectory.nativePath + "/html";
					filePath += requestData.path;
					
                    var file:File = File.applicationStorageDirectory.resolvePath(filePath);
					
					var htpasswdData:HtpasswdData = htaccessCheck(filePath);
					
					if (htpasswdData && !htpasswdData.hasIDPW(requestData.basicID, requestData.basicPW)) {
						// Basic認証通らないばあい。
						socket.writeBytes(new ResponceData(401).toByteArray());
					}else if (file.isDirectory) {
						// ディレクトリだった場合、/をつけて移動させる。
						var location:String = "http://" + requestData.host + requestData.path + "/";
						socket.writeBytes(new ResponceData(301).setLocation(location).toByteArray());
					}
					else if (file.exists && !file.isDirectory)
                    {
						if (file.extension == "exe") {
							// cgiの場合
							_cgi.addEventListener(Event.COMPLETE, cgi_complete);
							_cgi.start(requestData.toCGIString());
							function cgi_complete(e:Event):void 
							{
								_cgi.removeEventListener(Event.COMPLETE, cgi_complete);
								var content:ByteArray = new ByteArray();
								content.length = 0;
								content.writeMultiByte(_cgi.text, "utf-8");
								content.position = 0;
								socket.writeBytes(new ResponceData(200).setByteArray(content).toByteArray(".html"));
								socket.flush();
								socket.close();
							}
							return;
						}else{
							var stream:FileStream = new FileStream();
							stream.open( file, FileMode.READ );
							var content:ByteArray = new ByteArray();
							stream.readBytes(content);
							stream.close();
							var cookieData:CookieData = cookieMaker(requestData.cookieData, requestData.path);
							if (cookieData) {
								var text:String = content.readMultiByte(content.length, "utf-8");
								text = text.replace(/\$Cookie\.countrymaam\$/g, cookieData.object.countrymaam);
								content.length = 0;
								content.writeMultiByte(text, "utf-8");
								content.position = 0;
							}
						}
						socket.writeBytes(new ResponceData(200).setByteArray(content).setCookie(cookieData).toByteArray(requestData.extention));
                    }
                    else
                    {
						socket.writeBytes(new ResponceData(404).toByteArray());
                    }
                    socket.flush();
                    socket.close();
                }
                catch (error:Error)
                {
                    //Alert.show(error.message, "Error");
                }
				
		}
		
		private function cookieMaker(cookieData:CookieData, path:String):CookieData {
			if (!cookieData) {
				if (path.substr(0, "/cookie".length) == "/cookie") {
					cookieData = new CookieData();
				}else{
					return null;
				}
			}
			cookieData.path = "/cookie";
			if (cookieData.object && cookieData.object.countrymaam) {
				cookieData.object.countrymaam = parseInt(cookieData.object.countrymaam) + 1;
			}else {
				cookieData.object = { countrymaam:1 };
			}
			// 有効期限10分後
			cookieData.expires = new Date();
			cookieData.expires.setTime(cookieData.expires.getTime() + 1000 * 60 * 10);
			return cookieData;
		}
		
		private function htaccessCheck(filePath:String):HtpasswdData 
		{
			// .htaccessを確認します。
			var filePath:String = filePath.substr(0, filePath.lastIndexOf("/")) + "/.htaccess";
			var content:ByteArray = getFile(filePath);
			if (!content) {
				return null;
			}
			var htaccessData:HtaccessData = new HtaccessData(content.readMultiByte(content.length, "utf-8"));
			// .htpasswdを確認します。
			filePath = File.applicationDirectory.nativePath + "/html/" + htaccessData.AuthUserFile;
			content = getFile(filePath);
			if (!content) {
				return null;
			}
			
			//trace(content.toString());
			return new HtpasswdData(content.readMultiByte(content.length, "utf-8"));
			
		}
		private function getFile(filePath:String):ByteArray {
			var file:File = File.applicationStorageDirectory.resolvePath(filePath);
			if (!file.exists || file.isDirectory) {
				return null;
			}
			var stream:FileStream = new FileStream();
			stream.open( file, FileMode.READ );
			var content:ByteArray = new ByteArray();
			stream.readBytes(content);
			stream.close();
			return content;
		}
    }
}