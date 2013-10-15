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
	
	public class Oni extends Sprite
	{
		public static const ENABLE_DEBUG:String = "enabledebug";
		
		public static const DISABLE_DEBUG:String = "disabledebug";
		
		public static const UPDATE_DATA:String = "updatedata";
		
		public static const UPDATE_POSITION:String = "updateposition";
		
		public static const SCREEN_ADDED:String = "screenadded";
		
		public static const SCREEN_CHANGED:String = "screenchanged";
		
		public static const SCREEN_REMOVED:String = "screenadded";
		
		public static const ENTITY_ADD:String = "addent";
		
		public static const ENTITY_REMOVE:String = "removeent";
		
		public static const UPDATE:String = "update";
		
		/**
		 * The screen manager - uhm, ye
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
			trace("[Oni] Running on " + Platform.PLATFORM);
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














