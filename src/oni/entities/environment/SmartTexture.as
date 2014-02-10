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
			
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _onUpdateData);
			
			//Update data
			dispatchEventWith(Oni.UPDATE_DATA, false, params);
			
			touchable = false;
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
				if (e.data.collision) _createBody();
			}
			
			//Get the textiures
			var backgroundTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_background");
			var floorTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_floor");
			var wallTexture:Texture = AssetManager.getTexture("smarttexture_" + _params.texture + "_wall");
			
			//Clear shape graphics
			_shape.graphics.clear();
			
			//Fill with the background texture
			if (backgroundTexture != null) 
			{
				_shape.graphics.beginTextureFill(backgroundTexture);
			}
			
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
					
					//Check if we have a wall texture
					if (wallTexture != null && !((positiveDegrees >= 0 && positiveDegrees <= 60) || positiveDegrees == 180))
					{
						_shape.graphics.lineTexture(128, wallTexture); //Walls
					}
					else
					{
						_shape.graphics.lineTexture(128, floorTexture); //Floors
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
			
			//Draw debug points
			_shape.graphics.lineStyle(1, 0xCCCCCC, 0);
			_shape.graphics.beginFill(0xFFFFFF, 0);
			for (i = 0; i < _points.length; i++)
			{
				_shape.graphics.drawCircle(_points[i].x, _points[i].y, 10);
				
				if (_points[i].control != null)
				{
					_shape.graphics.drawCircle(_points[i].control.x, _points[i].control.y, 5);
				}
			}
			_shape.graphics.endFill();
			
			//Set cull bounds
			cullBounds.setTo(0, 0, width, height+16);
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
			if (_physicsShape == null)
			{
				_physicsShape = new flash.display.Shape();
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