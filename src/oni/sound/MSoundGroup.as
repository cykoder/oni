package oni.sound
{
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public class MSoundGroup implements IPlayable
	{
		public static var MODE_RANDOM:int = 0;
		public static var MODE_SEQUENTIAL:int = 1;
		
		private var _msounds:Array = null;
		private var _count:int = 0;
		private var _lastindex:int = -1;
		
		private var _mode:int;
		public function get mode():int { return _mode; }
		
		public function set mode(value:int):void
		{
			if (_mode == value)
				return;
			
			if (value == MODE_RANDOM || value == MODE_SEQUENTIAL)
				_mode = value;
		}

		public function MSoundGroup(msounds:Array = null, mode:int = 0)
		{
			if (msounds) setMSounds(msounds);
			_mode = MODE_RANDOM;
		}
		
		public function setMSounds(msounds:Array, mode:int = 0):void
		{
			_msounds = msounds;
			this.mode = mode;
			_count = msounds.length;
			_lastindex = -1;
		}
		
		public function play(customPosition:Number = NaN):SoundChannel
		{
			if (_mode == MODE_RANDOM)
				//not perfectly fair chance of all numbers, but then 100 is used and then modded with count, so its fairly random
				return (_msounds[Math.floor(Math.random() * 100) % _count] as MSound).play();
			
			else // if (_mode == MODE_SEQUENTIAL)
			{
				_lastindex ++;
				if (_lastindex == _count) _lastindex = 0;
				
				return (_msounds[_lastindex] as MSound).play(customPosition);
			}
		}
		
		public function cleanUp():void
		{
			_msounds = null;
		}
		
		//not used, as only SFX should be played with MSoundGroup
		public function stop():Number
		{
			return NaN;
		}
		
		public function fadeIn():void
		{
			//TODO - SoundGroups are intended only for SFX now, can't fade In right now
		}
		
		public function fadeOut():void
		{
			//TODO - SoundGroups are intended only for SFX now, can't fade Out right now
		}	
		
	}
}