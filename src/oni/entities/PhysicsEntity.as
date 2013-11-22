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
		protected var _physicsBody:Body;
		
		protected var _physicsEnabled:Boolean;
		
		protected var _space:Space;
		
		public function PhysicsEntity(physicsEnabled:Boolean=true) 
		{
			//Not allowed to init this class directly fam
            if (Platform.debugEnabled && 
                getQualifiedClassName(this) == "oni.entities::PhysicsEntity")
            {
                throw new AbstractClassError();
            }
			
			//Set physics enabled
			this.enabled = physicsEnabled;
			
			//Listen for added
			addEventListener(Oni.ENTITY_ADDED, _initPhysics);
		}
		
		private function _onUpdate(e:Event):void
		{
			//Update physics data, if we have a body
			if (_physicsBody != null)
			{
				//Set position
				x = _physicsBody.position.x;
				y = _physicsBody.position.y;
				
				//Set rotation
				rotation = _physicsBody.rotation;
			}
		}
		
		protected function _initPhysics(e:Event):void
		{
			//Listen for update
			if(_physicsBody != null) e.data.manager.removeEventListener(Oni.UPDATE, _onUpdate);
			if(_physicsEnabled) e.data.manager.addEventListener(Oni.UPDATE, _onUpdate);
			
			//Set physics world
			if(e.data.space != null) _space = e.data.space;
			
			//Can only update if we have access to the world
			if (_physicsEnabled && _space != null)
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
					_physicsBody.userData.entity = this;
				}
			}
			
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADDED, _initPhysics);
		}
		
		protected function _createBody():void
		{
			//Nothing here
		}
		
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
		
		override public function set rotation(value:Number):void 
		{
			super.rotation = value;
			if(_physicsBody != null && _physicsBody.rotation != value) _physicsBody.rotation = value;
		}
		
		public function set enabled(value:Boolean):void 
		{
			if (_physicsEnabled != value)
			{
				_physicsEnabled = value;
				if (_physicsBody != null) _physicsBody.space = null;
			}
		}
		
		public function get enabled():Boolean 
		{
			return _physicsEnabled;
		}
		
	}

}