package  
{
	import com.hurlant.util.Base64;
	import flash.utils.ByteArray;
	import header.CookieData;
	import jp.mztm.umhr.logging.Log;
	
	/**
	 * ...
	 * @author umhr
	 */
	public class RequestData 
	{
		public var path:String;
		public var extention:String;
		public var cookieData:CookieData;
		public var host:String;
		public var basicID:String;
		public var basicPW:String;
		public function RequestData(value:ByteArray) 
		{
			if(value){
				parse(value.toString());
			}
		}
		
		private function parse(value:String):void 
		{
			Log.trace(value);
			Log.trace("//////////////////////////");
			
			var list:Array/*String*/ = value.split("\r\n");
			var request:String = list[0];
			var requestList:Array/*String*/ = list[0].split(" ");
			var method:String = requestList[0];
			setPath(requestList[1]);
			
			if(path){
				extention = path.substr(path.lastIndexOf("."));
			}
			
			var messageBody:String = value.substr(value.indexOf("\r\n\r\n"));
			
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (method.toLocaleLowerCase() == "post") {
					if (list[i].substr(0, "Content-Type".length) == "Content-Type") {
						if (list[i].indexOf("boundary=") > -1) {
							var boundary:String = list[i].substr(list[i].indexOf("boundary=") + "boundary=".length);
							setPosted(boundary, messageBody);
						}
					}
				}
				
				var index:int = list[i].indexOf(":");
				if (index > -1) {
					if (list[i].substr(0, index) == "Host") {
						host = list[i].substr(index + 2);
					}else if (list[i].substr(0, index) == "Cookie") {
						cookieData = new CookieData(list[i].substr(index + 2));
					}else if (list[i].substr(0, index) == "Authorization") {
						if (list[i].substr(index + 2, "Basic ".length) == "Basic ") {
							var basic:String = Base64.decode(list[i].substr(index + 2 + "Basic ".length));
							basicID = basic.split(":")[0];
							basicPW = basic.split(":")[1];
						}
					}
				}
			}
		}
		private function setPosted(boundary:String, messageBody:String):void {
			var dataList:Array = messageBody.split("--" + boundary);
			var n:int = dataList.length - 1;
			if (2 > n) {
				return;
			}
			var stdin:String = "";
			for (var i:int = 1; i < n; i++) 
			{
				stdin += parceForm(dataList[i]);
				if (i < n - 1) {
					stdin += "&";
				}
			}
			Log.trace(stdin);
		}
		public var postList:Object;
		public function toCGIString():String {
			var result:String = "";
			if (postList) {
				for (var p:String in postList) {
					result += p + "=" + postList[p] + "&";
				}
			}
			
			if (result.length > 0) {
				result = result.substr(0, result.length - 1);
			}
			
			return result;
		}
		
		
		private function parceForm(value:String):String {
			Log.trace("--------------");
			
			value = value.substr('Content-Disposition: form-data; name="'.length + 2);
			var name:String = value.substr(0, value.indexOf('"'));
			value = value.split("\r\n")[2];
			if (postList == null) {
				postList = { };
			}
			
			postList[name] = value;
			
			//trace("name:", name,name.length);
			//trace("value:", value, value.length);
			
			return name+"=" + encodeURI(value.replace(/ /g, "+"));
		}
		
		
		private function setPath(value:String):void 
		{
			
			if (value && value.length > 0 && value.substr(value.length - 1) == "/") {
				path = value+"index.html";
			}else {
				path = value;
			}
		}
		
		public function clone():RequestData {
			var result:RequestData = new RequestData(null);
			
			return result;
		}
		
		public function toString():String {
			var result:String = "RequestData:{";
			result += "path:" + path;
			result += ", extention:" + extention;
			result += "}";
			return result;
		}
		
	}
	
}