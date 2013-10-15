package oni.utils 
{
	import com.gamua.flox.Flox;
	import com.gamua.flox.Player;
	import starling.events.Event;
	
	/**
	 * A backend wrapper so we can use any game backend system, multiple or none at all
	 * @author Sam Hellawell
	 */
	public class Backend 
	{
		/**
		 * Initialises backend services
		 * @param	gameId
		 * @param	gameKey
		 */
		public static function init(services:Object):void
		{
			//Are we wanting to use any services?
			if (services != null)
			{
				//Check if we should use Flox
				/*if (services.flox != null)
				{
					//Init
					Flox.init(services.flox.gameId, services.flox.gameKey);
					
					//Save player for good measure
					Player.current.saveQueued();
				}*/
			}
		}
		
		/**
		 * Logs a message to the services
		 * @param	message
		 * @param	level
		 * @param	...rest
		 */
		public static function log(message:String, level:String="info", ...rest):void
		{
			switch(level)
			{
				case "e":
				case "err":
				case "error":
					if (floxEnabled)
					{
						Flox.logError("Error", message, rest);
					}
					else
					{
						trace("[Error] " + message, rest);
					}
					break;
					
				case "w":
				case "warn":
				case "warning":
					if (floxEnabled)
					{
						Flox.logWarning(message, rest);
					}
					else
					{
						trace("[Warning] " + message, rest);
					}
					break;
				
				default:
					if (floxEnabled)
					{
						Flox.logInfo(message, rest);
					}
					else
					{
						trace("[Info] " + message, rest);
					}
					break;
			}
			
		}
		
		/**
		 * Logs an event to the services
		 * @param	event
		 */
		public static function logEvent(event:Event):void
		{
			if(floxEnabled) Flox.logEvent(event.type, event.data);
		}
		
		/**
		 * Whether we are using the Flox service or not
		 */
		public static function get floxEnabled():Boolean
		{
			return Flox.gameID != null;
		}
		
	}

}