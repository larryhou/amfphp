package com.larrio.amf.message
{
	import flash.utils.ByteArray;
	
	/**
	 * AMF消息接口
	 * @author larryhou
	 * @createTime Apr 20, 2014 1:59:20 PM
	 */
	public interface IAMFMessage
	{
		/**
		 * 编码成二进制
		 */		
		function encode():ByteArray;
		
		/**
		 * 解码二进制信息
		 * @param bytes	二进制数据
		 */		
		function decode(bytes:ByteArray):void;
	}
}