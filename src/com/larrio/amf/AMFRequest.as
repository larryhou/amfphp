package com.larrio.amf
{
	
	/**
	 * AMF请求信息
	 * @author larryhou
	 * @createTime Apr 20, 2014 7:32:35 PM
	 */
	public class AMFRequest
	{
		/**
		 * 服务器命令字 
		 */		
		public var command:String;
		
		/**
		 * 回调函数 
		 */		
		public var responder:Function;
		
		/**
		 * 服务器命令接受参数 
		 */		
		public var params:Array;
		
		/**
		 * 扩展字段：请求序列号
		 */		
		public var sequence:uint;
		
		/**
		 * 是否接受AMFMessage原始数据 
		 */		
		public var acceptMessage:Boolean;
		
		/**
		 * 构造函数
		 * create a [AMFRequesInfo] object
		 */
		public function AMFRequest(command:String, responder:Function, params:Array, acceptMessage:Boolean = false)
		{
			this.command = command; this.responder = responder; this.params = params; this.acceptMessage = acceptMessage;
		}
	}
}