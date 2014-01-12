package oni.core 
{
	import oni.assets.AssetManager;
	import oni.core.DisplayMap;
	import oni.entities.lights.AmbientLight;
	import oni.entities.lights.Light;
	import oni.Oni;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class LightMap extends DisplayMap
	{
		private var _backgroundQuad:Quad;
		
		private var _ambientQuad:Quad;
		
		private var _ambientLight:Light;
		
		public function LightMap() 
		{
			//Create a background quad 
			_backgroundQuad = new Quad(1, 1, 0x000000);
			addChild(_backgroundQuad);
			
			//Create an ambient quad
			_ambientQuad = new Quad(1, 1, 0xFFFFFF);
			addChild(_ambientQuad);
			
			//Set the blend mode
			this.blendMode = BlendMode.MULTIPLY;
			
			//Disable touching
			this.touchable = false;
			
			//Listen for added to stage
			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}
		
		public function get enabled():Boolean
		{
			return this.visible;
		}
		
		public function set enabled(value:Boolean):void
		{
			this.visible = value;
		}
		
		public function get ambientLight():Light
		{
			return _ambientLight;
		}
		
		public function set ambientLight(light:Light):void
		{
			//Check if we have a light
			if (_ambientLight != null)
			{
				_ambientLight.removeEventListener(Oni.UPDATE_DATA, _onAmbientDataUpdated);
			}
			
			//Set actual light
			_ambientLight = light;
			
			//Listen for data update
			_ambientLight.addEventListener(Oni.UPDATE_DATA, _onAmbientDataUpdated);
			
			//Update data
			_onAmbientDataUpdated(null);
		}
		
		private function _onAmbientDataUpdated(e:Event):void
		{
			//Set colour
			_ambientQuad.color = _ambientLight.colour;
			
			//Set intensity
			_ambientQuad.alpha = _ambientLight.intensity;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			//Check if ambient light
			if (child is AmbientLight)
			{
				this.ambientLight = child as AmbientLight;
				return child;
			}
			else
			{
				//Add child
				return super.addChild(child);
			}
		}
		
		private function _addedToStage(e:Event):void
		{
			//Resize background quad
			_ambientQuad.width = _backgroundQuad.width = stage.stageWidth;
			_ambientQuad.height = _backgroundQuad.height = stage.stageHeight;
			
			//Remove event listener
			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}
		
		override public function reposition(nx:int, ny:int, nz:Number):void 
		{
			//Super
			super.reposition(nx, ny, nz);
			
			if (stage != null)
			{
				//Scale background
				_ambientQuad.width = _backgroundQuad.width = stage.stageWidth / nz;
				_ambientQuad.height = _backgroundQuad.height = stage.stageHeight / nz;
				
				//Position background
				_ambientQuad.x = _backgroundQuad.x = nx / nz;
				_ambientQuad.y = _backgroundQuad.y = ny / nz;
			}
		}
		
	}

}