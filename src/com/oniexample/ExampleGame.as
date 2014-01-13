package com.oniexample 
{
	import com.oniexample.examples.OtherLights;
	import com.oniexample.examples.PointLights;
	import com.oniexample.examples.TestScene;
	import com.oniexample.examples.FluidScene;
	import oni.Oni;
	import oni.utils.Backend;
	import starling.events.Event;
	
	/**
	 * Our example game, hurray!
	 * @author Sam Hellawell
	 */
	public class ExampleGame extends Oni
	{
		
		public function ExampleGame() 
		{
			//Log this
			Backend.log("We're running ExampleGame!");
			
			//Listen for init
			addEventListener(Oni.INIT, _init);
		}
		
		/**
		 * Called when we should initialise 
		 * @param	e
		 */
		private function _init(e:Event):void
		{
			//Add test scene
			//screens.add(new PointLights(this));
			//screens.add(new OtherLights(this));
			screens.add(new FluidScene(this));
			
			//screenManager.changeTo(ScreenManager.SCREEN_GAME);
		}
		
	}

}