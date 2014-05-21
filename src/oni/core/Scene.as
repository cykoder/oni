package oni.core 
{
	import flash.display.Bitmap;
	import flash.geom.Matrix;
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
	import oni.utils.OniMath;
	import oni.utils.Platform;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
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
		 * A coloured background quad
		 */
		private var _backQuad:Quad;
		
		/**
		 * A texture to render the light map to
		 */
		private var _lightRenderTexture:RenderTexture;
		
		/**
		 * The matrix for light quality scaling
		 */
		private var _lightRenderMatrix:Matrix;
		
		public function Scene(lighting:Boolean = true, background:uint = 0)
		{
			//Create a diffuse map
			_diffuseMap = new DisplayMap();
			
			//Create a render matrix
			_lightRenderMatrix = new Matrix();
			
			//Disable lighting?
			if (!Platform.supportsLighting()) lighting = false;
			
			//Set light quality
			var lightQuality:Number = 1;
			if (Platform.isMobile() || Platform.supportsAdvancedFeatures()) //Scale down on mobile devices
			{
				lightQuality = 0.5;
			}
			
 			//Add a background quad
 			if (background != 0)
 			{
				_backQuad = new Quad(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT, background);
 				_diffuseMap.addChild(_backQuad);
 			}
			
			//Create render quad
			addChild(new Quad(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT, 0x0));
			
			//Do we support lighting?
			if (lighting && Platform.supportsLighting())
			{
				//Create a light map
				_lightMap = new LightMap();
				_lightMap.addEventListener(Oni.UPDATE_DATA, _onAmbientLightUpdated);
				_lightMap.scaleX = _lightMap.scaleY = lightQuality;
					
				//Create a composite filter
				this.filter = new CompositeFilter();
					
				//Create a render texture for the diffuse map
				(this.filter as CompositeFilter).diffuseTexture = new RenderTexture(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT);
					
				//Create a render texture for the light map
				(this.filter as CompositeFilter).lightTexture = _lightRenderTexture = new RenderTexture(Platform.STAGE_WIDTH * lightQuality, Platform.STAGE_HEIGHT * lightQuality);
					
				//Set light quality
				MatrixUtil.prependScale(_lightRenderMatrix, lightQuality, lightQuality);
			}
			else //No lighting, just add diffuse map
			{
				addChild(_diffuseMap);
			}
			
			//Untouchable
			this.touchable = false;
			
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
		}
		
		private function _onAmbientLightUpdated(e:Event):void
		{
			//Update ambient colour
			if (filter != null)
			{
				//Set ambient colour
				(filter as CompositeFilter).ambientColor = OniMath.lerp32(0x0, e.data.color, e.data.intensity);
			}
		}
		
		public function get lightMap():LightMap
		{
			return _lightMap;
		}
		
		public function get diffuseMap():DisplayMap
		{
			return _diffuseMap;
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
				
			//Draw light map
			if (_lightRenderTexture != null)
			{
				_lightRenderTexture.clear();
				_lightRenderTexture.draw(_lightMap, _lightRenderMatrix);
			}
			
			//Check if we're using a filter or not
			if (this.filter != null)
			{
				//Draw diffuse map
				((this.filter as CompositeFilter).diffuseTexture as RenderTexture).clear();
				((this.filter as CompositeFilter).diffuseTexture as RenderTexture).draw(_diffuseMap, _diffuseMap.transformationMatrix);
			}
			
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
					 background: (_backQuad != null) ? _backQuad.color : 0,
					 lighting: lightMap != null,
					 physicsEnabled: entities.physicsEnabled,
					 gravity: entities.gravity,
					 entities: (entities != null) ? entities.serialize() : null,
					 components: (components != null) ? components.serialize() : null };
		}
		
		public static function deserialize(data:Object, entities:EntityManager, components:ComponentManager):Scene
		{
			//Create a scene
			var scene:Scene = new Scene(data.lighting, data.background);
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