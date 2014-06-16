package oni.entities.platformer 
{
	import flash.geom.Point;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Ray;
	import nape.geom.RayResult;
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
		private var _state:String;
		
		protected  var _material:Material;
		
		protected  var _moveDirection:int;
		
		protected  var _isJumping:Boolean;
		
		protected var _floorCheckRay:Ray;
		
		private var _fallTimer:uint=0;
		
		public function Character(params:Object)
		{
			//Default parameters
			if (params.acceleration == null) params.acceleration = 30;
			if (params.maxVelocity == null) params.maxVelocity = 50;
			
			//Super
			super(params);
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _params.bodyWidth, _params.bodyHeight);
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
			
			//Create a floor check ray
			_floorCheckRay = new Ray(Vec2.weak(), new Vec2(0, 1));
			_floorCheckRay.maxDistance = 100;
			
			//Listen for debug draw
			addEventListener(Oni.DEBUG_DRAW, _onDebugDraw);
			
			//Set state to idle
			state = "idle";
		}
		
		private function _onDebugDraw(e:Event):void
		{
			//Draw floor check ray
			_floorCheckRay.origin.set(Vec2.weak(this.x+_params.bodyWidth/2, this.y + _params.bodyHeight));
			var rayResult:RayResult = _physicsBody.space.rayCast(_floorCheckRay);
			if (rayResult != null)
			{
				var collision:Vec2 = _floorCheckRay.at(rayResult.distance);
				e.data.debug.drawLine(_floorCheckRay.origin, collision, 0xaa00);
				// Draw circle at collision point, and collision normal.
				e.data.debug.drawFilledCircle(collision, 3, 0xaa0000);
				e.data.debug.drawLine(
					collision,
					collision.addMul(rayResult.normal, 15, true),
					0xaa0000
				);
				collision.dispose();
	
				// release rayResult object to pool.
				rayResult.dispose();
			}
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
												 new Vec2(_params.bodyWidth-angle, _params.bodyHeight),
												 new Vec2(angle, _params.bodyHeight),
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
		
		protected function _onUpdate(e:Event):void
		{
			if (state != "dead")
			{
				//Are we jumping?
				if (isJumping && velocity.y < 0)
				{
					state = "jumping";
					velocity.y -= _params.jumpAcceleration;
				}
				else if(velocity.y > 120) //We're falling!
				{
					_isJumping = false;
					
					//Check if we're on the ground or not
					_floorCheckRay.origin.set(Vec2.weak(this.x+_params.bodyWidth/2, this.y + _params.bodyHeight));
					var rayResult:RayResult = _physicsBody.space.rayCast(_floorCheckRay);
					if (rayResult != null)
					{
						if (state == "landing")
						{
							state = "idle";
						}
						else
						{
							_fallTimer = 0;
							state = "landing";
						}
						
						rayResult.dispose();
					}
					else
					{
						state = "falling";
						_fallTimer++;
						if (_fallTimer > 60)
						{
							state = "falltodeath";
							_fallTimer = 0;
						}
					}
				}
				else if (state == "idle" || state == "moving" || state == "landing") //Check if we are moving or idle
				{
					if (velocity.x > 0.75 || velocity.x < -0.75)
					{
						state = "moving";
					}
					else
					{
						state = "idle";
						_moveDirection = 0;
					}
				}
				
					//Check move direction for acceleration
					if (_moveDirection != 0)
					{
						//Are we under the velocity limit?
						if (!(velocity.x < -_params.maxVelocity || velocity.x > _params.maxVelocity))
						{
							//Accelerate
							velocity.x += _moveDirection * _params.acceleration;
						}
						else
						{
							if (_moveDirection == 1) velocity.x = _params.maxVelocity;
							if (_moveDirection == -1) velocity.x = -_params.maxVelocity;
						}
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
		
		public function get state():String
		{
			return _state;
		}
		
		public function set state(value:String):void
		{
			//Check if different
			if (_state != value)
			{
				//Set state
				_state = value;
				
				//Dispatch changed event
				dispatchEventWith(Oni.UPDATE_DATA, false, { state: value });
			}
		}
		
	}

}