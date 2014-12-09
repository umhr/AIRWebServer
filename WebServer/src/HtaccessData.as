package  
{
	
	/**
	 * ...
	 * @author umhr
	 */
	public class HtaccessData 
	{
		public var AuthUserFile:String;
		public var AuthGroupFile:String;
		public var AuthName:String;
		public var AuthType:String;
		public var require:String;
		public var Satisfy:String;
		public function HtaccessData(value:String) 
		{
			var list:Array/*String*/ = value.split("\r\n");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				var type:String = list[i].split(" ")[0];
				if (type == "AuthUserFile") {
					AuthUserFile = list[i].substr(type.length + 1).replace(/"/g,"");
				}else if (type == "AuthName") {
					AuthName = list[i].substr(type.length + 1).replace(/"/g,"");
				}else if (type == "AuthGroupFile") {
					AuthGroupFile = list[i].substr(type.length + 1);
				}else if (type == "AuthType") {
					AuthType = list[i].substr(type.length + 1);
				}else if (type == "require") {
					require = list[i].substr(type.length + 1);
				}else if (type == "Satisfy") {
					Satisfy = list[i].substr(type.length + 1);
				}
				
			}
		}
		
		public function clone():HtaccessData {
			var result:HtaccessData = new HtaccessData(null);
			
			return result;
		}
		
		public function toString():String {
			var result:String = "HtaccessData:{";
			result += "AuthUserFile:" + AuthUserFile;
			result += ", AuthName:" + AuthName;
			result += ", AuthType:" + AuthType;
			result += ", require:" + require;
			result += ", Satisfy:" + Satisfy;
			result += "}";
			return result;
		}
		
	}
	
}