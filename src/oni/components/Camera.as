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
		 * The camera shake event
		 */
		public static const SHAKE:String = "shake";
		
		public var smoothing:Number = 0.25;
		
		/**
		 * The intensity of the shake
		 */
		private var _shakeIntensity:Number;
		
		/**
		 * The decay of the shake
		 */
		private var _shakeDecay:Number;
		
		private var _x:int, _holdX:int, _tempX:int;
		
		private var _y:int, _holdY:int, _tempY:int;
		
		private var _z:Number, _holdZ:Number;
		
		private var _previousPosition:Object;
		
		public function Camera() 
		{
			//Initialise variables
			_x = _y = 0;
			_z = 1;
			_holdX = _holdY = _holdZ = -1;
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
			
			//Listen for shake events
			//addEventListener(Camera.SHAKE, _onShake);
		}
		
		private function _onUpdate(e:Event):void
		{
			//Check if we should move
			if (_holdX != -1 || _holdY != -1 || _holdZ != -1 || _shakeIntensity > 0)
			{
				var oldX:int = _x;
				var oldY:int = _y;
				
				//Linear interpolate X
				if (_holdX != -1)
				{
					//Set X
					_x = Math.ceil(((1 - smoothing) * x) + (smoothing * _holdX));
					
					//Check if we should reset
					if (_x == _holdX) _holdX = -1;
				}
				
				//Linear interpolate Y
				if (_holdY != -1)
				{
					//Set Y
					_y = Math.ceil(((1 - smoothing) * y) + (smoothing * _holdY));
					
					//Check if we should reset
					if (_y == _holdY) _holdY = -1;
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
						//Reset variables
						_shakeIntensity = _shakeDecay = 0;
						
						//Reset x/y
						_holdX = _tempX;
						_holdY = _tempY;
						_tempX = _tempY = 0;
					}
					else
					{
						//Decrement intensity
						_shakeIntensity /= _shakeDecay;
						
						//Actually shake the container
						_x += _randomRange(-_shakeIntensity, _shakeIntensity);
						//_y += _randomRange(-_shakeIntensity, _shakeIntensity);
					}
				}
				
				//Dispatch event
				var position:Object = { x:_x, y:_y, z:_z, diff: { x: oldX-_x, y: oldY-y } };
				dispatchEventWith(Oni.UPDATE_POSITION, false, position);
				
				_previousPosition = position;
				delete(_previousPosition.previous);
			}
		}
		
		private function _randomRange(min:Number, max:Number):Number
		{
            return (min + Math.random() * (max - min));
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
		 * Called when the camera should start shaking
		 * @param	e
		 */
		private function _onShake(e:Event):void
		{
			//Get intensity
			if (e.data.intensity != null)
			{
				if(e.data.intensity > _shakeIntensity) _shakeIntensity = e.data.intensity;
			}
			else
			{
				_shakeIntensity = 10;
			}
			
			//Get decay
			if (e.data.intensity != null)
			{
				_shakeDecay = e.data.decay;
			}
			else
			{
				_shakeDecay = 1.25;
			}
			
			//Set temporary x/y
			if (_shakeIntensity == 0)
			{
				_tempX = _x;
				_tempY = _y;
			}
		}
		
	}

}