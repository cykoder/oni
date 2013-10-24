package oni.rendering 
{
	import flash.geom.Point;
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import oni.entities.lights.Light;
	import oni.Oni;
	import oni.utils.Platform;
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
	public class SceneRenderer extends DisplayObjectContainer
	{
		public var camera:Camera;
		
		public var shouldDepthSort:Boolean;
		
		private var _diffuseMap:Map;
		
		private var _lightMap:LightMap;
		
		private var _background:Shape;
		
		public function SceneRenderer(skybg:String="midday", lighting:Boolean=true, ambientColour:uint=0x000000, ambientIntensity:Number=1) 
		{
			//Create a diffuse map
			_diffuseMap = new Map(false);
			
			//Create a light map
			//TODO: Don't initialise the lightmap here?
			_lightMap = new LightMap(ambientColour, ambientIntensity);
			
			//Set the background
			background = skybg;
			
			//Add maps
			_addChild(_diffuseMap);
			if(lighting) _addChild(_lightMap);
			
			//Create a camera
			camera = new Camera();
			camera.addEventListener(Oni.UPDATE_POSITION, _updatePosition);
			
			//Listen for update
			addEventListener(Oni.UPDATE, _update);
			
			//Debug
			addEventListener(TouchEvent.TOUCH, _touch);
		}
		
		private var _lastTouchPosition:Point = new Point();
		private var _touchDifference:Point = new Point();
		private function _touch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this);
			if (touch != null)
			{
				if (touch.phase == TouchPhase.BEGAN ||touch.phase == TouchPhase.MOVED)
				{
					_lastTouchPosition.setTo(stage.stageWidth / 2, stage.stageHeight / 2);
					_touchDifference.setTo(((_lastTouchPosition.x - touch.globalX) < 0) ? 1 : -1, ((_lastTouchPosition.y - touch.globalY) < 0) ? 1 : -1);
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					_touchDifference.setTo(0,0);
				}
			}
		}
		
		public function set background(bg:String):void
		{
			//Check if background is already set
			if (_background == null)
			{
				//Create background and add to display list
				_background = new Shape();
				_background.blendMode = BlendMode.NONE;
				super.addChildAt(_background, 0);
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
		
		private function _update(e:Event):void
		{
			//Move camera by difference
			camera.x += _touchDifference.x*50;
			camera.y += _touchDifference.y*50;
			
			//Depth sort
			if (shouldDepthSort)
			{
				shouldDepthSort = false;
				_diffuseMap.sortChildren(Entity.depthSort);
			}
			
			//Update camera
			camera.dispatchEvent(e);
		}
		
		private function _updatePosition(e:Event):void
		{
			//Scale
			_diffuseMap.scaleX = _diffuseMap.scaleY = _lightMap.scaleX = _lightMap.scaleY = e.data.z;
			
			//Position maps
			_diffuseMap.reposition(e.data.x, e.data.y, e.data.z);
			_lightMap.reposition(e.data.x, e.data.y, e.data.z);
		}
		
		public function getContainer(child:DisplayObject):DisplayObjectContainer
		{
			//Check if light
			if (child is Light) return _lightMap;
			return _diffuseMap;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			if (getContainer(child).contains(child)) return child;
			shouldDepthSort = true;
			return getContainer(child).addChild(child);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{
			if (getContainer(child).contains(child)) return child;
			shouldDepthSort = true;
			return getContainer(child).addChildAt(child, index);
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean = true):DisplayObject 
		{
			if (!getContainer(child).contains(child)) return child;
			return getContainer(child).removeChild(child, dispose);
		}
		
		private function _addChild(child:DisplayObject):DisplayObject 
		{
			return super.addChildAt(child, numChildren);
		}
		
		private function _removeChild(child:DisplayObject, dispose:Boolean = true):DisplayObject 
		{
			return super.removeChildAt(getChildIndex(child), dispose);
		}
		
	}

}