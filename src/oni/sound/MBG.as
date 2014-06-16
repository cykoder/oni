package oni.sound
{
	import oni.assets.AssetManager;
	public class MBG extends MSFX
	{
		private var lastPosition:Number = NaN;
		
		// =================== FUNCTIONS TO BE CALLED ===================== //
		public static function init():void
		{
			getInstance();
		}
		
		public static function play(sound:String):void
		{
			//AssetManager.getSound(sound).loops = 999;
			
			if (_instance)
				_instance.playSound(AssetManager.getSound(sound));
		}

		//if null is passed, then last sound is fadedOut
		public static function stop(sound:MSound = null):void
		{
			if (_instance)
			{
				if (sound) sound.fadeOut();
				else if (_instance._lastsound) _instance._lastsound.fadeOut();
			}
		}
		
		public static function setMute(value:Boolean):void
		{
			if (_instance)
			{
				_instance._muted = value;
				_instance.afterMute();
			}
		}
		
		public static function toggleMute():Boolean
		{
			if (_instance)
				return _instance.toggleMute();
			return false;
		}
		
		public static function cleanUp():void
		{
			if (_instance)
			{
				_instance.cleanUpInternal();
				_instance = null;
			}
		}
		
		// =================== INTERNAL, OVERRIDE ONLY IF NEEDED ==================== //
		public function MBG()
		{
			super();
		}
		
		protected static var _instance:MBG = null;
		
		protected static function getInstance():MBG
		{
			if (_instance == null) 
				_instance = new MBG();
			
			return _instance;
		}
		
		protected function toggleMute():Boolean
		{
			_muted = !_muted;
			afterMute();
			return _muted;
		}
		
		protected override function playInternal(sound:IPlayable):void
		{	
			//always fadeout previous sound, only one BG channel music for the game
			if (_lastsound) 
				_lastsound.fadeOut();
			
			//always fadesIn only
			sound.fadeIn();
			
			lastPosition = NaN; //reseting
		}
	
		//Mute and unmute is actually pause and resume and they need not be fading..
		protected function afterMute():void
		{
			if (!_lastsound) return;
			
			if (_muted)
				lastPosition = _lastsound.stop();
			else
				_lastsound.fadeIn();
		}
	}
}