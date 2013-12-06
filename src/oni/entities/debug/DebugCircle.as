package oni.entities.debug 
{
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
	public class DebugCircle extends PhysicsEntity
	{
		/**
		 * The radius of the circle
		 */
		private var _radius:int;
		
		/**
		 * The shape to draw to
		 */
		private var _shape:Shape;
		
		/**
		 * Creates a debug circle with the given radius
		 * @param	radius
		 */
		public function DebugCircle(params:Object) 
		{
			//Super
			super(params);
			
			//Set radius
			_radius = params.radius/2;
			
			//No culling
			this.cull = false;
			
			//Create a shape for graphics
			_shape = new Shape();
			_shape.graphics.beginFill(0x000000);
			_shape.graphics.drawCircle(0, 0, _radius);
			_shape.graphics.endFill();
			_shape.graphics.lineStyle(1, 0xFFFFFF);
			_shape.graphics.moveTo(0, -_radius);
			_shape.graphics.lineTo(0, 0);
			addChild(_shape);
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _radius*2, _radius*2);
		}
		
		/**
		 * Creates a physics body
		 */
		override protected function _createBody():void 
		{
			//Create a physics body
			_physicsBody = new Body(BodyType.DYNAMIC, new Vec2(x, y));
			_physicsBody.shapes.add(new Circle(_radius));
					
			//Set physics space
			_physicsBody.space = _space;
		}
		
	}

}