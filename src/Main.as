package  
{
	import oni.Oni;
	import oni.utils.Backend;
	import oni.utils.Platform;
    import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
	
	/**
	 * Main startup class, you should extend this and set that class to your document if you don't know what you're doing.
	 * @author Sam Hellawell
	 */
	public class Main extends Sprite
	{
		private var _starling:Starling;
		
		public function Main() 
		{
			//Setup the stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//Setup starling
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = Platform.isAndroid();
			
			//Get the stage dimensions
			var stageWidth:int = stage.stageWidth;
			var stageHeight:int = stage.stageHeight;
			
			//Check if mobile and set screen dimensions
			if (Platform.isMobile())
			{
				stageWidth = stage.fullScreenWidth;
				stageHeight = stage.fullScreenHeight;
			}
			
			//Check if we're an iPad, if so, set minimum stage dimensions
			if (stageWidth == 1024 || stageWidth == 2048)
			{
				Platform.STAGE_WIDTH = 1024;
				Platform.STAGE_HEIGHT = 768;
			}
			
			//Set viewport
			var viewport:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT), 
													   new Rectangle(0, 0, stageWidth, stageHeight), 
													   ScaleMode.SHOW_ALL);
													  
			//Create instance
			_starling = new Starling(Oni, stage, viewport);
			_starling.antiAliasing = 1;
            _starling.simulateMultitouch = false;
			_starling.showStats = Platform.debugEnabled;
            _starling.enableErrorChecking = Platform.debugEnabled;
			_starling.stage.stageWidth  = Platform.STAGE_WIDTH;
			_starling.stage.stageHeight = Platform.STAGE_HEIGHT;
			
			//test
			_starling.showStats = true;
			
			//Start!
			_starling.start();
			
			//Listen for application activate
            NativeApplication.nativeApplication.addEventListener(
                Event.ACTIVATE, function (e:*):void { _starling.start(); });
            
			//Listen for application deactivate
            NativeApplication.nativeApplication.addEventListener(
                Event.DEACTIVATE, function (e:*):void { _starling.stop(true); });
		}
	}
	
}