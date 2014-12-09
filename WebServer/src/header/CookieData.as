package header {
	import mx.formatters.DateFormatter;
	
	/**
	 * 参考
	 * http://www.futomi.com/lecture/cookie/
	 * ...
	 * @author umhr
	 */
	public class CookieData 
	{
		public var object:Object = { };
		public var expires:Date;
		public var domain:String;
		public var path:String;
		public var secure:String;
		public function CookieData(value:String = null) 
		{
			if(value){
				perse(value);
			}
		}
		private function perse(value:String):void {
			var list:Array/*String*/ = value.split("; ");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				var params:Array = list[i].split("=");
				object[params[0]] = params[1];
			}
		}
		public function toHeader():String {
			var result:String = "Set-Cookie: ";
			for (var p:String in object) {
				result += p + "=" + object[p] + ";";
			}
			if (expires) {
				var dateFormatter:DateFormatter = new DateFormatter();
				dateFormatter.formatString = "EEE, DD MMM YYYY JJ:NN:SS";
				result += "expires=" + dateFormatter.format(expires.toUTCString()) + "; ";
			}
			if (domain) {
				result += "domain=" + domain + "; ";
			}
			if (path) {
				result += "path=" + path + "; ";
			}
			if (secure) {
				result += "secure=" + secure + "; ";
			}
			result = result.substr(0, result.length - 1);
			return result;
		}
		
		
		public function clone():CookieData {
			var result:CookieData = new CookieData();
			return result;
		}
		
		public function toString():String {
			var result:String = "CookieData:{";
			
			result += "}";
			return result;
		}
		
	}
	
}