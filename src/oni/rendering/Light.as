package oni.rendering 
{
	import oni.entities.Entity;
	import starling.display.Shape;
	import starling.filters.BlurFilter;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Light extends Entity
	{
		protected var _color:uint;
		
		protected var _intensity:Number;
		
		public function Light(colour:uint, intensity:Number, blend:String="add") 
		{
			//Set colour
			_color = colour;
			
			//Set intensity
			_intensity = intensity;
			
			//Set blend state (additive or multiply)
			blendMode = blend;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}
		
		public function get intensity():Number
		{
			return _intensity;
		}
		
		public function set intensity(value:Number):void
		{
			_intensity = value;
		}
		
	}

}