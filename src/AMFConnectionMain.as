package
{
	import com.larrio.amf.AMFConnection;
	import com.larrio.amf.AMFRequest;
	import com.larrio.amf.message.AMFMessage;
	
	import flash.display.Sprite;
	
	/**
	 * 测试demo
	 * @author larryhou
	 * @createTime Apr 20, 2014 7:20:50 PM
	 */
	public class AMFConnectionMain extends Sprite
	{
		/**
		 * 构造函数
		 * create a [AMFConnectionMain] object
		 */
		public function AMFConnectionMain()
		{
			var amf:AMFConnection = new AMFConnection();
			amf.connect("http://localhost:8080/amfphp/gateway.php");
			amf.call("HelloWorld.say", responder, ["hello"], true);
			
			var list:Vector.<AMFRequest> = new Vector.<AMFRequest>();
			while (list.length < 10)
			{
				list.push(new AMFRequest("HelloWorld.say", responder, ["hello." + Math.random().toFixed(6).substr(2)]));
			}
			
			amf.batchCall(list);
		}
		
		private function responder(data:Object, request:AMFRequest):void
		{
			if (data is AMFMessage)
			{
				trace(data);
			}
			else
			{
				trace(JSON.stringify(data));
			}
			
		}
	}
}