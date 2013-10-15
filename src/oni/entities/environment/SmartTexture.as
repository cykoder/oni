package oni.entities.environment 
{
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import oni.entities.EntityManager;
	import oni.Oni;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nape.Config;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.space.Space;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class SmartTexture extends Entity
	{
		private var _texture:String;
		
		private var _shape:Shape;
		
		private var _collisionData:Array;
		
		private var _physicsBody:Body;
		
		private var _physicsWorld:Space;
		
		private var _collidable:Boolean;
		
		public function SmartTexture(texture:String, collisionData:Array, collidable:Boolean=true)
		{
			//Set texture
			_texture = texture;
			
			//Set collidble
			_collidable = collidable;
			
			//Set touchable
			this.touchable = true;
			
			//Create a shape for graphics
			_shape = new Shape();
			addChild(_shape);
			
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _updateCollision);
			
			//Listen for added
			addEventListener(Oni.ENTITY_ADD, _onAdded);
			
			//Update collision
			dispatchEventWith(Oni.UPDATE_DATA, false, { collisionData: collisionData } );
			
			//TODO: remove this bug line
			//addEventListener(TouchEvent.TOUCH, _touch);
		}
		
		private function _onAdded(e:Event):void
		{
			//Set physics world
			_physicsWorld = e.data.physicsWorld;
			
			//Init physics
			if(_collidable) _initPhysics();
			
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADD, _onAdded);
		}
		
		private function _initPhysics():void
		{
			//Can only update if we have access to the world
			if (_physicsWorld != null)
			{
				//Remove curernt physics body
				if (_physicsBody != null)
				{
					_physicsBody.space = null;
					_physicsBody.shapes.clear();
					_physicsBody = null;
				}
				
				//Create a physics body
				_physicsBody = new Body(BodyType.STATIC, new Vec2(x, y));
				
				//Transform collision data into nape vertices
				var vertices:Array = [];
				for (var i:uint = 0; i < _collisionData.length; i++) vertices.push(new Vec2(_collisionData[i].x, _collisionData[i].y));
				
				//Create a poly list and add shapes
				var polys:GeomPolyList = new GeomPoly(vertices).convexDecomposition();
				polys.foreach(function (p:GeomPoly):void
				{
					_physicsBody.shapes.add(new Polygon(p));
				});
				polys.clear();
				
				//Set physics world
				_physicsBody.space = _physicsWorld;
			}
		}
		
		private function _updateCollision(e:Event):void
		{
			//Get collision data
			_collisionData = e.data.collisionData;
			
			//Init physics
			if(_collidable) _initPhysics();
			
			//Get the textiures
			var backgroundTexture:Texture = AssetManager.getTexture("smarttexture_" + _texture + "_background");
			var floorTexture:Texture = AssetManager.getTexture("smarttexture_" + _texture + "_floor");
			var wallTexture:Texture = AssetManager.getTexture("smarttexture_" + _texture + "_wall");
			
			//Clear shape graphics
			_shape.graphics.clear();
			
			//Fill with the background texture
			_shape.graphics.beginTextureFill(backgroundTexture);
			
			//Loop through each point and redraw
			var i:uint;
			for (i = 0; i < _collisionData.length; ++i)
			{
				if (i == 0)
				{
					_shape.graphics.moveTo(_collisionData[i].x, _collisionData[i].y);
				}
				else
				{
					//Calculate angles
					var x1:int = _collisionData[i-1].x, y1:int = _collisionData[i-1].y;
					var x2:int = _collisionData[i].x, y2:int = _collisionData[i].y;
					var radians:Number = Math.atan2(y2 - y1,x2 - x1);
					var degrees:Number = radians / (Math.PI / 180);
					var positiveDegrees:Number = degrees;
					if (positiveDegrees < 0) positiveDegrees = degrees * -1;
					
					//Set line style
					if (degrees == 90) //Corner
					{
						_shape.graphics.lineTexture(128, wallTexture);
					}
					else if (degrees == -90) //Inside corner
					{
						_shape.graphics.lineTexture(128, wallTexture);
					}
					else if ((positiveDegrees >= 0 && positiveDegrees <= 60) || positiveDegrees == 180) //Floors
					{
						_shape.graphics.lineTexture(128, floorTexture);
					}
					else //Walls
					{
						_shape.graphics.lineTexture(128, wallTexture);
					}
					
					//Draw line
					_shape.graphics.lineTo(_collisionData[i].x, _collisionData[i].y);
				}
			}
			
			//End fill
			_shape.graphics.endFill();
			
			//Draw debug outlines
			/*_shape.graphics.lineStyle(5, 0xFFFFFF);
			for (i = 0; i < _collisionData.length; ++i)
			{
				if (i == 0)
				{
					_shape.graphics.moveTo(_collisionData[i].x, _collisionData[i].y);
				}
				else
				{
					_shape.graphics.lineTo(_collisionData[i].x, _collisionData[i].y);
				}
			}
			
			//Draw debug points
			_shape.graphics.lineStyle(1, 0xCCCCCC);
			_shape.graphics.beginFill(0xFFFFFF, 1);
			for (i = 0; i < _collisionData.length; ++i)
			{
				_shape.graphics.drawCircle(_collisionData[i].x, _collisionData[i].y, 10);
			}
			_shape.graphics.endFill();*/
			
			//Set cull bounds
			cullBounds.setTo(0, 0, width + 256, height + 256);
		}
		
		private var selectedPoint:int=-1, _lastClick:Point = new Point();
		private function _touch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this);
			if (touch != null)
			{
				if (touch.phase == TouchPhase.BEGAN)
				{
					if (_lastClick.x == touch.globalX-this.x && _lastClick.y == touch.globalY-this.y)
					{
						_collisionData.push(_collisionData[0]);
						
						for (var j:int = 1; j < _collisionData.length; j++)
						{
							if (_lastClick.x < 0)_lastClick.x = 0;
							if (_lastClick.y < 0)_lastClick.y = 0;
							
							var a:Point = _collisionData[j];
							var b:Point = _collisionData[j + 1];
							if (b == null) b = _collisionData[0];
							
							if(intersect(a, b, new Point(_lastClick.x-50,_lastClick.y-50),new Point(_lastClick.x+50, _lastClick.y+50)))
							{
								_shape.graphics.lineStyle(10, 0xff0000);
								_shape.graphics.moveTo(a.x, a.y);
								_shape.graphics.lineTo(b.x, b.y);
								_collisionData.splice(j+1, 0, _lastClick);
								dispatchEventWith(Oni.UPDATE_DATA, false, { collisionData:_collisionData } );
								break;
							}
						}
						_collisionData.pop();
					}
					_lastClick.setTo(touch.globalX-this.x, touch.globalY-this.y);
					
					var w:int = 50;
					var touchRect:Rectangle = new Rectangle(touch.globalX-this.x-w, touch.globalY-this.y-w, w*2, w*2);
					for (var i:int = 0; i < _collisionData.length; i++)
					{
						if (touchRect.containsPoint(new Point(_collisionData[i].x, _collisionData[i].y)))
						{
							selectedPoint = i;
							break;
						}
					}
				}
				else if (touch.phase == TouchPhase.MOVED)
				{
					if (selectedPoint > -1)
					{
						_collisionData[selectedPoint] = new Point((touch.globalX - this.x), (touch.globalY - this.y));
						if (_collisionData[selectedPoint].x < 0) _collisionData[selectedPoint].x = 0;
						if (_collisionData[selectedPoint].y < 0) _collisionData[selectedPoint].y = 0;
						dispatchEventWith(Oni.UPDATE_DATA, false, { collisionData:_collisionData } );
					}
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					selectedPoint = -1;
				}
			}
		}
		
		private function intersect(p1:Point, p2:Point, p3:Point, p4:Point):Point
		{
			var v12:Object = {x:p2.x - p1.x, y:p2.y - p1.y};
			var v34:Object = {x:p4.x - p3.x, y:p4.y - p3.y};
			var d:Number = v12.x * v34.y - v12.y * v34.x
			if(!d) return null; //points are collinear
			var a:Number = p3.x - p1.x;
			var b:Number = p3.y - p1.y
			var t:Number = (a * v34.y - b * v34.x) / d;
			var s:Number = (b * v12.x - a * v12.y) / -d;
			if(t < 0 || t > 1 || s < 0 || s > 1) return null; //line segments don't intersect
			return new Point(p1.x + v12.x * t, p1.y + v12.y * t)
		}
		
	}

}