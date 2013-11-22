package oni.entities 
{
    import flash.utils.getQualifiedClassName;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.errors.AbstractClassError;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PhysicsEntity extends Entity
	{
		/**
		 * The entity's physical body
		 */
		protected var _physicsBody:Body;
		
		/**
		 * Whether physics are enabled or not
		 */
		protected var _isPhysicsEnabled:Boolean;
		
		/**
		 * The physics space
		 */
		protected var _space:Space;
		
		/**
		 * Creates a physics entity, should not be called directly you naughty boy!
		 * @param	physicsEnabled
		 */
		public function PhysicsEntity(physicsEnabled:Boolean=true) 
		{
			//Not allowed to init this class directly fam
            if (Platform.debugEnabled && 
                getQualifiedClassName(this) == "oni.entities::PhysicsEntity")
            {
                throw new AbstractClassError();
            }
			
			//Set enabled
			_isPhysicsEnabled = physicsEnabled;
			
			//Listen for added
			addEventListener(Oni.ENTITY_ADDED, _onAdded);
		}
		
		/**
		 * Called when the entity has been added
		 * @param	e
		 */
		protected function _onAdded(e:Event):void
		{
			//Listen for update
			if(_physicsBody != null) e.data.manager.removeEventListener(Oni.UPDATE, _onUpdate);
			if(_isPhysicsEnabled) e.data.manager.addEventListener(Oni.UPDATE, _onUpdate);
			
			//Set physics world
			if(e.data.space != null) _space = e.data.space;
			
			//Can only update if we have access to the world
			if (_isPhysicsEnabled && _space != null)
			{
				//Update if we've already initialised
				if (_physicsBody != null)
				{
					//Set position
					_physicsBody.position = new Vec2(x, y);
				}
				else
				{
					//Create the body!
					_createBody();
					
					//Set data
					if(_physicsBody != null) _physicsBody.userData.entity = this;
				}
			}
			
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADDED, _onAdded);
		}
		
		/**
		 * Called when the engine updates
		 * @param	e
		 */
		private function _onUpdate(e:Event):void
		{
			//Update physics data, if we have a body
			if (_physicsBody != null)
			{
				//Set position
				super.x = _physicsBody.position.x;
				super.y = _physicsBody.position.y;
				
				//Set rotation
				super.rotation = _physicsBody.rotation;
			}
		}
		
		/**
		 * Creates a physics body
		 */
		protected function _createBody():void
		{
			//Nothing here
		}
		
		/**
		 * The entity's x co-ordinate
		 */
		override public function set x(value:Number):void 
		{
			//Only update if new
			if (super.x == value) return;
			
			//Set x for starling
			super.x = value;
			
			//Check if we have a physics body to update
			if (_physicsBody != null) 
			{
				if (_physicsBody.type == BodyType.STATIC)
				{
					_createBody();
				}
				else
				{
					_physicsBody.position.x = value;
				}
			}
		}
		
		/**
		 * The entity's y co-ordinate
		 */
		override public function set y(value:Number):void 
		{
			//Only update if new
			if (super.y == value) return;
			
			//Set y for starling
			super.y = value;
			
			//Check if we have a physics body to update
			if (_physicsBody != null) 
			{
				if (_physicsBody.type == BodyType.STATIC)
				{
					_createBody();
				}
				else
				{
					_physicsBody.position.y = value;
				}
			}
		}
		
		/**
		 * The entity's rotation
		 */
		override public function set rotation(value:Number):void 
		{
			//Only update if new
			if (super.rotation == value) return;
			
			//Set rotation for starling
			super.rotation = value;
			
			//Set physics body rotation
			if(_physicsBody != null && _physicsBody.rotation != value) _physicsBody.rotation = value;
		}
		
		/**
		 * Whether physics are enabled or not
		 */
		public function set enabled(value:Boolean):void 
		{
			//Do we already have a body?
			if (_physicsBody == null)
			{
				//Create the body!
				_createBody();
					
				//Set data
				_physicsBody.userData.entity = this;
			}
			else
			{
				if (value) //Enable the body
				{
					_physicsBody.space = _space;
				}
				else //Disable the body
				{
					_physicsBody.space = null;
				}
			}
			
			//Set
			_isPhysicsEnabled = value;
		}
		
		/**
		 * Whether physics are enabled or not
		 */
		public function get enabled():Boolean 
		{
			return _isPhysicsEnabled;
		}
		
	}

}