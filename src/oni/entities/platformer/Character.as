package oni.entities.platformer 
{
	import flash.geom.Point;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import oni.entities.Entity;
	import oni.entities.PhysicsEntity;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Character extends PhysicsEntity
	{
		private var _shape:Shape;
		
		private var _bodyWidth:int;
		
		private var _bodyHeight:int;
		
		private var _material:Material;
		
		public function Character(bodyWidth:int, bodyHeight:int)
		{
			//Set dimensions
			_bodyWidth = bodyWidth;
			_bodyHeight = bodyHeight;
			
			//Create a shape for graphics
			_shape = new Shape();
			_shape.graphics.beginFill(0x000000);
			_shape.graphics.lineStyle(1, 0xFFFFFF);
			_shape.graphics.drawRect(0, 0, bodyWidth, bodyHeight);
			_shape.graphics.endFill();
			addChild(_shape);
			
			//Set cull bounds
			cullBounds.setTo(0, 0, bodyWidth + 64, bodyHeight + 64);
		}
		
		override protected function _createBody():void 
		{
			//Create a physics body
			_physicsBody = new Body(BodyType.DYNAMIC, new Vec2(x, y));
			
			//Create a body material
			_material = new Material(Number.NEGATIVE_INFINITY, 0.4, 2, 1);
			
			//Create a body shape
			var angle:int = 4;
			_physicsBody.shapes.add(new Polygon([new Vec2(0, 0),
												 new Vec2(_bodyWidth, 0),
												 new Vec2(_bodyWidth, _bodyHeight-angle),
												 //new Vec2(_bodyWidth-(angle/4), _bodyHeight-(angle/2)),
												 new Vec2(_bodyWidth-angle, _bodyHeight),
												 new Vec2(angle, _bodyHeight),
												 //new Vec2((angle/4), _bodyHeight-(angle/2)),
												 new Vec2(0, _bodyHeight - angle),
												 new Vec2(0, 0)], _material));
			_physicsBody.allowRotation = false;
					
			//Set physics world
			_physicsBody.space = _physicsWorld;
		}
		
		public function get friction():Number
		{
			return _material.dynamicFriction;
		}
		
		public function set friction(value:Number):void
		{
			_material.dynamicFriction = value;
		}
		
		public function get velocity():Vec2
		{
			return _physicsBody.velocity;
		}
		
		public function set velocity(value:Vec2):void
		{
			_physicsBody.velocity = value;
		}
		
	}

}