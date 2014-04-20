package com.larrio.amf
{
	import com.larrio.amf.message.AMFMessage;
	import com.larrio.amf.message.AMFMessageBody;
	import com.larrio.amf.message.AMFMessageVersion;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * AMF连接请求
	 * @author larryhou
	 * @createTime Apr 20, 2014 5:33:18 PM
	 */
	public class AMFConnection extends EventDispatcher
	{
		private var _gateway:String;
		private var _sequence:uint;
		
		private var _map:Dictionary;
		
		/**
		 * 构造函数
		 * create a [AMFConnection] object
		 */
		public function AMFConnection(gateway:String)
		{
			_gateway = gateway;
			_map = new Dictionary(false);
		}
		
		/**
		 * 执行服务器请求
		 * @param command	服务器命令
		 * @param responder	前端回调函数
		 * @param params	服务器接受参数
		 */		
		public function call(command:String, responder:Function, params:Array, acceptMessage:Boolean = false):void
		{
			if (!responderValidate(responder) || !command) return;
			
			var task:AMFTaskInfo = new AMFTaskInfo();
			var request:AMFRequest = new AMFRequest(command, responder, params);
			request.acceptMessage = acceptMessage;
			request.sequence = ++_sequence;
			task.requests.push(request);
			flush(task);
		}
		
		/**
		 * 校验回调函数合法性
		 */		
		private function responderValidate(responder:Function):Boolean
		{
			if (responder == null)
			{
				throw new Error("回调函数不能为null");
				return false;
			}
			else
			if (responder.length == 0)
			{
				throw new Error("回调函数最少1个参数");
				return false;
			}
			else
			if (responder.length > 2)
			{
				throw new Error("回调函数最多接受2个参数");
				return false;
			}
			
			return true;
		}
		
		/**
		 * 批量执行服务命令
		 * @param params	参数列表 [{command: "TestService.method", responder:[Function object], params:[Array object]}]
		 */		
		public function batchCall(list:Vector.<AMFRequest>):void
		{
			var task:AMFTaskInfo = new AMFTaskInfo();
			
			var request:AMFRequest;
			for each(request in list)
			{
				if (!responderValidate(request.responder)) continue;
				if (!request.command) continue;
				
				request.sequence = ++_sequence;
				task.requests.push(request);
			}
			
			list.length && flush(task);
		}
		
		/**
		 * 向服务器发送请求
		 * @param data	AMF请求信息
		 */		
		private function flush(task:AMFTaskInfo):void
		{
			var request:URLRequest = new URLRequest(_gateway);
			request.contentType = "application/x-amf";
			request.method = URLRequestMethod.POST;
			
			var message:AMFMessage = new AMFMessage();
			message.version = AMFMessageVersion.AMF0;
			
			var body:AMFMessageBody;
			for each(var data:AMFRequest in task.requests)
			{
				body = new AMFMessageBody();
				body.response = data.sequence.toString();
				body.target = data.command;
				body.data = data.params;
				message.bodies.push(body);
			}
			
			request.data = message.encode();
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
						
			_map[loader] = task;
			listen(loader).load(request);
		}
		
		/**
		 * 添加时间侦听
		 */		
		private function listen(loader:URLLoader):URLLoader
		{
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
			return loader;
		}
		
		/**
		 * 取消事件侦听
		 */		
		private function unlisten(loader:URLLoader):URLLoader
		{
			loader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.removeEventListener(Event.COMPLETE, completeHandler);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, statusHandler);
			return loader;
		}
		
		/**
		 * 网络状态处理
		 */		
		private function statusHandler(event:HTTPStatusEvent):void
		{
			var loader:URLLoader = event.currentTarget as URLLoader;
			var request:AMFTaskInfo = _map[loader] as AMFTaskInfo;
			request.status = event.status;
		}
		
		/**
		 * 服务器成功返回数据处理
		 */		
		protected function completeHandler(event:Event):void
		{
			var loader:URLLoader = unlisten(event.currentTarget as URLLoader);
			var request:AMFTaskInfo = _map[loader] as AMFTaskInfo;
			
			var bytes:ByteArray = loader.data as ByteArray;
			var message:AMFMessage = new AMFMessage();
			message.decode(bytes);
			
			finishTask(request, message);
			delete _map[loader];
		}
		
		/**
		 * 发生错误处理
		 */		
		protected function errorHandler(event:ErrorEvent):void
		{
			var loader:URLLoader = unlisten(event.currentTarget as URLLoader);
			
			var task:AMFTaskInfo = _map[loader] as AMFTaskInfo;	
			finishTask(task, null);
			delete _map[loader];
		}
		
		/**
		 * 处理服务器回调
		 * @param request	AMF请求信息
		 * @param data		回调透传参数
		 */		
		private function finishTask(task:AMFTaskInfo, data:AMFMessage):void
		{
			var dict:Dictionary = new Dictionary(false);
			for each(var body:AMFMessageBody in data.bodies)
			{
				dict[body.target.match(/^\d+/)[0]] = body;
			}
			
			for each(var request:AMFRequest in task.requests)
			{
				finishResponder(request, request.acceptMessage? data : (dict[request.sequence] as AMFMessageBody).data);
			}
		}
		
		/**
		 * 处理回调函数
		 */		
		private function finishResponder(request:AMFRequest, data:*):void
		{
			switch(request.responder.length)
			{
				case 1:
				{
					request.responder.apply(null, [data]);
					break;
				}
					
				case 2:
				{
					request.responder.apply(null, [data, request]);
					break;
				}
			}
		}
			
	}
}
import com.larrio.amf.AMFRequest;

class AMFTaskInfo
{
	public var requests:Vector.<AMFRequest>;
	public var status:int;
	
	public function AMFTaskInfo()
	{
		this.requests = new Vector.<AMFRequest>();
	}
}