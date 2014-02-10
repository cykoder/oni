package oni.entities.scene 
{
	import oni.entities.EntityManager;
	import oni.entities.PhysicsEntity;
	import starling.display.DisplayObject;
	import flash.geom.Rectangle;
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import oni.Oni;
	import oni.utils.Backend;
	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Prop extends PhysicsEntity
	{
		/**
		 * The prop's physical data
		 */
		private var _physicsData:Object;
		
		/**
		 * Creates a new prop from with the given parameters
		 * @param	params
		 */
		public function Prop(params:Object) 
		{
			//Super
			super(params);
			
			//Load texture
			var textureAtlas:TextureAtlas = AssetManager.getTextureAtlas("scene_" + params.atlas);
			if (textureAtlas != null)
			{
				var textures:Vector.<Texture> = textureAtlas.getTextures(params.name);
				if (textures != null && textures.length > 0)
				{
					if (textures.length == 1) //Not animated
					{
						addChild(new Image(textures[0]));
					}
					else //Animated
					{
						Starling.juggler.add(addChild(new MovieClip(textures)) as MovieClip);
					}
				}
				else
				{
					Backend.log("Unable to find textures for: " + params.name + " in atlas " + params.atlas, "error");
				}
			}
			else
			{
				Backend.log("Unable to find scene atlas for: " + params.atlas, "error");
			}
			
			//Set physics data
			_physicsData = AssetManager.getJSON("physics_data")[params.name];
			
			//Check if we have physics data available, if not, disable physics
			if (params.physics && _physicsData == null) physics = false;
			
			//Set pivot
			this.pivotX = width / 2;
			this.pivotY = height / 2;
			
			//Set cull bounds
			cullBounds.setTo(0, 0, width, height);
		}
		
		/**
		 * Creates a physics body
		 */
		override protected function _createBody():void 
		{
			//Only create if we have physics data
			if (_physicsData != null)
			{
				//Create a physics body
				_physicsBody = new Body(_physicsData.dynamic ? BodyType.DYNAMIC : BodyType.STATIC, new Vec2(x, y));
				
				//Go through fixtures (shapes)
				var shapes:Array = _physicsData.fixtures;
				var material:Material;
				for (var i:uint = 0; i < shapes.length; i++)
				{
					//Update material
					if (material == null) material = new Material(shapes[i].restitution, shapes[i].friction, shapes[i].friction * 1.5, shapes[i].density);
					
					//Circle
					if (shapes[i].type == "CIRCLE")
					{
						_physicsBody.shapes.add(
							new Circle(shapes[i].radius / 2,
									   new Vec2(shapes[i].x, shapes[i].y),
									   material)
						);
					}
					else if (shapes[i].type == "POLYGON") //Polygon
					{
						var polygons:Array = shapes[i].polygons;
						var vertices:Array;
						for (var c:uint = 0; c < polygons.length; c++)
						{
							vertices = polygons[c];
							if (vertices != null && vertices.length > 0)
							{
								//Transform collision data into nape vertices
								var collisionVerts:Array = [];
								for (var j:uint = 0; j < vertices.length - 1; j++) collisionVerts.push(new Vec2(vertices[j].x/2, vertices[j].y/2));
								
								//Create a poly list and add shapes
								var polys:GeomPolyList = new GeomPoly(collisionVerts).convexDecomposition();
								polys.foreach(function (p:GeomPoly):void
								{
									_physicsBody.shapes.add(new Polygon(p, material));
								});
								polys.clear();
							}
						}
					}
				}
						
				//Set physics world
				_physicsBody.space = _space;
			}
		}
		
	}

}