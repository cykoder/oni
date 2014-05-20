package oni
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import oni.assets.AssetManager;
	import oni.Oni;
	import oni.utils.Backend;
	import oni.utils.Platform;
    import flash.desktop.NativeApplication;
	import flash.display.StageDisplayState;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.textures.Texture;
    import starling.utils.RectangleUtil;
    import starling.utils.ScaleMode;
	
	/**
	 * The startup class, your main/document class should extend this.
	 * @author Sam Hellawell
	 */
	public class Startup extends Sprite
	{
		/*
		 * Startup image
		 */
        [Embed(source="../../lib/textures/startup.png")]
        public static const startup:Class;
		
		/**
		 * The class we use for the engine
		 */
		public static var StartupClass:Class = Oni;
		
		/**
		 * The starling instance
		 */
		private var _starling:Starling;
		
		/**
		 * Initialiser
		 */
		public function Startup(targetWidth:int=960, targetHeight:int=540, stretch:Boolean=false, fullscreen:Boolean=false) 
		{
			//Set target dimensions
			Platform.STAGE_WIDTH = targetWidth;
			Platform.STAGE_HEIGHT = targetHeight;
			
			//Setup the stage
			stage.showDefaultContextMenu = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			if(fullscreen || Platform.isMobile()) stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			//Setup starling
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = !Platform.isIOS();
			
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
			var viewport:Rectangle;
			if (!stretch) //Bordered, keep aspect ratio
			{
				viewport = RectangleUtil.fit(new Rectangle(0, 0, Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT), 
											 new Rectangle(0, 0, stageWidth, stageHeight), 
											 ScaleMode.SHOW_ALL);
			}
			else //Stretch to fit
			{
				viewport = new Rectangle(0, 0, stageWidth, stageHeight);
			}
			
			//Create a splash bitmap
            var splash:Bitmap = new startup() as Bitmap;
            splash.x = viewport.x;
            splash.y = viewport.y;
            splash.width  = viewport.width;
            splash.height = viewport.height;
            splash.smoothing = true;
            addChild(splash);
			
			//Create a starling instance
			_starling = new Starling(StartupClass, stage, viewport);
            _starling.simulateMultitouch = !Platform.isMobile();
			_starling.stage.stageWidth  = Platform.STAGE_WIDTH;
			_starling.stage.stageHeight = Platform.STAGE_HEIGHT;
            _starling.enableErrorChecking = false;
			
			//Listen for starling ready
			_starling.addEventListener("rootCreated", function():void
            {
				//Remove the splash image
                removeChild(splash);
				splash.bitmapData.dispose();
                splash = null;
				
				//Start starling
                _starling.start();
            });
			
			//Listen for application activate
            NativeApplication.nativeApplication.addEventListener(
                Event.ACTIVATE, function (e:*):void { _starling.start(); });
            
			//Listen for application deactivate
            NativeApplication.nativeApplication.addEventListener(
                Event.DEACTIVATE, function (e:*):void { _starling.stop(true); });
		}
	}
	
}