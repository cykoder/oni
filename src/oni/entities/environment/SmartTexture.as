package oni.entities.environment 
{
	import flash.display.Shader;
	import nape.geom.AABB;
	import nape.geom.IsoFunction;
	import nape.geom.MarchingSquares;
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import oni.entities.EntityManager;
	import oni.entities.PhysicsEntity;
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
	import starling.core.Starling;
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
	public class SmartTexture extends PhysicsEntity
	{
		private var _shape:Shape;
		
		private var _points:Array;
		
		private var _physicsShape:flash.display.Shape;
		
		public function SmartTexture(params:Object)
		{
			//Super
			super(params);
			
			//Create a shape for graphics
			_shape = new Shape();
			addChild(_shape);
			
			//Create a physics shape for the collision data
			_physicsShape = new flash.display.Shape();
			
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _updateCollision);
			
			//Update collision
			dispatchEventWith(Oni.UPDATE_DATA, false, params);
			
			//TODO: remove this bug line
			//addEventListener(TouchEvent.TOUCH, _touch);
		}
		
		override protected function _onAdded(e:Event):void 
		{
			//Remove current physics body
			if (_physicsBody != null)
			{
				_physicsBody.space = null;
				_physicsBody.shapes.clear();
				_physicsBody = null;
			}
				
			//Super
			super._onAdded(e);
		}
		
		private function _updateCollision(e:Event):void
		{
			//Get collision data
			_points = e.data.points;
			
			//Init physics
			if(e.data.collision) _createBody();
			
			//Get the textiures
			var backgroundTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_background");
			var floorTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_floor");
			var wallTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_wall");
			
			//Clear shape graphics
			_shape.graphics.clear();
			
			//Fill with the background texture
			_shape.graphics.beginTextureFill(backgroundTexture);
			
			//Loop through each point and redraw
			var i:uint;
			for (i = 0; i < _points.length; ++i)
			{
				//Check if first point
				if (i == 0)
				{
					_shape.graphics.moveTo(_points[i].x, _points[i].y);
				}
				else
				{
					//Calculate angles
					var x1:int = _points[i-1].x, y1:int = _points[i-1].y;
					var x2:int = _points[i].x, y2:int = _points[i].y;
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
					if (_points[i].control == null)
					{
						_shape.graphics.lineTo(_points[i].x, _points[i].y);
					}
					else
					{
						_shape.graphics.curveTo(_points[i].control.x, _points[i].control.y, _points[i].x, _points[i].y);
					}
				}
			}
			
			//End fill
			_shape.graphics.endFill();
			
			//Draw debug outlines
			/*_shape.graphics.lineStyle(5, 0xFFFFFF);
			for (i = 0; i < _points.length; ++i)
			{
				if (i == 0)
				{
					_shape.graphics.moveTo(_points[i].x, _points[i].y);
				}
				else
				{
					_shape.graphics.lineTo(_points[i].x, _points[i].y);
				}
			}
			
			//Draw debug points
			_shape.graphics.lineStyle(1, 0xCCCCCC);
			_shape.graphics.beginFill(0xFFFFFF, 1);
			for (i = 0; i < _points.length; i++)
			{
				_shape.graphics.drawCircle(_points[i].x, _points[i].y, 10);
				
				if (_points[i].control != null)
				{
					_shape.graphics.drawCircle(_points[i].control.x, _points[i].control.y, 5);
				}
			}
			_shape.graphics.endFill();*/
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _shape.width, _shape.height);
		}
		
		override protected function _createBody():void 
		{
			//Remove current physics body
			if (_physicsBody != null)
			{
				_physicsBody.space = null;
				_physicsBody.shapes.clear();
				_physicsBody = null;
			}
			
			//Create a physics body
			_physicsBody = new Body(BodyType.STATIC, new Vec2(x, y));
			
			//Begin drawing the physics shape
			_physicsShape.graphics.beginFill(0x0, 1);
			_physicsShape.graphics.lineStyle(8, 0x0);
			
			//Loop all points
			var i:uint;
			for (i = 0; i < _points.length; ++i)
			{
				//Check if first point
				if (i == 0)
				{
					_physicsShape.graphics.moveTo(_points[i].x, _points[i].y);
				}
				else
				{
					//Draw line
					if (_points[i].control == null)
					{
						_physicsShape.graphics.lineTo(_points[i].x, _points[i].y);
					}
					else
					{
						_physicsShape.graphics.curveTo(_points[i].control.x, _points[i].control.y, _points[i].x, _points[i].y);
					}
				}
			}
			
			//End drawing
			_physicsShape.graphics.endFill();
			
			//Create an iso fucntion with the physics shape
            var objIso:DisplayObjectIso = new DisplayObjectIso(_physicsShape);
			
			//Flash requires the object to be on stage for hitTestPoint
			Starling.current.nativeStage.addChild(_physicsShape);
			
			//Create a list of polygons to make up the collider
			var polys:GeomPolyList = MarchingSquares.run(objIso, objIso.bounds, Vec2.weak(8, 8), 2);
			for (i = 0; i < polys.length; i++)
			{
				var p:GeomPoly = polys.at(i);

				//Decompose into workable polygons
				var qolys:GeomPolyList = p.simplify(1.5).convexDecomposition(true);
				for (var j:int = 0; j < qolys.length; j++)
				{
					var q:GeomPoly = qolys.at(j);
					
					//Add the shape
					_physicsBody.shapes.add(new Polygon(q));

					//Recycle GeomPoly and its vertices
					q.dispose();
				}
				
				//Recycle list nodes
				qolys.clear();

				//Recycle GeomPoly and its vertices
				p.dispose();
			}
			
			//Recycle list nodes
			polys.clear();
			
			//Remove the physics shape
			Starling.current.nativeStage.removeChild(_physicsShape);
			
			//Clear the physics shape graphics
			_physicsShape.graphics.clear();
			
			//Set physics space
			_physicsBody.space = _space;
		}
		
		private var selectedPoint:int=-1, _hasSelectedControlPoint:Boolean;
		private function _touch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this);
			if (touch != null)
			{
				var touchLocation:Point = touch.getLocation(this);
				
				if (touch.phase == TouchPhase.BEGAN)
				{
						_points.push(_points[0]);
						
						var a:Point = new Point();
						var b:Point = new Point();
						
						for (var j:int = 1; j < _points.length; j++)
						{
							a.setTo(_points[j].x, _points[j].y);
							
							if (j + 1 >= _points.length)
							{
								b.setTo(_points[0].x, _points[0].y);
							}
							else
							{
								b.setTo(_points[j + 1].x, _points[j + 1].y);
							}
							
							/*if(intersect(a, b, new Point(_lastClick.x-50,_lastClick.y-50),new Point(_lastClick.x+50, _lastClick.y+50)))
							{
								_shape.graphics.lineStyle(10, 0xff0000);
								_shape.graphics.moveTo(a.x, a.y);
								_shape.graphics.lineTo(b.x, b.y);
								_points.splice(j+1, 0, _lastClick);
								dispatchEventWith(Oni.UPDATE_DATA, false, { points:_points } );
								break;
							}*/
						}
						_points.pop();
					
					var w:int = 50;
					
					var touchRect:Rectangle = new Rectangle(touchLocation.x-w, touchLocation.y-w, w*2, w*2);
					for (var i:int = 0; i < _points.length; i++)
					{
						if (touchRect.contains(_points[i].x, _points[i].y))
						{
							selectedPoint = i;
							_hasSelectedControlPoint = false;
							break;
						}
						else if (_points[i].control != null && touchRect.contains(_points[i].control.x, _points[i].control.y))
						{
							selectedPoint = i;
							_hasSelectedControlPoint = true;
							break;
						}
					}
				}
				else if (touch.phase == TouchPhase.MOVED)
				{
					if (selectedPoint > -1)
					{
						if (_hasSelectedControlPoint)
						{
							_points[selectedPoint].control = { x: touchLocation.x, y: touchLocation.y };
						}
						else
						{
							_points[selectedPoint].x = touchLocation.x;
							_points[selectedPoint].y = touchLocation.y;
							if (_points[selectedPoint].x < 0) _points[selectedPoint].x = 0;
							if (_points[selectedPoint].y < 0) _points[selectedPoint].y = 0;
						}
						
						dispatchEventWith(Oni.UPDATE_DATA, false, { points: _points, collision: false } );
					}
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					selectedPoint = -1;
					_hasSelectedControlPoint = false;
					dispatchEventWith(Oni.UPDATE_DATA, false, { points: _points, collision: true } );
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
		
		override public function set rotation(value:Number):void 
		{
			//Don't allow rotation
		}	
	}
}

import flash.display.DisplayObject;
import nape.geom.AABB;
import nape.geom.IsoFunction;

class DisplayObjectIso implements IsoFunction
{
	public var displayObject:DisplayObject;
	public var bounds:AABB;

	public function DisplayObjectIso(displayObject:DisplayObject):void
	{
		this.displayObject = displayObject;
		this.bounds = AABB.fromRect(displayObject.getBounds(displayObject));
	}
	
	public function iso(x:Number, y:Number):Number
	{
		return (displayObject.hitTestPoint(x, y, true) ? -1.0 : 1.0);
	}
}