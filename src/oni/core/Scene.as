package oni.core 
{
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import nape.geom.Mat23;
	import nape.util.ShapeDebug;
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
	import starling.display.Graphics;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Shape;
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
	public class Scene extends Quad
	{
		/**
		 * Whether we should depth sort the scene or not
		 */
		public var shouldDepthSort:Boolean;
		
		public var lighting:Boolean;
		
		/**
		 * The scene's diffuse map
		 */
		protected var _diffuseMap:DisplayMap;
		
		/**
		 * The scene's light map
		 */
		protected var _lightMap:LightMap;
		
		/**
		 * A matrix used to render the scene
		 */
		private var _renderMatrix:Matrix;
		
		private var _entities:EntityManager;
		
		private var _debugView:ShapeDebug;
		
		private var _renderMode:uint = RenderMode.NORMAL;
		
		public function Scene(entities:EntityManager, lighting:Boolean = true)
		{
			//Super
			super(Platform.STAGE_WIDTH*2, Platform.STAGE_HEIGHT*2, 0);
			
			//Set variables
			this.lighting = lighting;
			_entities = entities;
			
			//Create a debug view
			_debugView = new ShapeDebug(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT, 0x0);
			_debugView.display.scaleX = Starling.current.nativeStage.stageWidth / Platform.STAGE_WIDTH;
			_debugView.display.scaleY = Starling.current.nativeStage.stageHeight / Platform.STAGE_HEIGHT;
			_debugView.display.visible = false;
			Starling.current.nativeStage.addChild(_debugView.display);
			
			//Create a diffuse map
			_diffuseMap = new DisplayMap();
			
			//Create render matrices
			_renderMatrix = new Matrix();
			
			//Create a composite filter
			this.filter = new CompositeFilter();
				
			//Create a render texture for the diffuse map
			(this.filter as CompositeFilter).diffuseTexture = new RenderTexture(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT, false);
			
			//Do we support lighting?
			if (lighting)
			{
				//Set light quality
				var lightQuality:Number = 1;
				if (Platform.isMobile() || !Platform.supportsAdvancedFeatures()) //Scale down on mobile devices
				{
					//lightQuality = 0.5;
				}
				
				//Create a light map
				_lightMap = new LightMap();
				_lightMap.addEventListener(Oni.UPDATE_DATA, _onAmbientLightUpdated);
					
				//Create a render texture for the light map
				(this.filter as CompositeFilter).lightTexture = new RenderTexture(Platform.STAGE_WIDTH * lightQuality, Platform.STAGE_HEIGHT * lightQuality, false);
			}
			else
			{
				(this.filter as CompositeFilter).lightTexture = Texture.fromColor(1, 1, 0xFFFFFF);
			}
			
			//Untouchable
			this.touchable = false;
			
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
			
			//Listen for entity added and removed
			entities.addEventListener(Oni.ENTITY_ADDED, _entityAdded);
			entities.addEventListener(Oni.ENTITY_REMOVED, _entityRemoved);
		}
		
		/**
		 * Called when an entity needs to be added to the scene
		 * @param	e
		 */
		private function _entityAdded(e:Event):void
		{
			//Add to scene
			addEntity(e.data.entity);
		}
		
		/**
		 * Called when an entity needs to be removed from the scene
		 * @param	e
		 */
		private function _entityRemoved(e:Event):void
		{
			//Remove from scene
			removeEntity(e.data.entity);
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
					
					//Calculate y difference
					var ydif:Number = aZ - bZ;
					if (ydif == 0) ydif = -1;
					return ydif;
				});
			}
			
			//Render mode
			if (renderMode == RenderMode.NORMAL || renderMode == RenderMode.DEBUG || renderMode == RenderMode.DEBUG_ONLY)
			{
				//Debug only?
				if (renderMode != RenderMode.DEBUG_ONLY)
				{
					//Check if we're using a filter or not
					if (this.filter != null)
					{
						//Draw the light map
						if (lighting)
						{
							((this.filter as CompositeFilter).lightTexture as RenderTexture).clear();
							((this.filter as CompositeFilter).lightTexture as RenderTexture).draw(_lightMap, _renderMatrix);
						}
						
						//Draw diffuse map
						((this.filter as CompositeFilter).diffuseTexture as RenderTexture).clear();
						((this.filter as CompositeFilter).diffuseTexture as RenderTexture).draw(_diffuseMap, _renderMatrix);
					}
					
					//Render
					super.render(support, parentAlpha);
				}
				
				//Should we render the debug view also?
				if (renderMode == RenderMode.DEBUG || renderMode == RenderMode.DEBUG_ONLY)
				{
					//Clear debug view and draw
					_debugView.clear();
					_debugView.draw(_entities.space);
					
					//Create an event to dispatch
					var e:Event = new Event(Oni.DEBUG_DRAW, false, { debug: _debugView } );
					
					//Dispatch to diffuse and light map
					_diffuseMap.dispatchEvent(e);
					_lightMap.dispatchEvent(e);
					
					//Flush to screen
					_debugView.flush();
				}
			}
			else
			{
				((this.filter as CompositeFilter).lightTexture as RenderTexture).clear();
				((this.filter as CompositeFilter).diffuseTexture as RenderTexture).clear();
			}
		}
		
		private function _updatePosition(e:Event):void
		{
			//Calculate the display matrix
			_renderMatrix.identity();
			_renderMatrix.translate(-e.data.x, -e.data.y);
			_renderMatrix.scale(e.data.z, e.data.z);
			_renderMatrix.translate(Platform.STAGE_WIDTH / 2, Platform.STAGE_HEIGHT / 2);
			
			//Position debug view
			_debugView.transform.setAs(_renderMatrix.a, _renderMatrix.b, _renderMatrix.c, _renderMatrix.d, _renderMatrix.tx, _renderMatrix.ty);
			
			//Set transformation matrices for different render modes
			if(renderMode == RenderMode.LIGHTING && lighting)
			{
				_lightMap.transformationMatrix = _renderMatrix;
			}
			else if(renderMode == RenderMode.DIFFUSE)
			{
				_diffuseMap.transformationMatrix = _renderMatrix;
			}
			
			//Dispatch position update
			if (_diffuseMap != null) _diffuseMap.dispatchEvent(e);
			if (_lightMap != null) _lightMap.dispatchEvent(e);
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
		
		public function set renderMode(mode:uint):void
		{
			if (_renderMode != mode)
			{
				//Set render mode
				_renderMode = mode;
				
				//Debug display
				_debugView.display.visible = (_renderMode == RenderMode.DEBUG || _renderMode == RenderMode.DEBUG_ONLY);
				
				if (_renderMode == RenderMode.LIGHTING && !parent.contains(_lightMap))
				{
					if(parent.contains(_diffuseMap)) parent.removeChild(_diffuseMap);
					parent.addChild(_lightMap);
				}
				else if (_renderMode == RenderMode.DIFFUSE && !parent.contains(_diffuseMap))
				{
					if(parent.contains(_lightMap)) parent.removeChild(_lightMap);
					parent.addChild(_diffuseMap);
				}
				else 
				{
					if(parent.contains(_diffuseMap)) parent.removeChild(_diffuseMap);
					if (parent.contains(_lightMap)) parent.removeChild(_lightMap);
					
					//Clear textures for debug only view
					if (_renderMode == RenderMode.DEBUG_ONLY)
					{
						((this.filter as CompositeFilter).lightTexture as RenderTexture).clear();
						((this.filter as CompositeFilter).diffuseTexture as RenderTexture).clear();
					}
				}
			}
		}
		
		public function get renderMode():uint
		{
			return _renderMode;
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
					 lighting: lighting,
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