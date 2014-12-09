package  
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.hash.IHash;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import flash.utils.ByteArray;
	
	/**
	 * .htpasswdのデータを保持し、問い合わせのあったid,pwの組み合わせを持っているかの確認をします。
	 * ...
	 * @author umhr
	 */
	public class HtpasswdData 
	{
		
		// "id:pw"
		private var _idpwList:Array/*String*/ = [];
		public function HtpasswdData(value:String) 
		{
			var list:Array/*String*/ = value.split("\r\n");
			var n:int = list.length;
			for (var i:int = 0; i < n; i++) 
			{
				_idpwList.push(list[i]);
			}
		}
		
		/**
		 * 該当のidとpwを持っているかの確認
		 * @param	id
		 * @param	pw
		 * @return
		 */
		public function hasIDPW(id:String, pw:String):Boolean {
			if (!id && !pw) {
				return false;
			}
			var result:Boolean = false;
			var idpw:String = id + ":{SHA}";
			idpw += sha1Base64FromPlaintext(pw);
			var n:int = _idpwList.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (idpw == _idpwList[i]) {
					result = true;
				}
			}
			return result;
		}
		
		/**
		 * 参考
		 * http://studynet.blog54.fc2.com/blog-entry-9.html
		 * http://crypto.hurlant.com/demo/
		 * @param	plaintext
		 * @return
		 */
		private function sha1Base64FromPlaintext(plaintext:String):String {
			var hexString:String = Hex.fromString(plaintext);
			var bainaryString:ByteArray = new ByteArray();
			bainaryString = Hex.toArray(hexString);
			var hashString1:IHash = Crypto.getHash("sha1");
			var hashString2:ByteArray = hashString1.hash( bainaryString );
			var resultString:String = Hex.fromArray( hashString2 );
			return Base64.encodeByteArray(hashString2);
		}
		
		public function clone():HtpasswdData {
			var result:HtpasswdData = new HtpasswdData(null);
			
			return result;
		}
		
		public function toString():String {
			var result:String = "HtpasswdData:{";
			
			result += "}";
			return result;
		}
		
	}
	
}