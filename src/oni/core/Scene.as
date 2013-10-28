package oni.core 
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import oni.assets.AssetManager;
	import oni.components.Camera;
	import oni.entities.Entity;
	import oni.entities.lights.Light;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Scene extends DisplayObjectContainer
	{
		public var shouldDepthSort:Boolean;
		
		protected var _diffuseMap:DisplayMap;
		
		protected var _lightMap:LightMap;
		
		private var _background:Shape;
		
		public function Scene(background:String, lighting:Boolean=true) 
		{
			//Create a diffuse map
			_diffuseMap = new DisplayMap(false);
			addChild(_diffuseMap);
			
			//Is lighting enabled?
			if (lighting)
			{
				//Create a light map
				_lightMap = new LightMap();
				addChild(_lightMap);
			}
			
			//Set the background
			this.background = background;
			
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
		}
		
		public function get lighting():LightMap
		{
			return _lightMap;
		}
		
		public function set background(bg:String):void
		{
			//Check if background is already set
			if (_background == null)
			{
				//Create background and add to display list
				_background = new Shape();
				_background.blendMode = BlendMode.NONE;
				addChildAt(_background, 0);
			}
			
			//Clear background
			_background.graphics.clear();
			
			//Get the texture
			var bgTexture:Texture = AssetManager.getTexture("scene_background_" + bg);
			
			//Fill with texture
			_background.graphics.beginTextureFill(bgTexture);
			_background.graphics.drawRect(0, 0, Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT);
			_background.graphics.endFill();
			
			//Null
			bgTexture = null;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			//Depth sort
			if (shouldDepthSort)
			{
				shouldDepthSort = false;
				_diffuseMap.sortChildren(depthSort);
			}
			
			//Render
			super.render(support, parentAlpha);
		}
		
		private function _updatePosition(e:Event):void
		{
			//Scale
			_diffuseMap.scaleX = _diffuseMap.scaleY = e.data.z;
			if(_lightMap != null) _lightMap.scaleX = _lightMap.scaleY = e.data.z;
			
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
		
		/**
		 * Depth sorts two entities
		 * @param	a
		 * @param	b
		 * @return
		 */
		public static function depthSort(a:DisplayObject, b:DisplayObject):Number
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
		}
		
	}

}