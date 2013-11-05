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
		 * A base class for all types of screens
		 * @param	name
		 */
		public function Screen(oni:Oni, name:String) 
		{
			//Set the name
			this.name = name;
			
			//Set oni instance
			_oni = oni;
		}
		
		public function remove():void
		{
			//Remove from parent
			_oni.removeChild(this);
		}
		
		public function get components():ComponentManager
		{
			return _oni.components;
		}
		
		public function get oni():Oni
		{
			return _oni;
		}
		
	}

}