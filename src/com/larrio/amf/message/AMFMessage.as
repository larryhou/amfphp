package com.larrio.amf.message
{
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * AMF数据包
	 * @author larryhou
	 * @createTime Apr 20, 2014 12:46:47 PM
	 */
	public class AMFMessage implements IAMFMessage
	{
		/**
		 * AMF版本号 
		 * @see AMFMessageVersion 
		 */		
		public var version:uint;
		
		/**
		 * 包头列表 
		 */		
		public var headers:Vector.<AMFMessageHeader>;
		
		/**
		 * 包体列表 
		 */		
		public var bodies:Vector.<AMFMessageBody>;
				
		/**
		 * 构造函数
		 * create a [AMFMessage] object
		 */
		public function AMFMessage()
		{
			this.bodies = new Vector.<AMFMessageBody>();
			this.headers = new Vector.<AMFMessageHeader>();
		}
		
		/**
		 * 解码AMF数据包
		 * @param bytes	二进制数据
		 */		
		public function decode(bytes:ByteArray):void
		{
			bytes.position = 0;
			this.version = bytes.readUnsignedShort();
			
			var count:uint, i:uint;
			
			var header:AMFMessageHeader;
			headers = new Vector.<AMFMessageHeader>();
			
			count = bytes.readUnsignedShort();
			for (i = 0; i < count; i++)
			{
				header = new AMFMessageHeader();
				header.version = this.version;
				header.decode(bytes);
				headers.push(header);
			}
			
			var body:AMFMessageBody;
			bodies = new Vector.<AMFMessageBody>();
			
			count = bytes.readUnsignedShort();
			for (i = 0; i < count; i++)
			{
				body = new AMFMessageBody();
				body.version = this.version;
				body.decode(bytes);
				bodies.push(body);
			}
		}
		
		/**
		 * 编码AMF数据包
		 */		
		public function encode():ByteArray
		{
			var result:ByteArray = new ByteArray();
			result.writeShort(this.version);
			
			var count:uint, i:uint;
			
			count = headers? headers.length : 0;
			result.writeShort(count);
			
			for (i = 0; i < count; i++)
			{
				headers[i].version = this.version;
				result.writeBytes(headers[i].encode());
			}
			
			count = bodies? bodies.length : 0;
			result.writeShort(count);
			
			for (i = 0; i < count; i++)
			{
				bodies[i].version = this.version;
				result.writeBytes(bodies[i].encode());
			}
			
			return result;
		}
		
		/**
		 * 格式化输出
		 */		
		public function toString():String
		{
			var result:String = getQualifiedClassName(this);
			result += printObject(this, "    ");
			return result;
		}
		
		/**
		 * 打印对象
		 */		
		private function printObject(obj:Object, indent:String = ""):String
		{
			var result:String = "";
			var desc:XML = describeType(obj);
			
			var type:String = desc.@name;
			if  (type.match(/^(array|object)$/i) || !type.indexOf("__AS3__.vec::"))
			{
				result += "\n";
				for (var key:* in obj)
				{
					result += indent + key + "[" + getQualifiedClassName(obj[key]) + "] -> " + printObject(obj[key], indent + "    ");
				}
			}
			else
			if (type.match(/AMFMessage/i))
			{
				result += "\n";
				var list:XMLList = desc..variable;
				for each(var item:XML in list)
				{
					key = String(item.@name);
					result += indent + key + "[" + item.@type + "] -> " + printObject(obj[key], indent + "    ");
				}
			}
			else
			{
				return String(obj) + "\n";
			}
			
			return result;
		}
	}
}