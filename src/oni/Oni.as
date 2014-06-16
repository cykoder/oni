package oni
{
	import flash.system.System;
	import oni.assets.AssetManager;
	import oni.components.ComponentManager;
	import oni.entities.Entity;
	import oni.screens.GameScreen;
	import oni.screens.Screen;
	import oni.screens.ScreenManager;
	import oni.sound.MBG;
	import oni.sound.MSFX;
	import oni.sound.MSound;
	import oni.utils.Backend;
	import oni.utils.Platform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
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
		 * Event fired for drawing debug data
		 */
		public static const DEBUG_DRAW:String = "debugdraw";
		
		/**
		 * Event fired when the current level has been completed
		 */
		public static const LEVEL_COMPLETED:String = "level_complete";
		
		/**
		 * Event fired when the current level has been failed
		 */
		public static const LEVEL_FAILED:String = "level_fail";
		
		/**
		 * Event fired when a level should be loaded
		 */
		public static const LEVEL_LOAD:String = "level_load";
		
		/**
		 * Event fired when there is a physics interaction
		 */
		public static const PHYSICS_INTERACTION:String = "physicsinteraction";
		
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
		 * Event fired when a component is added
		 */
		public static const COMPONENT_ADDED:String = "addcomp";
		
		/**
		 * Event fired when a component is removed
		 */
		public static const COMPONENT_REMOVED:String = "removecomp";
		
		/**
		 * Event fired when the game updates
		 */
		public static const UPDATE:String = "update";
		
		/**
		 * Event fired when something should initialise
		 */
		public static const INIT:String = "init";
		
		/**
		 * The screen manager
		 */
		public var screens:ScreenManager;
		
		/**
		 * The component manager
		 */
		public var components:ComponentManager;
		
		/**
		 * The main OniEngine class
		 */
		public function Oni()
		{
			//Create a component manager
			components = new ComponentManager(this);
			
			//Listen for added to stage event
			addEventListener(Event.ADDED_TO_STAGE, _init);
			
			//Debug
			Backend.log("Oni running on " + Platform.PLATFORM);
		}
		
		/**
		 * Called when the engine is added to the stage, ready to be initialised
		 * @param	e
		 */
		private function _init(e:Event):void
		{
			//Initialise the sound system
			MBG.init();
			MSFX.init();
			
			//Remove initialisation listener
			removeEventListener(Event.ADDED_TO_STAGE, _init);
			
			//Create a screen manager
			screens = new ScreenManager(this);
			components.add(screens);
			
			//Dispatch init event
			dispatchEventWith(Oni.INIT);
			
            //Do a quick clean up
            System.pauseForGCIfCollectionImminent(0);
            System.gc();
			
			//Listen for frame update
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		/**
		 * Called every frame
		 * @param	e
		 */
		private function _onEnterFrame(e:Event):void
		{
			//Dispatch update event
			dispatchEventWith(Oni.UPDATE, false);
			
			//Update current screen
			if (screens != null && screens.current != null)
			{
				screens.current.dispatchEventWith(Oni.UPDATE, false);
			}
		}
	}
}














