package oni.entities.debug 
{
	import oni.entities.Entity;
	import oni.entities.PhysicsEntity;
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
	public class DebugSquare extends PhysicsEntity
	{
		private var _wh:int;
		
		private var _shape:Shape;
		
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
			
			//Set cull bounds
			cullBounds.setTo(0, 0, wh + 64, wh + 64);
		}
		
		override protected function _createBody():void
		{
			//Create a physics body
			_physicsBody = new Body(BodyType.DYNAMIC, new Vec2(x, y));
			_physicsBody.shapes.add(new Polygon(Polygon.box(_wh, _wh)));
			
			//Set physics world
			_physicsBody.space = _physicsWorld;
		}
		
	}

}