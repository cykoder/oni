package oni.utils 
{
	import com.gamua.flox.Flox;
	import com.gamua.flox.Player;
	import com.gamua.flox.TimeScope;
	import starling.events.Event;
	
	/**
	 * A backend wrapper so we can use any game backend system, multiple or none at all
	 * @author Sam Hellawell
	 */
	public class Backend 
	{
		public static var logToFlox:Boolean = false;
		
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
				if (services.flox != null)
				{
					//Init
					Flox.init(services.flox.gameId, services.flox.gameKey);
					
					//Save player for good measure
					Player.current.saveQueued();
				}
			}
		}
		
		public static function authenticatePlayer(key:String):void
		{
			trace("auth player " + key);
			//Player.loginWithKey(key, _onLoginComplete, _onLoginError);
		}
		
		private static function _onLoginComplete(player:Player):void
		{
			//Login sucessful, swag
			trace(player);
		}
		
		private static function _onLoginError(message:String):void
		{
			//Login error, log it
			Backend.log(message, "error");
		}
		
		public static function loadAllScores(onComplete:Function, onError:Function, scoreId:String="global", timeScope:String = "all"):void
		{
			//Is flox enabled?
			if (floxEnabled)
			{
				//Set timescope and load scores
				if (timeScope == "all") timeScope = TimeScope.ALL_TIME;
				Flox.loadScores(scoreId, timeScope, onComplete, onError);
			}
		}
		
		public static function loadScores(playerIds:Array, onComplete:Function, onError:Function, scoreId:String="global"):void
		{
			//Is flox enabled?
			if (floxEnabled)
			{
				Flox.loadScores(scoreId, playerIds, onComplete, onError);
			}
		}
		
		public static function loadPlayerScores(onComplete:Function, onError:Function, scoreId:String="global"):void
		{
			//Is flox enabled?
			if (floxEnabled)
			{
				Flox.loadScores(scoreId, [Player.current.id], onComplete, onError);
			}
		}
		
		public static function postScore(score:int, playerName:String, scoreId:String="global"):void
		{
			//Post to flox
			if (floxEnabled)
			{
				//Post score to flox
				Flox.postScore(scoreId, score, playerName);
			}
			
			//Backend log
			Backend.log("Submitted score: " + score + " as " + playerName + " to " + scoreId);
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
					if (floxEnabled && logToFlox)
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
					if (floxEnabled && logToFlox)
					{
						Flox.logWarning(message, rest);
					}
					else
					{
						trace("[Warning] " + message, rest);
					}
					break;
				
				default:
					if (floxEnabled && logToFlox)
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