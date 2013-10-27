package oni.entities.lights 
{
    import flash.utils.getQualifiedClassName;
	import oni.entities.Entity;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.display.BlendMode;
	import starling.display.Shape;
	import starling.errors.AbstractClassError;
	import starling.filters.BlurFilter;
	
	/**
	 * A base class for light entities
	 * @author Sam Hellawell
	 */
	public class Light extends Entity
	{
		/**
		 * The colour of the light
		 */
		protected var _colour:uint;
		
		/**
		 * The intensity of the light
		 */
		protected var _intensity:Number;
		
		/**
		 * Creates a new light with specified colour, intensity and blend
		 * @param	colour
		 * @param	intensity
		 * @param	blend
		 */
		public function Light(colour:uint, intensity:Number, blendMode:String = BlendMode.ADD) 
		{
			//Not allowed to init this class directly fam
            if (Platform.debugEnabled && 
                getQualifiedClassName(this) == "oni.entities.lights::Light")
            {
                throw new AbstractClassError();
            }
			
			//Set colour
			_colour = colour;
			
			//Set intensity
			_intensity = intensity;
			
			//Set blend mode (additive or multiply, usually)
			if(blendMode != null) this.blendMode = blendMode;
		}
		
		/**
		 * The colour of the light 
		 */
		public function get colour():uint
		{
			return _colour;
		}
		
		/**
		 * The colour of the light 
		 */
		public function set colour(value:uint):void
		{
			//Set colour
			_colour = value;
			
			//Dispatch update data event
			dispatchEventWith(Oni.UPDATE_DATA);
		}
		
		/**
		 * The intensity of the light
		 */
		public function get intensity():Number
		{
			return _intensity;
		}
		
		/**
		 * The intensity of the light
		 */
		public function set intensity(value:Number):void
		{
			//Set intensity
			_intensity = value;
			
			//Dispatch update data event
			dispatchEventWith(Oni.UPDATE_DATA);
		}
		
	}

}