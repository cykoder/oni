package oni.screens 
{
	import oni.Oni;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Screen extends DisplayObjectContainer
	{
		/**
		 * A base class for all types of screens
		 * @param	name
		 */
		public function Screen(name:String) 
		{
			//Set the name
			this.name = name;
		}
		
	}

}