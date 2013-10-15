package oni.entities.debug 
{
	import oni.entities.Entity;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class DebugSquare extends Entity
	{
		private var _wh:int;
		
		private var _shape:Shape;
		
		private var _physicsBody:Body;
		
		private var _physicsWorld:Space;
		
		public function DebugSquare(wh:int) 
		{
			//Set width and height
			_wh = wh;
			
			//No culling
			this.cull = false;
			
			//Set pivot
			this.pivotX = this.pivotY = _wh / 2;
			
			//Create a shape for graphics
			_shape = new Shape();
			_shape.graphics.beginFill(0x000000);
			_shape.graphics.lineStyle(1, 0xFFFFFF);
			_shape.graphics.drawRect(0, 0, wh, wh);
			_shape.graphics.endFill();
			addChild(_shape);
			
			//Listen for added
			addEventListener(Oni.ENTITY_ADD, _onAdded);
		}
		
		private function _onAdded(e:Event):void
		{
			//Set physics world
			_physicsWorld = e.data.physicsWorld;
			
			//Init physics
			_initPhysics();
			
			//Listen for update
			e.data.manager.addEventListener(Oni.UPDATE, _onUpdate);
			
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADD, _onAdded);
		}
		
		private function _initPhysics(e:Event=null):void
		{
			//Can only update if we have access to the world
			if (_physicsWorld != null)
			{
				//Update if we've already initialised
				if (_physicsBody != null)
				{
					//Set position
					_physicsBody.position = new Vec2(x, y);
				}
				else
				{
					//Create a physics body
					_physicsBody = new Body(BodyType.DYNAMIC, new Vec2(x, y));
					_physicsBody.shapes.add(new Polygon(Polygon.box(_wh, _wh)));
					
					//Set physics world
					_physicsBody.space = _physicsWorld;
				}
			}
		}
		
		private function _onUpdate(e:Event):void
		{
			super.x = _physicsBody.position.x;
			super.y = _physicsBody.position.y;
			this.rotation = _physicsBody.rotation;
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
			if(_physicsBody != null) _physicsBody.position.x = value;
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
			if(_physicsBody != null) _physicsBody.position.y = value;
		}
		
	}

}