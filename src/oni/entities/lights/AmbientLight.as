package oni.entities.lights 
{
	import oni.Oni;
	import starling.display.Shape;
	import starling.events.Event;
	
	/**
	 * This is pretty much just a "proxy" class, for now
	 * @author Sam Hellawell
	 */
	public class AmbientLight extends Light
	{
		/**
		 * Creates an ambient light instance with the given parameters
		 * @param	colour
		 * @param	intensity
		 */
		public function AmbientLight(colour:uint, intensity:Number) 
		{
			//Super
			super(colour, intensity, null);
		}
		
	}

}