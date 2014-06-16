package oni.utils 
{
	import flash.system.Capabilities;
	/**
	 * Utility class for the platform the engine is running on
	 * @author Sam Hellawell
	 */
	public class Platform 
	{
		/**
		 * The intended width of the stage
		 */
		public static var STAGE_WIDTH:int = 960;
		
		/**
		 * The intended height of the stage
		 */
		public static var STAGE_HEIGHT:int = 540;
		
		/**
		 * Checks if the engine is running on iOS
		 * @return
		 */
		public static function isIOS():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "IOS");
		}

		/**
		 * Checks if the engine is running on Android
		 * @return
		 */
		public static function isAndroid():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "AND");
		}

		/**
		 * Checks if the engine is running on Windows
		 * @return
		 */
		public static function isWindows():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "WIN");
		}

		/**
		 * Checks if the engine is running on Mac OSX
		 * @return
		 */
		public static function isMac():Boolean
		{
			return (Capabilities.version.substr(0, 3) == "MAC");
		}

		/**
		 * Checks if the engine is running on a mobile platform
		 * @return
		 */
		public static function isMobile():Boolean
		{
			return isIOS() || isAndroid();
		}

		/**
		 * Checks if the engine is running on a desktop/laptop
		 * @return
		 */
		public static function isDesktop():Boolean
		{
			return !isMobile() &&
				   Capabilities.playerType == "Desktop" ||
				   Capabilities.playerType == "StandAlone" ||
				   Capabilities.playerType == "External";
		}

		/**
		 * Checks if the engine is running on a web plugin
		 * @return
		 */
		public static function isWeb():Boolean
		{
			return Capabilities.playerType == "PlugIn";
		}
		
		/**
		 * Checks if the platform can support advanced features such as fragment shaders
		 * @return
		 */
		public static function supportsAdvancedFeatures():Boolean
		{
			return !isWeb() && !isMobile();
		}
		
		/**
		 * Checks if the platform the engine is running is capable of debug mode
		 * @return
		 */
		public static function get debugEnabled():Boolean
		{
			return Capabilities.isDebugger;
		}
		
		/**
		 * Returns the name of the platform the engine is running on
		 * @return
		 */
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