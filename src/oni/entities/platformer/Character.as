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
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import oni.entities.PhysicsEntity;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Character extends PhysicsEntity
	{
		protected  var _material:Material;
		
		protected  var _moveDirection:int;
		
		protected  var _isJumping:Boolean;
		
		public function Character(params:Object)
		{
			//Default parameters
			if (params.jumpHeight == null) params.jumpHeight = 340;
			if (params.jumpAcceleration == null) params.jumpAcceleration = 10;
			if (params.acceleration == null) params.acceleration = 30;
			if (params.maxVelocity == null) params.maxVelocity = 240;
			
			//Super
			super(params);
			
			//Create a shape for graphics
			var _shape:Shape = new Shape();
			_shape.graphics.beginFill(0x000000);
			_shape.graphics.lineStyle(1, 0xFFFFFF);
			_shape.graphics.drawRect(0, 0, _params.bodyWidth, _params.bodyHeight);
			_shape.graphics.endFill();
			//addChild(_shape);
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _params.bodyWidth, _params.bodyHeight);
			
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
												 new Vec2(_params.bodyWidth, 0),
												 new Vec2(_params.bodyWidth, _params.bodyHeight-angle),
												 //new Vec2(_params.bodyWidth-(angle/4), _params.bodyHeight-(angle/2)),
												 new Vec2(_params.bodyWidth-angle, _params.bodyHeight),
												 new Vec2(angle, _params.bodyHeight),
												 //new Vec2((angle/4), _params.bodyHeight-(angle/2)),
												 new Vec2(0, _params.bodyHeight - angle),
												 new Vec2(0, 0)], _material));
			
			//Don't allow rotation
			_physicsBody.allowRotation = false;
					
			//Set physics world
			_physicsBody.space = _space;
		}
		
		public function jump():void
		{
			//Only jump is we're on ground
			if (onGround)
			{
				velocity.y = -_params.jumpHeight;
				_isJumping = true;
			}
		}
		
		public function get isJumping():Boolean
		{
			return !onGround && _isJumping;
		}
		
		public function set isJumping(value:Boolean):void
		{
			_isJumping = value;
		}
		
		private function _onUpdate(e:Event):void
		{
			//Are we jumping?
			if (isJumping && velocity.y < 0)
			{
				velocity.y -= _params.jumpAcceleration;
			}
			
			//Check if moving
			if (_moveDirection != 0)
			{
				//Accelerate
				if (!(velocity.x < -_params.maxVelocity || velocity.x > _params.maxVelocity))
				{
					velocity.x += _moveDirection * _params.acceleration;
				}
			}
		}
		
		public function move(direction:int):void
		{
			//Check if different
			if (canMove && direction != _moveDirection)
			{
				//Set direction
				_moveDirection = direction;
				
				//Reset velocity
				velocity.x = _moveDirection * _params.acceleration;
				
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
		
		public function get onGround():Boolean
		{
			return velocity.y > -1.5 && velocity.y < 1.5;
		}
		
		public function get canMove():Boolean
		{
			return true;
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
		
		public function get isMoving():Boolean
		{
			return velocity.x != 0;
		}
		
		public function get canJump():Boolean
		{
			return onGround;
		}
		
	}

}