package oni.utils 
{
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Platform 
	{
		public static var STAGE_WIDTH:int = 960;
		public static var STAGE_HEIGHT:int = 540;
		
		public static function isIOS():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "IOS");
		}

		public static function isAndroid():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "AND");
		}

		public static function isWindows():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "WIN");
		}

		public static function isMac():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "MAC");
		}

		public static function isMobile():Boolean
		{
			return isIOS() || isAndroid();
		}

		public static function isDesktop():Boolean
		{
			return Capabilities.playerType == "Desktop";
		}

		public static function get debugEnabled():Boolean
		{
			return Capabilities.isDebugger;
		}
		
		public static function get PLATFORM():String
		{
			if (isIOS()) return "iOS";
			if (isAndroid()) return "Android";
			if (isWindows()) return "Windows";
			if (isMac()) return "Mac";
			
			//I don't know
			return "IDK";
		}
		
	}

}