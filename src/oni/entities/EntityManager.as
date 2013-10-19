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
		public var physicsWorld:Space;
		
		public var entities:Array;
		
		private var _napeDebug:ShapeDebug;
		
		public function EntityManager(gravity:Number=600) 
		{
			//Create a physics world
			physicsWorld = new Space(new Vec2(0, gravity));
			
			//Setup a debugger
			/*if (Platform.debugEnabled)
			{
				_napeDebug = new ShapeDebug(Main.s.stageWidth, Main.s.stageHeight, 0x000000);
				_napeDebug.drawConstraints = true;
				_napeDebug.display.scaleX = Main.s.stageWidth / 960;
				_napeDebug.display.scaleY = Main.s.stageHeight / 540;
				Main.s.addChild(_napeDebug.display);
			}*/
			
			//Create an entities array
			entities = new Array();
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
			
			//Listen for debug enabled
			addEventListener(Oni.ENABLE_DEBUG, _onDebugEnabled);
		}
		
		private function _onDebugEnabled(e:Event):void
		{
			//Relay event to all entities
			for (var i:uint = 0; i < entities.length; i++)
			{
				entities[i].dispatchEvent(e);
			}
		}
		
		private function _onUpdate(e:Event):void
		{
			//Update the physics world
			physicsWorld.step(1 / 30);
			
			//Update debug view
			if (_napeDebug != null)
			{
				_napeDebug.clear();
				_napeDebug.draw(physicsWorld);
				_napeDebug.flush();
			}
		}
		
		public function addEntity(entity:Entity):Entity
		{
			//Dispatch added event
			entity.dispatchEventWith(Oni.ENTITY_ADD, false, { manager:this, physicsWorld:this.physicsWorld } );
			
			//Add to list
			entities.push(entity);
			
			//Dispatch event
			dispatchEventWith(Oni.ENTITY_ADD, false, { entity:entity } );
			
			//Return
			return entity;
		}
		
		public function removeEntity(entity:Entity):void
		{
			//Dispatch removed event
			entity.dispatchEventWith(Oni.ENTITY_REMOVE, false, { manager:this } );
			
			//Remove
			entities.splice(entities.indexOf(entity), 1);
			
			//Dispatch event
			dispatchEventWith(Oni.ENTITY_REMOVE, false, { entity:entity } );
		}
		
	}

}