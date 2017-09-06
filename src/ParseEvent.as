package
{
	import flash.events.Event;
	
	public class ParseEvent extends Event
	{
		
		public static var LINE_PARSED:String = "lineParsed";
		public static var PARSE_ERROR:String = "parseError";
		public static var PARSE_COMPLETE:String = "parseComplete";
		public static var NOTES:String = "notes";
		
		public var msg:String;
		
		public function ParseEvent(type:String, msg:String="", bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.msg = msg;
		}
	}
}