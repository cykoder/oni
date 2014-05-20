package oni.components.input 
{
	import flash.geom.Point;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PlatformerController extends EventDispatcher
	{
		private static const _swipeSensitivity:Number = 25;
		
		public var enabled:Boolean = true;
		
		private var _stage:Stage;
		
		private var _canJump:Boolean = true;
		
		private var _lastMovementDown:String;
		
		public function PlatformerController(_oni:Oni) 
		{
			//Set stage
			_stage = _oni.stage;
			
			//Check control type
			if (!Platform.isMobile())
			{
				//Listen for keyboard input
				_stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			}
			else
			{
				//Listen for touch input
				_stage.addEventListener(TouchEvent.TOUCH, _onTouch);
			}
		}
		
		private function _onKeyUp(e:KeyboardEvent):void
		{
			//Check input map against keycode
			if (enabled && Input.MAP[e.keyCode] != null)
			{
				switch(Input.MAP[e.keyCode])
				{
					case Input.RIGHT:
					case Input.LEFT:
						if(_lastMovementDown == Input.MAP[e.keyCode]) dispatchEventWith(Input.CLEAR);
						break;
						
					default: //Dispatch event
						dispatchEventWith(Input.MAP[e.keyCode], false, { state: "up" });
						break;
				}
			}
		}
		
		private function _onKeyDown(e:KeyboardEvent):void
		{
			//Check input map against keycode
			if (enabled && Input.MAP[e.keyCode] != null)
			{
				switch(Input.MAP[e.keyCode])
				{
					case Input.RIGHT:
					case Input.LEFT:
						_lastMovementDown = Input.MAP[e.keyCode];
						dispatchEventWith(Input.MAP[e.keyCode], false, { state: "down" } );
					break;
						
					default: //Dispatch event
						dispatchEventWith(Input.MAP[e.keyCode], false, { state: "down" });
						break;
				}
			}
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Get touches
			var touches:Vector.<Touch> = e.getTouches(_stage);
			if (enabled && touches != null && touches.length <= 2)
			{
				//Check if all touches have ended
				if (touches.length == 0 || touches.length == 1 && touches[0].phase == TouchPhase.ENDED)
				{
					dispatchEventWith(Input.CLEAR);
					_canJump = true;
				}
				else
				{
					for (var i:uint = 0; i < touches.length; i++)
					{
						//Check if its a moved event
						if (touches[i].phase == TouchPhase.MOVED)
						{
							//Get touch difference
							var diff:Point = touches[i].getMovement(_stage);
							if (diff.y <= -_swipeSensitivity) //Swipe up, jump!
							{
								//Dispatch jump event
								dispatchEventWith(Input.JUMP);
								_canJump = false;
							}
							
							//Dispatch move event
							if (diff.x < 0)
							{
								dispatchEventWith(Input.LEFT, false, { velocity: diff.x });
							}
							else
							{
								dispatchEventWith(Input.RIGHT, false, { velocity: diff.x });
							}
						}
						else if (touches[i].phase == TouchPhase.ENDED)
						{
							_canJump = true;
						}
						
						//Tap to jump
						if (touches[i].tapCount == 2)
						{
							dispatchEventWith(Input.JUMP);
							_canJump = false;
						}
					}
				}
			}
		}
		
	}

}