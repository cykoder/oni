package oni.sound
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import oni.assets.AssetManager;
	
	/*
		USE init, then just call play(), toggleMute() and setMute() as needed, finally cleanUp();
	*/
	
	public class MSFX
	{
		protected var _transform:SoundTransform = new SoundTransform();
		protected var _lastsound:IPlayable = null; //assigned when creating
		protected var _muted:Boolean = false;
		protected static var _instance:MSFX = null;

		// =================== FUNCTIONS TO BE CALLED ===================== //
		public static function init():void
		{
			getInstance();
		}
		
		public static function play(sound:String):void
		{			
			if (_instance)
				_instance.playSound(AssetManager.getSound(sound));
		}

		public static function toggleMute():Boolean
		{
			if (_instance)
				return _instance.toggleMute();
			
			return false;
		}

		public static function setMute(value:Boolean):void
		{
			if (_instance)
				_instance._muted = value;
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
		protected static function getInstance():MSFX
		{
			if (_instance == null) 
				_instance = new MSFX();
			
			return _instance;
		}
		
		protected function playSound(sound:IPlayable):void
		{
			if (_muted)
			{
				_lastsound = sound;
				return;
			}
			
			playInternal(sound);
			_lastsound = sound;
		}
		
		protected function playInternal(sound:IPlayable):void
		{
			sound.play();
		}
				
		protected function cleanUpInternal():void
		{
			_lastsound = null;
			_transform = null;
		}
				
		private function toggleMute():Boolean
		{
			_muted = !_muted;
			return _muted;
		}
				
		public function MSFX()
		{
		}
	}
}