package com.larrio.amf.message
{
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	
	/**
	 * AMF消息包头
	 * @author larryhou
	 * @createTime Apr 20, 2014 12:47:03 PM
	 */
	public class AMFMessageHeader implements IAMFMessage
	{
		/**
		 * 包头名 
		 */		
		public var name:String;
		
		/**
		 * 标记位 
		 */		
		public var mustUnderstand:Boolean;
		
		/**
		 * AMF版本号 
		 * @see AMFMessageVersion 
		 */		
		public var version:uint;
		
		/**
		 * 包头携带数据 
		 */		
		public var data:Object;
				
		/**
		 * 构造函数
		 * create a [AMFHeader] object
		 */
		public function AMFMessageHeader()
		{
			
		}
		
		/**
		 * 解码包头数据
		 * @param bytes	包头二进制
		 */		
		public function decode(bytes:ByteArray):void
		{
			var length:uint = bytes.readUnsignedShort();
			this.name = bytes.readMultiByte(length, "UTF-8");
			this.mustUnderstand = Boolean(bytes.readUnsignedByte());
			
			length = bytes.readInt();
			
			var amf:ByteArray = new ByteArray();
			bytes.readBytes(amf, 0, length);
			
			amf.objectEncoding = this.version == AMFMessageVersion.AMF3? ObjectEncoding.AMF3 : ObjectEncoding.AMF0;
			amf.position = 0;
			
			this.data = amf.readObject();
		}
		
		/**
		 * 编码包头数据
		 */		
		public function encode():ByteArray
		{
			var result:ByteArray = new ByteArray();
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte(this.name, "UTF-8");
			
			result.writeShort(bytes.length);
			result.writeBytes(bytes);
			
			result.writeByte(int(this.mustUnderstand));
			
			bytes = new ByteArray();
			bytes.objectEncoding = this.version == AMFMessageVersion.AMF3? ObjectEncoding.AMF3 : ObjectEncoding.AMF0;
			bytes.writeObject(this.data);
			
			result.writeInt(bytes.length);
			result.writeBytes(bytes);
			
			return result;
		}
	}
}