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
		
		protected var _physicsWorld:Space;
		
		public function PhysicsEntity() 
		{
			//Not allowed to init this class directly fam
            if (Platform.debugEnabled && 
                getQualifiedClassName(this) == "oni.entities::PhysicsEntity")
            {
                throw new AbstractClassError();
            }
			
			//Listen for added
			addEventListener(Oni.ENTITY_ADD, _initPhysics);
		}
		
		private function _initPhysics(e:Event):void
		{
			//Set physics world
			if(e.data.physicsWorld != null) _physicsWorld = e.data.physicsWorld;
			
			//Can only update if we have access to the world
			if (_physicsEnabled && _physicsWorld != null)
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
				}
			}
			
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADD, _initPhysics);
		}
		
		protected function _createBody():void
		{
			//Nothing here
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
			if(_physicsBody != null) _physicsBody.position.x = value;
		}
		
		override public function get x():Number 
		{
			if (!_physicsBody) return super.x;
			rotation = _physicsBody.rotation;
			return _physicsBody.position.x;
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
			if(_physicsBody != null) _physicsBody.position.y = value;
		}
		
		override public function get y():Number 
		{
			if (!_physicsBody) return super.y;
			rotation = _physicsBody.rotation;
			return _physicsBody.position.y;
		}
		
		override public function set rotation(value:Number):void 
		{
			super.rotation = value;
			if(_physicsBody != null && _physicsBody.rotation != value) _physicsBody.rotation = value;
		}
		
		override public function get rotation():Number 
		{
			if (!_physicsBody) return super.rotation;
			return super.rotation;
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