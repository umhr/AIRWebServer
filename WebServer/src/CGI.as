package 
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	/**
	 * 参考
	 * http://milkyshade.com/air/302/
	 * ...
	 * @author umhr
	 */
	public class CGI extends EventDispatcher 
	{
		/**
		 * C#アプリケーションを呼び出すときに使う
		 */
		private var _fileName:String = 'html\\cgi\\sakasa.exe';// C#アプリケーション
		
		private var _file:File = File.applicationDirectory.resolvePath(_fileName);
		private var _nativeProcess:NativeProcess;
		public var text:String = "";
		
		public function CGI ()
		{
			//start();
		}
		
		public function start(text:String):void {
			trace(text);
			var arguments:Vector.<String>;
			var nativeProcessStartupInfo:NativeProcessStartupInfo;
			if (NativeProcess.isSupported && _file.exists) {
				
				// 引数（不要なら付けなくても良い）
				arguments = new Vector.<String>();
				arguments[0] = text;
				
				nativeProcessStartupInfo = new NativeProcessStartupInfo();
				nativeProcessStartupInfo.arguments = arguments;
				nativeProcessStartupInfo.executable = _file;
				
				_nativeProcess = new NativeProcess();
				_nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
				_nativeProcess.start(nativeProcessStartupInfo);
				
			}
			
		}
		
		/**
		 * 標準出力から読む
		 * @param	event
		 */
		private function onOutputData (event:ProgressEvent):void
		{
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData);
			text = _nativeProcess.standardOutput.readUTFBytes(_nativeProcess.standardOutput.bytesAvailable);
			trace(text);
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}