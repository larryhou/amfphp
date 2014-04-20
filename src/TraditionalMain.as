package
{
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	/**
	 * 传统方式连接amfphp
	 * @author larryhou
	 * @createTime Apr 20, 2014 8:27:57 PM
	 */
	public class TraditionalMain extends Sprite
	{
		/**
		 * 构造函数
		 * create a [TraditionalMain] object
		 */
		public function TraditionalMain()
		{
			var amf:NetConnection = new NetConnection();
			amf.connect("http://localhost:8080/amfphp/gateway.php");
			amf.call("HelloWorld.say", new Responder(onResult,onStatus), "hello");
		}
		
		private function onStatus(info:Object):void
		{
			trace(JSON.stringify(info));
		}
		
		private function onResult(data:Object):void
		{
			trace(JSON.stringify(data));
			
		}
	}
}