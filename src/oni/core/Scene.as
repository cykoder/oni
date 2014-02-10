package oni.core 
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import oni.assets.AssetManager;
	import oni.components.Camera;
	import oni.components.ComponentManager;
	import oni.entities.Entity;
	import oni.entities.EntityManager;
	import oni.entities.environment.FluidBody;
	import oni.entities.lights.Light;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Scene extends DisplayObjectContainer
	{		   
		/**
		 * Whether we should depth sort the scene or not
		 */
		public var shouldDepthSort:Boolean;
		
		/**
		 * The scene's diffuse map
		 */
		protected var _diffuseMap:DisplayMap;
		
		/**
		 * The scene's light map
		 */
		protected var _lightMap:LightMap;
		
		/**
		 * The scene's color filter
		 */
		private var _colorFilter:ColorMatrixFilter;
		
		private var _backQuad:Quad;
		
		public function Scene(lighting:Boolean=true, background:uint=0)
		{
			//Create a diffuse map
			_diffuseMap = new DisplayMap();
			
			//Add a background quad
			if (background != 0)
			{
				_diffuseMap.addChild(new Quad(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT, background));
			}
			
			//Is lighting enabled?
			if (lighting)
			{
				//Create a light map
				_lightMap = new LightMap();
				
				//Create a composite filter
				this.filter = new CompositeFilter();
				
				//Create a render texture for the diffuse map
				(this.filter as CompositeFilter).diffuseMap = new RenderTexture(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT);
				
				//Create a render texture for the light map
				(this.filter as CompositeFilter).lightMap = new RenderTexture(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT);
				
				//Create a render texture for the ambient map
				(this.filter as CompositeFilter).ambientMap = new RenderTexture(1, 1);
				
				//Create background quad (this is needed so the scene gets rendered)
				_backQuad = new Quad(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT, 0x0);
				addChild(_backQuad);
				
			}
			else //No lighting, just render like normal
			{
				addChild(_diffuseMap);
			}
			
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
		}
		
		public function get lighting():LightMap
		{
			return _lightMap;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			//Depth sort
			if (shouldDepthSort)
			{
				shouldDepthSort = false;
				_diffuseMap.sortChildren(function depthSort(a:DisplayObject, b:DisplayObject):Number
				{
					//Calculate z
					var aZ:Number = 0;
					var bZ:Number = 0;
					
					//Is an entity?
					if (a is Entity) aZ = (a as Entity).z;
					if (b is Entity) bZ = (b as Entity).z;
					
					//Make sure fluid is always slightly on top
					if (a is FluidBody) aZ += 0.0001;
					if (b is FluidBody) bZ += 0.0001;
					
					//Calculate y difference
					var ydif:Number = aZ - bZ;
					if (ydif == 0) ydif = -1;
					return ydif;
				});
			}
			
			//Draw diffuse map
			((this.filter as CompositeFilter).diffuseMap as RenderTexture).clear();
			((this.filter as CompositeFilter).diffuseMap as RenderTexture).draw(_diffuseMap, _diffuseMap.transformationMatrix);
			
			//Draw light map
			((this.filter as CompositeFilter).lightMap as RenderTexture).clear();
			((this.filter as CompositeFilter).lightMap as RenderTexture).draw(_lightMap, _lightMap.transformationMatrix);
			
			//Draw light map
			((this.filter as CompositeFilter).ambientMap as RenderTexture).clear();
			((this.filter as CompositeFilter).ambientMap as RenderTexture).draw(_lightMap.ambientQuad);
			
			//Render
			super.render(support, parentAlpha);
		}
		
		private function _updatePosition(e:Event):void
		{
			//Position maps
			_diffuseMap.reposition(e.data.x, e.data.y, e.data.z);
			if (_lightMap != null) _lightMap.reposition(e.data.x, e.data.y, e.data.z);
		}
		
		public function getContainer(child:DisplayObject):DisplayObjectContainer
		{
			//Check if light
			if (child is Light) return _lightMap;
			return _diffuseMap;
		}
		
		public function addEntity(entity:Entity):void
		{
			var container:DisplayObjectContainer = getContainer(entity);
			if (container != null)
			{
				container.addChild(entity);
				container = null;
			}
			
			shouldDepthSort = true;
		}
		
		public function removeEntity(entity:Entity):void
		{
			var container:DisplayObjectContainer = getContainer(entity);
			if (container != null)
			{
				container.removeChild(entity);
				container = null;
			}
			
			shouldDepthSort = true;
		}
		
		override public function dispose():void 
		{
			//Remove event listeners
			removeEventListener(Oni.UPDATE_POSITION, _updatePosition);
			
			//Super
			super.dispose();
		}
		
		public function serialize(entities:EntityManager = null, components:ComponentManager = null):Object
		{
			return { name: name,
					 lighting: lighting != null,
					 physicsEnabled: entities.physicsEnabled,
					 gravity: entities.gravity,
					 entities: (entities != null) ? entities.serialize() : null,
					 components: (components != null) ? components.serialize() : null };
		}
		
		public static function deserialize(data:Object, entities:EntityManager, components:ComponentManager):Scene
		{
			//Create a scene
			var scene:Scene = new Scene(data.lighting);
			scene.name = data.name;
			
			//Add the entities
			var i:uint;
			for (i = 0; i < data.entities.length; i++)
			{
				scene.addEntity(entities.add(Entity.deserialize(data.entities[i])));
			}
			
			//Add the components
			for (i = 0; i < data.components.length; i++)
			{
				components.add(new (getDefinitionByName(data.components[i].className) as Class)(scene, data.components[i].params));
			}
			
			//Return
			return scene;
		}
		
	}

}