package oni.screens 
{
	import oni.Oni;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class ScreenManager extends EventDispatcher
	{
		/**
		 * The index for the game screen
		 */
		public static var SCREEN_GAME:int;
		
		/**
		 * The current engine instance
		 */
		private var _oni:Oni;
		
		/**
		 * Array of current game screens
		 */
		private var _screens:Array = new Array();
		
		/**
		 * The current displayed screen
		 */
		private var _currentScreen:Screen;
		
		/**
		 * Creates a screen manager
		 * @param	oni
		 */
		public function ScreenManager(oni:Oni) 
		{
			//Set engine instance
			_oni = oni;
			
			//Listen for update
			addEventListener(Oni.UPDATE, _updateScreen);
		}
		
		/**
		 * Adds a screen to the list
		 * @param	screen
		 */
		public function add(screen:Screen):Screen
		{
			//Check its not in array
			if (_screens.indexOf(screen) < 0)
			{
				//Set index
				switch(screen.name)
				{
					case "game":
						SCREEN_GAME = _screens.length;
						break;
				}
				
				//Add to array
				_screens.push(screen);
			
				//Dispatch event
				dispatchEventWith(Oni.SCREEN_ADDED, false, { screen: screen } );
				
				//Change to it?
				if (_screens.length == 1) changeTo(_screens.length-1);
			}
			
			//Return
			return screen;
		}
		
		/**
		 * Switches between two screens
		 * @param	index
		 */
		public function changeTo(index:int):void
		{
			//Base child index
			var childIndex:int = 0;
			
			//Check if we have a screen
			if (_currentScreen != null)
			{
				//Set child index
				childIndex = _oni.getChildIndex(_currentScreen);
				
				//Remove
				_oni.removeChild(_currentScreen);
			}
			
			//Set current screen
			_currentScreen = _screens[index];
			
			//Dispatch event
			dispatchEventWith(Oni.SCREEN_CHANGED, false, { screen: _currentScreen } );
			
			//Add
			_oni.addChildAt(_screens[index], childIndex);
		}
		
		/**
		 * Gets a screen by index
		 * @param	index
		 * @return
		 */
		public function getScreen(index:int):Screen
		{
			return _screens[index];
		}
		
		/**
		 * Removes a screen by index
		 * @param	index
		 * @return
		 */
		public function remove(index:int):Screen
		{
			//Create new array
			var screens:Array = _screens.concat();
			
			//Add screens
			_screens = new Array();
			for (var i:int = 0; i < screens.length; i++)
			{
				if(i != index) add(screens[i]);
			}
			
			//Check if current screen
			if (_currentScreen == screens[index] && _screens.length > 0)
			{
				changeTo(0);
			}
			else
			{
				_currentScreen = null;
			}
			
			//Dispatch event
			dispatchEventWith(Oni.SCREEN_REMOVED, false, { screen: screens[index] } );
			
			//Return the screen
			return screens[index];
		}
		
		/**
		 * The amount of screens in use
		 */
		public function get screenCount():int
		{
			return _screens.length;
		}
		
		/**
		 * Updates the current screen
		 * @param	e
		 */
		private function _updateScreen(e:Event):void
		{
			//Check current screen
			if (_currentScreen != null)
			{
				//Update screen
				_currentScreen.dispatchEvent(e);
			}
		}
		
	}

}