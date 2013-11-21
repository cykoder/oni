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
		
		public function Haze(z:Number, intensity:Number, color:uint)
		{
			//Super
			super(null, "weather_haze");
			
			//Set dimensions
			width = Platform.STAGE_WIDTH;
			height = Platform.STAGE_HEIGHT;
			
			//Disable culling/scrolling
			scrollX = false;
			scrollY = false;
			cull = false;
			
			//Set z
			this.z = z;
			
			//Set intensity
			this.intensity = intensity;
			
			//Set color
			this.color = color;
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
		
	}

}