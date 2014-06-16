package oni.sound
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.system.System;
	import flash.utils.Timer;
	
	public class MSound implements IPlayable
	{
		private var _transform:SoundTransform = new SoundTransform();
		private var _sound:Sound = null; //assigned when creating
		private var _lastchannel:SoundChannel;
		
		private var _starttime:Number = 0;
		private var _loops:Number = 0;
		
		private var _timer:Timer;
		
		//Returns _transform.volume, not volume, need to revisit later probably
		private var _volume:Number = 1;
		public function get volume():Number { return _transform.volume; }
		public function set volume(value:Number):void
		{
			if (_volume == value || value < 0)
				return;
			
			//retains only two decimal places
			_volume = _transform.volume = Math.round(value * 100) / 100;
			
			//should be useful for BG music, as on the fly volume change is possible
			if (_lastchannel) _lastchannel.soundTransform = _transform;
		}

		//===== constructor =====
		
		public function MSound(sound:Sound, loops:Number = 0, volume:Number = 1)
		{
			this._loops = loops;
			this._sound = sound;
			this.volume = volume;
		}
		
		public function play(customPosition:Number = NaN):SoundChannel
		{
			stopExistingTimers();
			
			_transform.volume = _volume;
			
			if (isNaN(customPosition))
				_lastchannel = _sound.play(_starttime, _loops, _transform);
			else
				_lastchannel = _sound.play(customPosition, _loops, _transform);
			
			return _lastchannel;
		}
		
		private function stopExistingTimers():void
		{
			if (_timer && _timer.running) 
			{
				_timer.stop();
				_timer = null;
			}
		}
		
		//start from volume 0 and once it reaches 1
		public function fadeIn():void
		{
			stopExistingTimers();
			
			_transform.volume = 0;
			
			if (_lastchannel) _lastchannel.stop();
			_lastchannel = _sound.play(_starttime, _loops, _transform);

			_timer = new Timer(40, 100);
			_timer.addEventListener(TimerEvent.TIMER, updateFadeIn, false, 0, true);
			_timer.start();
		}
		
		private function updateFadeIn(e:Event):void
		{
			_transform.volume += 0.05;

			if (_transform.volume >= _volume)
			{
				_transform.volume = _volume;
				_timer.stop();
			}
			
			if (_lastchannel) _lastchannel.soundTransform = _transform;
		}

		private function updateFadeOut(e:Event):void
		{
			_transform.volume -= 0.05;
			
			if (_transform.volume <= 0)
			{
				_transform.volume = 0;
				stop();
			}
			
			if (_lastchannel) _lastchannel.soundTransform = _transform;
		}		
		
		//start from 1, and once it reaches 0, stop the sound
		public function fadeOut():void
		{
			stopExistingTimers();
			
			//avoid timer, if called
			if (_transform.volume == 0) return;
			
			_timer = new Timer(40, 100);
			_timer.addEventListener(TimerEvent.TIMER, updateFadeOut, false, 0, true);
			_timer.start();
		}

		public function stop():Number
		{
			stopExistingTimers();
			
			if (_lastchannel) 
			{
				var position:Number = _lastchannel.position; 
				_lastchannel.stop();
				return position;
			}
			
			return 0;
		}
		
		public function cleanUp():void
		{
			_sound = null;
			_transform = null;
			_lastchannel = null;
			stopExistingTimers();
			_timer = null;
		}
		
		public function get loops():int
		{
			return _loops;
		}
		
		public function set loops(v:int):void
		{
			_loops = v;
		}
		
	}
}