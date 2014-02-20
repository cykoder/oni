package oni.editor.ui 
{
	import oni.Oni;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Slider extends Sprite
	{
		private var _min:Number;
		
		private var _max:Number;
		
		private var _shape:Shape;
		
		private var _textfield:TextField;
		
		private var _value:Number;
		
		public function Slider(min:Number, max:Number, val:Number=-1) 
		{
			//Set min/max
			_min = min;
			_max = max;
			
			//Create a shape
			_shape = new Shape();
			addChild(_shape);
			
			//Create a textfield
			_textfield = new TextField(40, 16, min.toString(), "Verdana", 10, 0xFFFFFF);
			_textfield.hAlign = HAlign.CENTER;
			_textfield.x = 100;
			addChild(_textfield);
			
			//Listen for touch
			addEventListener(TouchEvent.TOUCH, _onTouch);
			
			//Set value to minimum
			if (val == -1)
			{
				value = min;
			}
			else
			{
				value = val;
			}
		}
		
		private function _redraw():void
		{
			//Clear
			_shape.graphics.clear();
			
			//Draw base rect
			_shape.graphics.lineStyle(1, 0x333333, 1);
			_shape.graphics.beginFill(0x242424);
			_shape.graphics.drawRect(0,0,100,16);
			_shape.graphics.endFill();
			
			//Draw box
			_shape.graphics.beginFill(0xFFFFFF, 0.5);
			_shape.graphics.drawRect(Math.round((_value - _min)/(_max - _min) * 100), 1, 1, 14);
			_shape.graphics.endFill();
		}
		
		public function get value():Number
		{
			return _value;
		}
		
		public function set value(val:Number):void
		{
			//Round to 2 decimal places
			val = Math.round(val * Math.pow(10, 2)) / Math.pow(10, 2);
			
			//Limit
			if (val < _min) val = _min;
			if (val > _max) val = _max;
			
			//Check if different
			if (val != value)
			{
				//Set text
				_textfield.text = val.toString();
				
				//Set value
				_value = val;
			
				//Dispatch event
				dispatchEventWith(Oni.UPDATE_DATA, false, { name: name, value: value });
				
				//Redraw
				_redraw();
			}
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Get touch
			var touch:Touch = e.getTouch(_shape);
			
			//Check if touch exists
			if (touch != null && (touch.phase == TouchPhase.BEGAN || touch.phase == TouchPhase.MOVED))
			{
				value = (touch.getLocation(_shape).x / 100) * _max;
			}
		}
		
	}

}