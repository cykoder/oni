package oni.components.input 
{
	import oni.Oni;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Input
	{
		public static const CLEAR:String = "clear";
		
		public static const SINGLE_TAP:String = "singletap";
		
		public static const DOUBLE_TAP:String = "doubletap";
		
		public static const RIGHT:String = "right";
		
		public static const LEFT:String = "left";
		
		public static const UP:String = "up";
		
		public static const JUMP:String = UP;
		
		public static const MINUS:String = "minus";
		
		public static const PLUS:String = "plus";
		
		public static const MAP:Object = { "39": Input.RIGHT,
										   "37": Input.LEFT,
										   "38": Input.UP,
										   "32": Input.JUMP,
										   "189": Input.MINUS,
										   "187": Input.PLUS };
		
	}

}