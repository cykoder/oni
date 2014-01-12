package oni.entities.platformer 
{
	import flash.geom.Point;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
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
		public var jumpHeight:Number = 340;
		
		public var jumpAcceleration:Number = 10;
		
		public var acceleration:Number = 30;
		
		public var maxVelocity:Number = 240;
		
		private var _shape:Shape;
		
		private var _bodyWidth:int;
		
		private var _bodyHeight:int;
		
		private var _material:Material;
		
		private var _footSensor:Polygon;
		
		private var _onGround:Boolean;
		
		private var _moveDirection:int;
		
		private var _isJumping:Boolean;
		
		public function Character(params:Object)
		{
			//Super
			super(params);
			
			//Set dimensions
			_bodyWidth = params.bodyWidth;
			_bodyHeight = params.bodyHeight;
			
			//Create a shape for graphics
			_shape = new Shape();
			_shape.graphics.beginFill(0x000000);
			_shape.graphics.lineStyle(1, 0xFFFFFF);
			_shape.graphics.drawRect(0, 0, _bodyWidth, _bodyHeight);
			_shape.graphics.endFill();
			addChild(_shape);
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _bodyWidth, _bodyHeight);
			
			//Listen for physics interaction
			addEventListener(Oni.PHYSICS_INTERACTION, _onPhysicsInteraction);
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
		}
		
		override protected function _createBody():void 
		{
			//Create a physics body
			_physicsBody = new Body(BodyType.DYNAMIC, new Vec2(x, y));
			
			//Create a body material
			_material = new Material(Number.NEGATIVE_INFINITY, 0.4, 2, 10);
			
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
			
			//Create a foot sensor
			_footSensor = new Polygon(Polygon.rect(2, _bodyHeight-2, _bodyWidth-4, 8));
			_footSensor.sensorEnabled = true;
			_physicsBody.shapes.add(_footSensor);
			
			//Don't allow rotation
			_physicsBody.allowRotation = false;
					
			//Set physics world
			_physicsBody.space = _space;
		}
		
		private function _onPhysicsInteraction(e:Event):void
		{
			//Sensor interaction
			if (e.data.type == InteractionType.SENSOR)
			{
				//Set on ground
				_onGround = (e.data.event == CbEvent.BEGIN);
				if (_onGround) _isJumping = false;
			}
		}
		
		public function jump():void
		{
			//Only jump is we're on ground
			if (_onGround)
			{
				velocity.y = -jumpHeight;
				_isJumping = true;
			}
		}
		
		public function stopJumping():void
		{
			_isJumping = false;
		}
		
		private function _onUpdate(e:Event):void
		{
			//Are we jumping?
			if (_isJumping && velocity.y < 0)
			{
				velocity.y -= jumpAcceleration;
			}
			
			//Check if moving
			if (_moveDirection != 0)
			{
				//Accelerate
				if (!(velocity.x < -maxVelocity || velocity.x > maxVelocity))
				{
					velocity.x += _moveDirection * acceleration;
				}
			}
		}
		
		public function move(direction:int):void
		{
			//Check if different
			if (direction != _moveDirection)
			{
				//Set direction
				_moveDirection = direction;
				
				//Reset velocity
				velocity.x = _moveDirection * acceleration;
				
				//Clear friction
				friction = 0;
			}
		}
		
		public function stop():void
		{
			//Stop moving
			velocity.x = 0;
			friction = 0.4;
			_moveDirection = 0;
		}
		
		public function get footSensor():Polygon
		{
			return _footSensor;
		}
		
		public function get onGround():Boolean
		{
			return _onGround;
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
		
		override public function set rotation(value:Number):void 
		{
			//Don't allow rotation
		}
		
	}

}