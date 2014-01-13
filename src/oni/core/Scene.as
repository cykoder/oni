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
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
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
		 * The scene's hue, values range between -1 and 1
		 */
		protected var _hue:Number;
		
		/**
		 * The scene's saturation, values range between -1 and 1
		 */
		protected var _saturation:Number;
		
		/**
		 * The scene's brightness, values range between -1 and 1
		 */
		protected var _brightness:Number;
		
		/**
		 * The scene's contrast, values range between -1 and 1
		 */
		protected var _contrast:Number;
		
		/**
		 * The scene's color filter
		 */
		private var _colorFilter:ColorMatrixFilter;
		
		public function Scene(lighting:Boolean=true, effects:Boolean=true)
		{
			//Create a diffuse map
			_diffuseMap = new DisplayMap();
			addChild(_diffuseMap);
			
			//Is lighting enabled?
			if (lighting)
			{
				//Create a light map
				_lightMap = new LightMap();
				addChild(_lightMap);
			}
			
			//Create a color filter
			_colorFilter = new ColorMatrixFilter();
			if (effects) filter = _colorFilter;
			
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
		}
		
		public function get effectsEnabled():Boolean
		{
			return filter != null;
		}
		
		public function set effectsEnabled(value:Boolean):void
		{
			//Check to apply filter or not
			if (filter == null)
			{
				filter = _colorFilter;
			}
			else
			{
				filter = null;
			}
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
			
			//Render
			super.render(support, parentAlpha);
		}
		
		private function _updatePosition(e:Event):void
		{
			//Position maps
			_diffuseMap.reposition(e.data.x, e.data.y, e.data.z);
			if(_lightMap != null) _lightMap.reposition(e.data.x, e.data.y, e.data.z);
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
		
		public function serialize(entities:EntityManager, components:ComponentManager):Object
		{
			return { lighting: lighting != null,
					 physicsEnabled: entities.physicsEnabled,
					 gravity: entities.gravity,
					 entities: entities.serialize(),
					 components: components.serialize() };
		}
		
		/**
		 * The scene's brightness, values range between -1 and 1
		 */
		public function get brightness():Number
		{
			return _brightness;
		}
		
		/**
		 * The scene's brightness, values range between -1 and 1
		 */
		public function set brightness(value:Number):void
		{
			//Only adjust if different
			if (value != _brightness)
			{
				//Get difference
				var diff:Number = value - _brightness;
				if (isNaN(diff)) diff = value;
				
				//Set value
				_brightness = value;
				
				//Adjust
				_colorFilter.adjustBrightness(diff);
			}
		}
		
		/**
		 * The scene's contrast, values range between -1 and 1
		 */
		public function get contrast():Number
		{
			return _contrast;
		}
		
		/**
		 * The scene's contrast, values range between -1 and 1
		 */
		public function set contrast(value:Number):void
		{
			//Only adjust if different
			if (value != _contrast)
			{
				//Get difference
				var diff:Number = value - _contrast;
				if (isNaN(diff)) diff = value;
				
				//Set value
				_contrast = value;
				
				//Adjust
				_colorFilter.adjustBrightness(diff);
			}
		}
		
		/**
		 * The scene's saturation, values range between -1 and 1
		 */
		public function get saturation():Number
		{
			return _saturation;
		}
		
		/**
		 * The scene's saturation, values range between -1 and 1
		 */
		public function set saturation(value:Number):void
		{
			//Only adjust if different
			if (value != _saturation)
			{
				//Get difference
				var diff:Number = value - _saturation;
				if (isNaN(diff)) diff = value;
				
				//Set value
				_saturation = value;
				
				//Adjust
				_colorFilter.adjustSaturation(diff);
			}
		}
		
		/**
		 * The scene's hue, values range between -1 and 1
		 */
		public function get hue():Number
		{
			return _hue;
		}
		
		/**
		 * The scene's hue, values range between -1 and 1
		 */
		public function set hue(value:Number):void
		{
			//Only adjust if different
			if (value != _hue)
			{
				//Get difference
				var diff:Number = value - _hue;
				if (isNaN(diff)) diff = value;
				
				//Set value
				_hue = value;
				
				//Adjust
				_colorFilter.adjustHue(diff);
			}
		}
		
		public static function deserialize(data:Object, entities:EntityManager, components:ComponentManager):Scene
		{
			//Create a scene
			var scene:Scene = new Scene(data.lighting);
			
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