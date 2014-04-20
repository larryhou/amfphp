package com.larrio.amf.message
{
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	
	/**
	 * AMF消息包体
	 * @author larryhou
	 * @createTime Apr 20, 2014 12:47:17 PM
	 */
	public class AMFMessageBody implements IAMFMessage
	{
		/**
		 * AMF版本号 
		 * @see AMFMessageVersion 
		 */		
		public var version:uint;
		
		/**
		 * PHP命令字 
		 */		
		public var target:String;
		
		/**
		 * 请求标记
		 * @usage 可用来识别服务器回包
		 */		
		public var response:String;
		
		/**
		 * 包体数据
		 */		
		public var data:Object;
		
		/**
		 * 构造函数
		 * create a [AMFMessageBody] object
		 */
		public function AMFMessageBody()
		{
			
		}
		
		/**
		 * 解码AMF包体数据
		 * @param bytes	包体二进制数据
		 */		
		public function decode(bytes:ByteArray):void
		{
			var length:int = bytes.readUnsignedShort();
			this.target = bytes.readMultiByte(length, "UTF-8");
			
			length = bytes.readUnsignedShort();
			this.response = bytes.readMultiByte(length, "UTF-8");
			
			length = bytes.readInt();
			
			var amf:ByteArray = new ByteArray();
			bytes.readBytes(amf, 0, length);
			
			amf.objectEncoding = this.version == AMFMessageVersion.AMF3? ObjectEncoding.AMF3 : ObjectEncoding.AMF0;
			amf.position = 0;
			
			this.data = amf.readObject();
		}
		
		/**
		 * 编码AMF包体
		 */		
		public function encode():ByteArray
		{
			var result:ByteArray = new ByteArray();
			
			var bytes:ByteArray = new ByteArray();
			if (this.target)
			{
				bytes.writeMultiByte(this.target, "UTF-8");
			}
			
			result.writeShort(bytes.length);
			result.writeBytes(bytes);
			
			bytes = new ByteArray();
			if (this.response)
			{
				bytes.writeMultiByte(this.response, "UTF-8");
			}
			
			result.writeShort(bytes.length);
			result.writeBytes(bytes);
			
			bytes = new ByteArray();
			bytes.objectEncoding = this.version == AMFMessageVersion.AMF3? ObjectEncoding.AMF3 : ObjectEncoding.AMF0;
			if (this.data)
			{
				bytes.writeObject(this.data);
			}
			
			result.writeInt(bytes.length);
			result.writeBytes(bytes);
			
			return result;
		}
		
	}
}