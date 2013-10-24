package oni
{
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import oni.screens.GameScreen;
	import oni.screens.Screen;
	import oni.screens.ScreenManager;
	import oni.utils.Backend;
	import oni.utils.Platform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * Main game engine class
	 * @author Sam Hellawell
	 */
	public class Oni extends Sprite
	{
		/**
		 * Event fired when debug mode is enabled
		 */
		public static const ENABLE_DEBUG:String = "enabledebug";
		
		/**
		 * Event fired when debug mode is diabled
		 */
		public static const DISABLE_DEBUG:String = "disabledebug";
		
		/**
		 * Event fired when data should be updated
		 */
		public static const UPDATE_DATA:String = "updatedata";
		
		/**
		 * Event fired when something updates position
		 */
		public static const UPDATE_POSITION:String = "updateposition";
		
		/**
		 * Event fired when a screen is added
		 */
		public static const SCREEN_ADDED:String = "screenadded";
		
		/**
		 * Event fired when a screen is changed
		 */
		public static const SCREEN_CHANGED:String = "screenchanged";
		
		/**
		 * Event fired when a screen is removed
		 */
		public static const SCREEN_REMOVED:String = "screenadded";
		
		/**
		 * Event fired when an entity is added
		 */
		public static const ENTITY_ADDED:String = "addent";
		
		/**
		 * Event fired when an entity is removed
		 */
		public static const ENTITY_REMOVED:String = "removeent";
		
		/**
		 * Event fired when the game updates
		 */
		public static const UPDATE:String = "update";
		
		/**
		 * The screen manager
		 */
		public var screenManager:ScreenManager;
		
		/**
		 * The main OniEngine class
		 */
		public function Oni()
		{
			//Listen for added to stage event
			addEventListener(Event.ADDED_TO_STAGE, _init);
			
			//Debug
			Backend.log("[Oni] Running on " + Platform.PLATFORM);
		}
		
		/**
		 * Called when the engine is added to the stage, ready to be initialised
		 * @param	e
		 */
		private function _init(e:Event):void
		{
			//Remove initialisation listener
			removeEventListener(Event.ADDED_TO_STAGE, _init);
			
			//Create a screen manager
			screenManager = new ScreenManager(this);
			
			//Add screens
			screenManager.addScreen(new GameScreen());
			
			//screenManager.changeTo(ScreenManager.SCREEN_GAME);
			
			//Listen for update
			addEventListener(EnterFrameEvent.ENTER_FRAME, _enterFrame);
		}
		
		/**
		 * Called every frame, handles updating
		 * @param	e
		 */
		private function _enterFrame(e:EnterFrameEvent):void
		{
			//Dispatch update event
			dispatchEventWith(Oni.UPDATE, false, { } );
		}
	}
}














