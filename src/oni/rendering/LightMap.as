package oni.rendering 
{
	import oni.assets.AssetManager;
	import oni.rendering.Map;
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
	public class LightMap extends Map
	{
		private var _backgroundQuad:Quad;
		
		public function LightMap(ambientColor:uint, ambientIntensity:Number, blurResolution:Number=0.5) 
		{
			//Super
			super(false);
			
			//Set untouchable
			this.touchable = false;
			
			//Create a background quad
			_backgroundQuad = new Quad(1, 1, ambientColor);
			_backgroundQuad.alpha = ambientIntensity;
			addChild(_backgroundQuad);
			
			//Listen for added to stage
			addEventListener(Event.ADDED_TO_STAGE, _addedToStage);
			
			//Set the blend mode
			//this.blendMode = "none";
			this.blendMode = "multiply";
			
			this.filter = new BlurFilter(2, 2, blurResolution);
		}
		
		private function _addedToStage(e:Event):void
		{
			//Resize background quad
			_backgroundQuad.width = stage.stageWidth;
			_backgroundQuad.height = stage.stageHeight;
			
			//Remove event listener
			removeEventListener(Event.ADDED_TO_STAGE, _addedToStage);
		}
		
		public function get ambientColor():uint
		{
			return _backgroundQuad.color;
		}
		
		public function set ambientColor(color:uint):void
		{
			_backgroundQuad.color = color;
		}
		
		public function get ambientIntensity():Number
		{
			return _backgroundQuad.alpha;
		}
		
		public function set ambientIntensity(intensity:Number):void
		{
			_backgroundQuad.alpha = intensity;
		}
		
		override public function reposition(nx:int, ny:int, nz:Number):void 
		{
			//Super
			super.reposition(nx, ny, nz);
			
			if (stage != null)
			{
				//Scale background
				_backgroundQuad.width = stage.stageWidth / nz;
				_backgroundQuad.height = stage.stageHeight / nz;
				
				//Position background
				_backgroundQuad.x = nx / nz;
				_backgroundQuad.y = ny / nz;
			}
		}
		
	}

}