package oni.screens 
{
	import oni.components.ComponentManager;
	import oni.Oni;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Screen extends DisplayObjectContainer
	{
		/**
		 * The current Oni instance
		 */
		protected var _oni:Oni;
		
		/**
		 * Whether the screen is an overlay or not
		 */
		protected var _overlay:Boolean;
		
		/**
		 * A base class for all types of screens
		 * @param	name
		 */
		public function Screen(oni:Oni, name:String, overlay:Boolean=false) 
		{
			//Set the name
			this.name = name;
			
			//Set overlay
			this._overlay = overlay;
			
			//Set oni instance
			_oni = oni;
		}
		
		public function remove(nextScreen:Screen=null):void
		{
			//Remove from parent
			if (_oni.contains(this))
			{
				_oni.removeChild(this);
			}
		}
		
		public function get components():ComponentManager
		{
			return _oni.components;
		}
		
		public function get oni():Oni
		{
			return _oni;
		}
		
		public function get overlay():Boolean
		{
			return _overlay;
		}
		
	}

}