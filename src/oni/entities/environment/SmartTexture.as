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
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Event;
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
			
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _onUpdateData);
			
			//Update data
			dispatchEventWith(Oni.UPDATE_DATA, false, params);
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
		
		private function _onUpdateData(e:Event):void
		{
			//Check if we have any data
			if (e.data != null)
			{
				//Set points
				_points = e.data.points;
				
				//Init physics
				if (e.data.collision && physics) _createBody();
			}
			
			//Get the textiures
			var backgroundTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_background");
			var topTexture:Texture, edgeTexture:Texture, bottomTexture:Texture, leftCornerTexture:Texture, rightCornerTexture:Texture;
			if (!_params.backgroundOnly)
			{
				topTexture = AssetManager.getTexture("smarttexture_" + _params.texture + "_top");
				edgeTexture = AssetManager.getTexture("smarttexture_" + _params.texture + "_edge");
				bottomTexture = AssetManager.getTexture("smarttexture_" + _params.texture + "_bottom");
				leftCornerTexture = AssetManager.getTexture("smarttexture_" + _params.texture + "_left_corner");
				rightCornerTexture = AssetManager.getTexture("smarttexture_" + _params.texture + "_right_corner");
			}
			
			//Clear shape graphics
			_shape.graphics.clear();
			
			//Fill with the background texture
			if (backgroundTexture != null && !isLine) _shape.graphics.beginTextureFill(backgroundTexture);
			
			//Trace background
			var i:uint;
			var x1:int;
			var y1:int;
			var x2:int;
			var y2:int;
			var radians:Number;
			var degrees:Number;
			var positiveDegrees:Number;
			for (i = 0; i < _points.length; ++i)
			{
				//Reset line style
				_shape.graphics.lineStyle(0);
				
				//Check if first point
				if (i == 0)
				{
					_shape.graphics.moveTo(_points[i].x, _points[i].y);
				}
				else
				{
					//Calculate angles
					x1 = _points[i-1].x, y1 = _points[i-1].y;
					x2 = _points[i].x, y2 = _points[i].y;
					radians = Math.atan2(y2 - y1,x2 - x1);
					degrees = radians / (Math.PI / 180);
					positiveDegrees = degrees;
					if (positiveDegrees < 0) positiveDegrees = degrees * -1;
					if (positiveDegrees > 130)
					{
						if (bottomTexture != null)
						{
							_shape.graphics.lineTexture(128, bottomTexture); //Bottom
						}
						else if (edgeTexture != null)
						{
							_shape.graphics.lineTexture(128, edgeTexture); //No bottom, default as edge
						}
					}
					else if (!((positiveDegrees >= 0 && positiveDegrees <= 60) || positiveDegrees == 180))
					{
						if (edgeTexture != null)
						{
							_shape.graphics.lineTexture(128, edgeTexture); //Edge
						}
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
			if (backgroundTexture != null) 
			{
				_shape.graphics.endFill();
			}
			
			//Edges and detailing
			if (!_params.backgroundOnly)
			{
				for (i = 0; i < _points.length; ++i)
				{
					//Reset line style
					_shape.graphics.lineStyle(0);
					
					//Check if first point
					if (i == 0)
					{
						_shape.graphics.moveTo(_points[i].x, _points[i].y);
					}
					else
					{
						//Shall we draw walls/floors?
						if (!_params.backgroundOnly)
						{
							//Calculate angles
							x1 = _points[i - 1].x;
							y1 = _points[i - 1].y;
							x2 = _points[i].x;
							y2 = _points[i].y;
							radians = Math.atan2(y2 - y1,x2 - x1);
							degrees = radians / (Math.PI / 180);
							positiveDegrees = degrees;
							if (positiveDegrees < 0) positiveDegrees = degrees * -1;
							
							//Check if edge or bottom, don't draw this
							if (positiveDegrees > 130 ||
							   !((positiveDegrees >= 0 && positiveDegrees <= 60) || positiveDegrees == 180))
							{
								//Clear line style
								_shape.graphics.lineStyle(0);
							}
							else
							{
								//Corners?
								if (leftCornerTexture != null &&
									rightCornerTexture != null &&
									_points[i].control == null)
								{
									//Calculate the length of the line
									var length:Number = Point.distance(new Point(x1, y1), new Point(x2, y2));
									
									//Calculate left corner start and end points
									var leftCornerOffset:Point = Point.interpolate(new Point(x1,y1), new Point(x2,y2), 1-(24/length));
									var leftCornerStart:Point = new Point(leftCornerOffset.x - x1, leftCornerOffset.y - y1);
									var leftCornerEnd:Point = Point.interpolate(new Point(x1,y1), new Point(x2,y2), 1-(48/length));
									
									//Left corner
									_shape.graphics.lineTexture(128, leftCornerTexture);
									_shape.graphics.moveTo(x1-leftCornerStart.x, y1-leftCornerStart.y);
									_shape.graphics.lineTo(leftCornerEnd.x, leftCornerEnd.y);
									
									//Calculate right corner start and end points
									var rightCornerStart:Point = Point.interpolate(new Point(x1,y1), new Point(x2,y2), (40/length));
									var rightCornerOffset:Point = new Point(rightCornerStart.x - x2, rightCornerStart.y - y2);
									var rightCornerEnd:Point = new Point(x2-rightCornerOffset.x/2, y2-rightCornerOffset.y/2);
									
									//Right corner
									_shape.graphics.lineTexture(128, rightCornerTexture);
									_shape.graphics.moveTo(rightCornerStart.x, rightCornerStart.y);
									_shape.graphics.lineTo(rightCornerEnd.x, rightCornerEnd.y);
									
									//Top
									_shape.graphics.lineTexture(128, topTexture); //Top
									_shape.graphics.moveTo(leftCornerOffset.x, leftCornerOffset.y);
									_shape.graphics.lineTo(rightCornerStart.x, rightCornerStart.y);
									_shape.graphics.moveTo(points[i].x, points[i].y);
									continue;
								}
								
								if (topTexture != null)
								{
									_shape.graphics.lineTexture(128, topTexture); //Top
								}
								else if(edgeTexture != null)
								{
									_shape.graphics.lineTexture(128, edgeTexture); //No top, default to edge
								}
							}
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
			}
			
			//Set cull bounds
			if (!isLine)
			{
				cullBounds.setTo(0, 0, width, height + 16);
			}
			else
			{
				cullBounds.setTo(0, 0, width, 64);
			}
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
			
			//Create a physics shape for the collision data
			if (_physicsShape == null) _physicsShape = new flash.display.Shape();
			
			//Create a physics body
			_physicsBody = new Body(BodyType.STATIC, new Vec2(x, y));
			
			//Begin drawing the physics shape
			if(!isLine) _physicsShape.graphics.beginFill(0x0, 1);
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
		
		override public function set rotation(value:Number):void 
		{
			//Don't allow rotation
		}
		
		override public function set z(value:Number):void 
		{
			if (_params.physics)
			{
				super.z = value;
			}
			else
			{
				_forceZ(value);
			}
		}
		
		public function get points():Array
		{
			return _points;
		}
		
		public function set texture(value:String):void
		{
			_params.texture = value;
			dispatchEventWith(Oni.UPDATE_DATA);
		}
		
		public function get texture():String
		{
			return _params.texture;
		}
		
		public function get isLine():Boolean
		{
			return !(_points[0].x == _points[_points.length - 1].x && _points[0].y == _points[_points.length - 1].y);
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			_shape.render(support, parentAlpha);
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