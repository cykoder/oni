package oni.rendering 
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
		public var smoothing:Number = 0.25;
		
		private var _x:int, _holdX:int;
		
		private var _y:int, _holdY:int;
		
		private var _z:Number;
		
		public function Camera() 
		{
			//Initialise variables
			_x = _y = 0;
			_z = 1.25;
			_holdX = _holdY = -1;
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
		}
		
		private function _onUpdate(e:Event):void
		{
			//Check if we should move
			if (_holdX != -1 || _holdY != -1)
			{
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
				
				//Dispatch event
				dispatchEventWith(Oni.UPDATE_POSITION, false, { x:_x, y:_y, z:z } );
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
			_z = value;
		}
		
	}

}