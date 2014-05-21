package oni.components 
{
	import oni.core.ISerializable;
	import oni.entities.EntityManager;
	import oni.Oni;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class ComponentManager extends EventDispatcher implements ISerializable
	{
		/**
		 * The components vector
		 */
		public var components:Vector.<EventDispatcher>;
		
		/**
		 * The current engine instance
		 */
		private var _oni:Oni;
		
		/**
		 * Initialises a new component manager
		 */
		public function ComponentManager(oni:Oni) 
		{
			//Set engine instance
			_oni = oni;
			
			//Create a components vector
			components = new Vector.<EventDispatcher>();
			
			//Listen for update
			_oni.addEventListener(Oni.UPDATE, _onUpdate);
		}
		
		/**
		 * Adds a component, if silent it won't dispatch an added event
		 * @param	component
		 * @return
		 */
		public function add(component:EventDispatcher, silent:Boolean=false):EventDispatcher
		{
			//Check if already added
			if (components.indexOf(component) == -1)
			{
				//Add
				components.push(component);
				
				//Dispatch event
				if(!silent) component.dispatchEventWith(Oni.COMPONENT_ADDED, false, { manager:this });
			}
			
			//Return
			return component;
		}
		
		/**
		 * Removes a component,  if silent it won't dispatch a removed event
		 * @param	component
		 * @return
		 */
		public function remove(component:EventDispatcher, silent:Boolean=false):EventDispatcher
		{
			//Check added or not
			if (components.indexOf(component) > -1)
			{
				//Remove
				components.splice(components.indexOf(component, 1), 1);
				
				//Dispatch event
				if(!silent) component.dispatchEventWith(Oni.COMPONENT_REMOVED, false, { manager:this });
			}
			
			//Return
			return component;
		}
		
		/**
		 * Removes all components, if silent it won't dispatch a removed event
		 * @param	silent
		 */
		public function removeAll(silent:Boolean=false):void
		{
			//Remove all entities
			for (var i:int = 0; i < components.length; i++) remove(components[i], silent);
		}
		
		/**
		 * Called when the engine updates
		 * @param	e
		 */
		private function _onUpdate(e:Event):void
		{
			//Relay event to all components
			for (var i:int = 0; i < components.length; i++) components[i].dispatchEvent(e);
		}
		
		/**
		 * Serializes data to an object
		 * @return
		 */
		public function serialize():Object
		{
			var data:Array = new Array();
			for (var i:uint = 0; i < components.length; i++)
			{
				if (components[i] is ISerializable && !(components[i] is EntityManager))
				{
					data.push((components[i] as ISerializable).serialize());
				}
			}
			return data;
		}
		
	}

}