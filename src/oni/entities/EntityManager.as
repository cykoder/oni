package oni.entities 
{
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.util.Debug;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.space.Space;
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
		
		private var debug:ShapeDebug;
		
		public function EntityManager(physics:Boolean=true, gravity:Vec2=null) 
		{
			//Create an entities array
			entities = new Array();
			
			//Setup physics
			if (physics)
			{
				//Set default gravity
				if (gravity == null) gravity = new Vec2(0, 600);
				setupPhysics(gravity);
			}
			
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
			
				//Create collision interaction listeners
				_physicsWorld.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, _onCollisionInteraction));
				_physicsWorld.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, _onCollisionInteraction));
				
				//Create sensor interaction listeners
				_physicsWorld.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, CbType.ANY_BODY, CbType.ANY_BODY, _onSensorInteraction));
				_physicsWorld.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, CbType.ANY_BODY, CbType.ANY_BODY, _onSensorInteraction));
				
				//Add debug
				debug = new ShapeDebug(Starling.current.nativeStage.stageWidth, Starling.current.nativeStage.stageHeight);
				//Starling.current.nativeStage.addChild(debug.display);
			}
		}
		
		private function _onCollisionInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type: InteractionType.COLLISION, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		private function _onSensorInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type:InteractionType.SENSOR, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		public function get physicsEnabled():Boolean
		{
			return _physicsWorld != null;
		}
		
		private function _onUpdate(e:Event):void
		{
			//Update the physics world
			if (_physicsWorld != null)
			{
				_physicsWorld.step(1 / 30);
				
				debug.clear();
				debug.draw(_physicsWorld);
				debug.flush();
			}
			
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