package oni.entities 
{
	import oni.Oni;
	import oni.utils.Platform;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.ShapeDebug;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class EntityManager extends EventDispatcher
	{
		public var entities:Array;
		
		private var _physicsWorld:Space;
		
		public function EntityManager(physics:Boolean=true) 
		{
			//Create an entities array
			entities = new Array();
			
			//Setup physics
			if(physics) setupPhysics(new Vec2(0, 600));
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
			
			//Listen for events to relay
			addEventListener(Oni.ENABLE_DEBUG, _relayEvent);
			addEventListener(Oni.DISABLE_DEBUG, _relayEvent);
		}
		
		public function setupPhysics(gravity:Vec2):void
		{
			//Check if we already have a physics world
			if (_physicsWorld != null)
			{
				//Clear and set gravity
				_physicsWorld.clear();
				_physicsWorld.gravity = gravity;
			}
			else
			{
				//Create a physics world
				_physicsWorld = new Space(new Vec2(0, 600));
			}
		}
		
		public function get physicsEnabled():Boolean
		{
			return _physicsWorld != null;
		}
		
		private function _onUpdate(e:Event):void
		{
			//Update the physics world
			if(_physicsWorld != null) _physicsWorld.step(1 / 30);
			
			//Relay
			_relayEvent(e);
		}
		
		private function _relayEvent(e:Event):void
		{
			//Relay event to all entities
			for (var i:uint = 0; i < entities.length; i++)
			{
				entities[i].dispatchEvent(e);
			}
		}
		
		public function add(entity:Entity, silent:Boolean=false):Entity
		{
			//Dispatch added event
			entity.dispatchEventWith(Oni.ENTITY_ADDED, false, { manager:this, physicsWorld:_physicsWorld } );
			
			//Add to list
			entities.push(entity);
			
			//Dispatch event
			if(!silent) dispatchEventWith(Oni.ENTITY_ADDED, false, { entity:entity } );
			
			//Return
			return entity;
		}
		
		public function remove(entity:Entity, silent:Boolean=false):void
		{
			//Dispatch removed event
			entity.dispatchEventWith(Oni.ENTITY_REMOVED, false, { manager:this } );
			
			//Remove
			entities.splice(entities.indexOf(entity), 1);
			
			//Dispatch event
			if(!silent) dispatchEventWith(Oni.ENTITY_REMOVED, false, { entity:entity } );
		}
		
		public function removeAll(silent:Boolean=false):void
		{
			//Remove all entities
			for (var i:int = 0; i < entities.length; i++) remove(entities[i], silent);
		}
		
	}

}