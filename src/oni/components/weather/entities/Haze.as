package oni.components.weather.entities 
{
	import oni.entities.environment.StaticTexture;
	import oni.utils.Platform;
	import starling.display.Image;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Haze extends StaticTexture
	{
		
		public function Haze(startupParameters:Object)
		{
			//Default parameters
			startupParameters.atlas = null;
			startupParameters.texture = "weather_haze";
			startupParameters.pivot = false;
			
			//Super
			super(startupParameters);
			
			//Set dimensions
			width = Platform.STAGE_WIDTH;
			height = Platform.STAGE_HEIGHT;
			
			//Disable culling/scrolling
			scrollX = false;
			scrollY = false;
			cull = false;
			
			//Set z
			this.z = startupParameters.z;
			
			//Set intensity
			this.intensity = startupParameters.intensity;
			
			//Set color
			this.color = startupParameters.colour;
			
			//Make it never touchable
			touchable = false;
		}
		
		public function get intensity():Number
		{
			return alpha;
		}
		
		public function set intensity(value:Number):void
		{
			alpha = value;
		}
		
		public function get enabled():Boolean
		{
			return visible;
		}
		
		public function set enabled(value:Boolean):void
		{
			visible = value;
		}
		
		public function get color():uint
		{
			return (getChildAt(0) as Image).color;
		}
		
		public function set color(value:uint):void
		{
			(getChildAt(0) as Image).color = value;
		}
		
		override public function set touchable(value:Boolean):void 
		{
			//Make it never touchable
			super.touchable = false;
		}
		
	}

}