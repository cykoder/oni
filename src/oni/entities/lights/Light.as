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
		 * Creates a new light with specified colour, intensity and blend
		 * @param	colour
		 * @param	intensity
		 * @param	blend
		 */
		public function Light(params:Object) 
		{
			//Default parameters
			if (params.colour != null) params.colour = uint(params.colour);
			if (params.colour == null) params.colour = 0xFFFFFF;
			if (params.intensity == null) params.intensity = 1;
			if (params.blendMode == null) params.blendMode = BlendMode.ADD;
			
			//Super
			super(params);
			
			//Not allowed to init this class directly fam
            if (Platform.debugEnabled && 
                getQualifiedClassName(this) == "oni.entities.lights::Light")
            {
                throw new AbstractClassError();
            }
			
			//Set the blend mode
			this.blendMode = params.blendMode;
		}
		
		/**
		 * The colour of the light 
		 */
		public function get colour():uint
		{
			return _params.colour;
		}
		
		/**
		 * The colour of the light 
		 */
		public function set colour(value:uint):void
		{
			//Set colour
			_params.colour = value;
			
			//Dispatch update data event
			dispatchEventWith(Oni.UPDATE_DATA);
		}
		
		/**
		 * The intensity of the light
		 */
		public function get intensity():Number
		{
			return _params.intensity;
		}
		
		/**
		 * The intensity of the light
		 */
		public function set intensity(value:Number):void
		{
			//Set intensity
			_params.intensity = value;
			
			//Dispatch update data event
			dispatchEventWith(Oni.UPDATE_DATA);
		}
		
	}

}