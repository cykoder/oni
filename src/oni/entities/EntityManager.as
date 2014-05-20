package oni.entities 
{
	import flash.geom.Point;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	import oni.assets.AssetManager;
	import oni.core.ISerializable;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.space.Space;
	import oni.Startup;
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class EntityManager extends EventDispatcher implements ISerializable
	{
		/**
		 * The physics time step
		 */
		public static var TIME_STEP:Number = 1 / 30;
		
		/**
		 * A list of current entities
		 */
		private var _entities:Vector.<Entity>;
		
		/**
		 * The physics space
		 */
		private var _space:Space;
		
		/**
		 * Whether the entities should update or not
		 */
		private var _paused:Boolean;
		
		/**
		 * Nape physics debug display
		 */
		private var _napeDebug:ShapeDebug;
		
		/**
		 * Creates an entity manager instance, with physics enabled or not
		 * @param	physics
		 * @param	gravity
		 */
		public function EntityManager(physics:Boolean=true, gravity:Point=null) 
		{
			//Create an entities vector
			_entities = new Vector.<Entity>();
			
			//Setup physics
			if (physics) setupPhysics(gravity);
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
		}
		
		/**
		 * Sets up a physics space with the given parameters
		 * @param	gravity
		 */
		public function setupPhysics(gravity:Point=null):void
		{
			//Set default gravity
			if (gravity == null) gravity = new Point(0, 600);
			
			//Check if we already have a physics space
			if (_space != null)
			{
				//Clear and set gravity
				_space.clear();
				_space.gravity = new Vec2(gravity.x, gravity.y);
			}
			else
			{
				//Create a physics space
				_space = new Space(new Vec2(gravity.x, gravity.y));
			
				//Create collision interaction listeners
				_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, _onCollisionInteraction));
				_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.COLLISION, CbType.ANY_BODY, CbType.ANY_BODY, _onCollisionInteraction));
			
				//Create fluid interaction listeners
				_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.FLUID, CbType.ANY_BODY , CbType.ANY_BODY, _onFluidInteraction));
				_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.FLUID, CbType.ANY_BODY, CbType.ANY_BODY, _onFluidInteraction));
				
				//Create sensor interaction listeners
				_space.listeners.add(new InteractionListener(CbEvent.BEGIN, InteractionType.SENSOR, CbType.ANY_BODY, CbType.ANY_BODY, _onSensorInteraction));
				_space.listeners.add(new InteractionListener(CbEvent.END, InteractionType.SENSOR, CbType.ANY_BODY, CbType.ANY_BODY, _onSensorInteraction));
				
				//Create a debug display
				_napeDebug = new ShapeDebug(Starling.current.stage.stageWidth, Starling.current.stage.stageHeight, 0xFFFFFF);
				_napeDebug.display.scaleX = Starling.current.nativeStage.stageWidth / Starling.current.stage.stageWidth;
				_napeDebug.display.scaleY = Starling.current.nativeStage.stageHeight / Starling.current.stage.stageHeight;
			}
		}
		
		/**
		 * Called when there is a collision interaction
		 * @param	callback
		 */
		private function _onCollisionInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type: InteractionType.COLLISION, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			if(a != null) a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			if(b != null) b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		/**
		 * Called when there is a fluid interaction
		 * @param	callback
		 */
		private function _onFluidInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type: InteractionType.FLUID, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			if(a != null) a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			if(b != null) b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		/**
		 * Called when there is a sensor interaction
		 * @param	callback
		 */
		private function _onSensorInteraction(callback:InteractionCallback):void
		{
			//Get contacts
			var a:PhysicsEntity = callback.int1.userData.entity;
			var b:PhysicsEntity = callback.int2.userData.entity;
			
			//Set data
			var data:Object = { type:InteractionType.SENSOR, event: callback.event, arbiters: callback.arbiters, a: a, b: b };
			
			//Callback
			if(a != null) a.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
			if(b != null) b.dispatchEventWith(Oni.PHYSICS_INTERACTION, false, data);
		}
		
		/**
		 * Whether physics are enabled or not
		 */
		public function get physicsEnabled():Boolean
		{
			return _space != null;
		}
		
		/**
		 * Whether physics are enabled or not
		 */
		public function set physicsEnabled(value:Boolean):void
		{
			if (physicsEnabled && !value)
			{
				//Disable
				_space.clear();
				_space = null;
			}
			else if (value)
			{
				//Enable
				setupPhysics();
			}
		}
		
		/**
		 * Called when the engine updates
		 * @param	e
		 */
		private function _onUpdate(e:Event):void
		{
			//Only if not paused
			if (!_paused)
			{
				//Fire update event
				var i:uint;
				for (i = 0; i < _entities.length; i++) 
				{
					_entities[i].dispatchEvent(e);
				}
				
				//Check if we should update physics
				if (_space != null) 
				{
					//Step physics time
					_space.step(TIME_STEP);
					
					//Debug drawing
					if (_napeDebug != null && _napeDebug.display.parent != null)
					{
						//Redraw debug view
						_napeDebug.clear();
						_napeDebug.draw(_space);
						
						//Dispatch debug draw event
						for (i = 0; i < _entities.length; i++) 
						{
							_entities[i].dispatchEventWith(Oni.DEBUG_DRAW, false, { debug: _napeDebug });
						}
						
						//Flush the debug
						_napeDebug.flush();
					}
				}
			}
		}
		
		/**
		 * Adds an entity, if silent it won't dispatch an added event
		 * @param	entity
		 * @param	silent
		 * @return
		 */
		public function add(entity:Entity, silent:Boolean=false):Entity
		{
			//Dispatch added event
			entity.dispatchEventWith(Oni.ENTITY_ADDED, false, { space: _space, manager: this } );
			
			//Add to list
			_entities.push(entity);
			
			//Dispatch event
			if (!silent) dispatchEventWith(Oni.ENTITY_ADDED, false, { entity: entity } );
			
			//Return
			return entity;
		}
		
		/**
		 * Removes an entity, if silent it won't dispatch a removed event
		 * @param	entity
		 * @param	silent
		 * @return
		 */
		public function remove(entity:Entity, silent:Boolean=false):void
		{
			//Remove
			_entities.splice(_entities.indexOf(entity), 1);
			if (entity != null)
			{
				//Remove from parent
				if (entity.parent != null) entity.removeFromParent(false);
				
				//Dispatch removed event
				entity.dispatchEventWith(Oni.ENTITY_REMOVED);
				
				//Dispatch event
				if (!silent) dispatchEventWith(Oni.ENTITY_REMOVED, false, { entity: entity } );
			}
		}
		
		/**
		 * Removes all entities, if silent it won't dispatch a removed event
		 * @param	silent
		 */
		public function removeAll(silent:Boolean=false):void
		{
			//Remove all entities
			while (_entities.length > 0)
			{
				remove(_entities[0], silent);
			}
		}
		
		/**
		 * Gets an entity by index
		 * @param	index
		 * @return
		 */
		public function get(index:int):Entity
		{
			return _entities[index];
		}
		
		/**
		 * Whether the entities should update or not
		 */
		public function get paused():Boolean
		{
			return _paused;
		}
		
		/**
		 * Whether the entities should update or not
		 */
		public function set paused(value:Boolean):void
		{
			_paused = value;
		}
		
		/**
		 * The physics space's gravity
		 */
		public function get gravity():Point
		{
			if (_space != null) return new Point(_space.gravity.x, _space.gravity.y);
			return new Point(0,600);
		}
		
		/**
		 * The physics space's gravity
		 */
		public function set gravity(value:Point):void
		{
			if (_space != null) _space.gravity = new Vec2(value.x, value.y);
		}
		
		/**
		 * The amount of entities in the scene
		 */
		public function get length():int
		{
			return _entities.length;
		}
		
		/**
		 * Serializes data to an object
		 * @return
		 */
		public function serialize():Object
		{
			var data:Array = new Array();
			for (var i:uint = 0; i < _entities.length; i++)
			{
				if(_entities[i].serializable) data.push(_entities[i].serialize());
			}
			return data;
		}
		
		/**Boolean
		 */
		public function get debug():Boolean
		{
			return _napeDebug != null && _napeDebug.display.parent != null;
		}
		
		/**
		 * Debug on/off
		 */
		public function set debug(value:Boolean):void
		{
			if (_napeDebug != null)
			{
				if (value)
				{
					Starling.current.nativeStage.addChild(_napeDebug.display);
				}
				else if (_napeDebug.display.parent != null)
				{
					Starling.current.nativeStage.removeChild(_napeDebug.display);
				}
			}
		}
		
	}

}