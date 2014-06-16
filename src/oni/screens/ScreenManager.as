package oni.screens 
{
	import oni.Oni;
	import oni.utils.Backend;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class ScreenManager extends EventDispatcher
	{
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
				//Add to array
				_screens.push(screen);
			
				//Dispatch event
				dispatchEventWith(Oni.SCREEN_ADDED, false, { screen: screen } );
				
				//Change to it?
				if (_screens.length == 1) switchTo(_screens.length-1);
			}
			
			//Return
			return screen;
		}
		
		/**
		 * Switches to a screen by index
		 * @param	index
		 */
		public function switchTo(index:int):void
		{
			//Base child index
			var childIndex:int = -1;
			var prevScreen:Screen = _currentScreen;
			
			//Check if we have a screen
			if (_currentScreen != null)
			{
				//Set child index
				if (_oni.contains(_currentScreen) && !_currentScreen.overlay)
				{
					childIndex = _oni.getChildIndex(_currentScreen);
				}
				
				//Remove all screens
				for (var i:uint = 0; i < _screens.length; i++)
				{
					//Check if screen is still in the diosplay list
					if (_screens[i].parent != null)
					{
						//Check if overlay or not
						if (!_screens[index].overlay)
						{
							//Remove screen
							_screens[i].remove(_screens[index]);
						}
						else if(i != index && _screens[i].overlay)
						{
							//Remove from parent
							//_screens[i].parent.removeChild(_screens[i]);
							_screens[i].remove();
							_screens[i].visible = false;
						}
					}
				}
			}
			
			//Set current screen
			_currentScreen = _screens[index];
			
			//Check if added
			if (!_oni.contains(_currentScreen))
			{
				//Add at right index
				if (childIndex == -1) childIndex = _oni.numChildren;
				_oni.addChildAt(_currentScreen, childIndex);
				
				//Check if should overlay
				if (_currentScreen.overlay && _oni.contains(prevScreen))
				{
					_oni.swapChildren(prevScreen, _currentScreen);
				}
			}
			else
			{
				_currentScreen.visible = true;
				_currentScreen.alpha = 1;
			}
			
			//Tell screen we've changed
			_currentScreen.dispatchEventWith(Oni.SCREEN_ADDED);
			
			//Dispatch event
			dispatchEventWith(Oni.SCREEN_CHANGED, false, { screen: _currentScreen } );
		}
		
		/**
		 * Switches to a screen by name
		 * @param	name
		 */
		public function switchToName(name:String):void
		{
			switchTo(getIndexByName(name));
		}
		
		/**
		 * Gets a screen by index
		 * @param	index
		 * @return
		 */
		public function get(index:int):Screen
		{
			return _screens[index];
		}
		
		/**
		 * Gets a screen by name
		 * @param	index
		 * @return
		 */
		public function getByName(name:String):Screen
		{
			return _screens[getIndexByName(name)];
		}
		
		/**
		 * Gets a screen index by name
		 * @param	name
		 * @return
		 */
		public function getIndexByName(name:String):int
		{
			//Find screen with name
			for (var i:uint = 0; i < _screens.length; i++)
			{
				if (_screens[i].name == name) return i;
			}
			
			//Log error
			Backend.log("ScreenManager: No screen with name (" + name +  ")", "error");
			return -1;
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
				switchTo(0);
			}
			else
			{
				_currentScreen = null;
			}
				
			//Remove
			screens[index].remove();
			
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
		
		public function get current():Screen
		{
			return _currentScreen;
		}
	}

}