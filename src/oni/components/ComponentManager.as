package oni.components 
{
	import oni.Oni;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class ComponentManager extends EventDispatcher
	{
		public var components:Array;
		
		public function ComponentManager() 
		{
			//Create a components array
			components = new Array();
			
			//Listen for events to relay
			addEventListener(Oni.UPDATE, _relayEvent);
			addEventListener(Oni.ENABLE_DEBUG, _relayEvent);
			addEventListener(Oni.DISABLE_DEBUG, _relayEvent);
		}
		
		public function add(component:EventDispatcher):EventDispatcher
		{
			//Check if already added
			if (components.indexOf(component) == -1)
			{
				//Add
				components.push(component);
			}
			
			//Return
			return component;
		}
		
		public function remove(component:EventDispatcher):EventDispatcher
		{
			//Check added or not
			if (components.indexOf(component) > -1)
			{
				//Remove
				components.splice(components.indexOf(component, 1));
			}
			
			//Return
			return component;
		}
		
		private function _relayEvent(e:Event):void
		{
			//Relay event to all components
			for (var i:uint = 0; i < components.length; i++)
			{
				components[i].dispatchEvent(e);
			}
		}
		
	}

}