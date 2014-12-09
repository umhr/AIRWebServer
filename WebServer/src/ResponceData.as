package  
{
	import flash.utils.ByteArray;
	import header.CookieData;
	import mx.formatters.DateFormatter;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class ResponceData 
	{
		private var _body:String;
		private var _location:String;
		private var _status:int;
		private var _byteArray:ByteArray = new ByteArray();
		private var _cookie:CookieData;
		public function ResponceData(status:int = 200) 
		{
			_status = status;
		}
		
		public function setLocation(location:String):ResponceData {
			_location = location;
			trace(_location);
			return this;
		}
		
		
		public function setBody(body:String):ResponceData {
			_body = body;
			return this;
		}
		public function setByteArray(byteArray:ByteArray):ResponceData {
			_byteArray = byteArray;
			return this;
		}
		public function setCookie(cookie:CookieData):ResponceData {
			_cookie = cookie;
			return this;
		}
		
		public function toByteArray(extention:String = ".html"):ByteArray {
			var text:String = "HTTP/1.1 200 OK\r\n";
			if (_status == 301) {
				text = "HTTP/1.0 301 Moved Permanently\r\n";
			}else if (_status == 401) {
				text = "HTTP/1.1 401 Authorization Required\r\n";
				_byteArray.writeMultiByte("<html><body><h2>401 Authorization Required</h2></body></html>", "utf-8");
			}else if (_status == 404) {
				text = "HTTP/1.0 404 Not Found\r\n";
				_byteArray.writeMultiByte("<html><body><h2>404 Not Found</h2></body></html>", "utf-8");
			}
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "EEE, DD MMM YYYY JJ:NN:SS";
			var dateStr:String = dateFormatter.format(new Date().toUTCString());
			
			text += "Date: " + dateStr + " GMT\r\n";
			text += "Server: Mztm\r\n";
			text += "Accept-Ranges: bytes\r\n";
			text += "Content-Length: " + _byteArray.length + "\r\n";
			if(_cookie){
				text += _cookie.toHeader();
			}
			text += "Content-Type: " + contentTypeFromExtention(extention) + "\r\n";
			text += "Cache-Control: no-cache\r\n";
			if (_status == 301) {
				text += "Location: " + _location + "\r\n";
			}else if (_status == 401) {
				text += 'WWW-Authenticate: Basic realm="SECRET AREA"\r\n';
			}
			text += "\r\n";
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeMultiByte(text, "utf-8");
			byteArray.writeBytes(_byteArray);
			
			return byteArray;
		}
		
		private function contentTypeFromExtention(extention:String):String {
			var result:String;
			var list:Array/*Array*/ = [
				["text/plain", ".txt", ".xml"],
				["text/html", ".html", ".htm", ".cgi"],
				["text/css", ".css"],
				["text/javascript", ".js"],
				["image/jpeg", ".jpg", ".jpeg"],
				["image/png", ".png"],
				["image/gif", ".gif"],
				["image/x-icon", ".ico"]
				];
			var ex:String;
			var n:int = list.length;
			var m:int;
			loop:for (var i:int = 0; i < n; i++) 
			{
				m = list[i].length;
				for (var j:int = 1; j < m; j++) 
				{
					if (list[i][j] == extention) {
						result = list[i][0];
						break loop;
					}
				}
			}
			return result;
		}
		
		
		public function clone():ResponceData {
			var result:ResponceData = new ResponceData(_status);
			
			return result;
		}
		public function toString():String {
			var result:String = "ResponceData:{";
			
			result += "}";
			return result;
		}
		
	}
	
}