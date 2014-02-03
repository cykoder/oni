package oni.components 
{
	import oni.Oni;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Camera extends EventDispatcher
	{
		/**
		 * The start shake event
		 */
		public static const START_SHAKE:String = "shakecamera";
		
		/**
		 * The stop shake event
		 */
		public static const STOP_SHAKE:String = "endshakecamera";
		
		public var smoothing:Number = 0.25;
		
		public var limit:Boolean = true;
		
		/**
		 * The intensity of the shake
		 */
		private var _shakeIntensity:Number;
		
		/**
		 * The decay of the shake
		 */
		private var _shakeDecay:Number;
		
		private var _x:int, _holdX:int;
		
		private var _y:int, _holdY:int;
		
		private var _z:Number, _holdZ:Number;
		
		public function Camera() 
		{
			//Initialise variables
			_x = _y = 0;
			_z = 1;
			_holdX = _holdY = _holdZ = -1;
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
			
			//Listen for shake events
			addEventListener(Camera.START_SHAKE, _beginShake);
			addEventListener(Camera.STOP_SHAKE, _stopShake);
		}
		
		private function _onUpdate(e:Event):void
		{
			//Check if we should move
			if (_holdX != -1 || _holdY != -1 || _holdZ != -1 || _shakeIntensity > 0)
			{
				//Linear interpolate X
				if (_holdX != -1)
				{
					//Set X
					_x = Math.ceil(((1 - smoothing) * x) + (smoothing * _holdX));
					
					//Check if we should reset
					if (_x == _holdX) _holdX = -1;
					
					//Limit
					if (limit && _x < 0) _x = 0;
				}
				
				//Linear interpolate Y
				if (_holdY != -1)
				{
					//Set Y
					_y = Math.ceil(((1 - smoothing) * y) + (smoothing * _holdY));
					
					//Check if we should reset
					if (_y == _holdY) _holdY = -1;
					
					//Limit
					if (limit && _y < 0) _y = 0;
				}
				
				//Linear interpolate Z
				if (_holdZ != -1)
				{
					//Set Z
					_z += (_holdZ - _z) * smoothing;
					
					//Check if we should reset
					if (_z == _holdZ) _holdZ = -1;
					
					//Limit
					if (_z < 0.25) _z = 0.25;
				}
				
				//Do shake
				if (_shakeIntensity > 0)
				{
					//Decrement intensity
					_shakeIntensity -= _shakeDecay;
					
					//Have we stopped shaking?
					if (_shakeIntensity <= 0)
					{
						dispatchEventWith(Camera.STOP_SHAKE);
					}
					else
					{
						//Decrement intensity
						_shakeIntensity -= _shakeDecay;
						
						//Actually shake the container
						_x -= (Math.random() * _shakeIntensity);
						_y -= (Math.random() * _shakeIntensity);
					}
				}
				
				//Dispatch event
				dispatchEventWith(Oni.UPDATE_POSITION, false, { x:_x, y:_y, z:_z } );
			}
		}
		
		public function get x():int
		{
			return _x;
		}
		
		public function set x(value:int):void
		{
			if(value != _holdX) _holdX = value;
		}
		
		public function get y():int
		{
			return _y;
		}
		
		public function set y(value:int):void
		{
			if(value != _holdY) _holdY = value;
		}
		
		public function get z():Number
		{
			return _z;
		}
		
		public function set z(value:Number):void
		{
			if(value != _holdZ) _holdZ = value;
		}
		
		/**
		 * Called when shaking has stopped, or if we should stop shaking
		 * @param	e
		 */
		private function _stopShake(e:Event):void
		{
			//Reset variables
			_shakeIntensity = _shakeDecay = 0;
		}
		
		/**
		 * Called when the camera should start shaking
		 * @param	e
		 */
		private function _beginShake(e:Event):void
		{
			//Get intensity
			_shakeIntensity = (e.data != null) ? e.data.intensity : 10;
			
			//Get decay
			_shakeDecay = (e.data != null) ? e.data.decay : 10;
		}
		
	}

}