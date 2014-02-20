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
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Checkbox extends Sprite
	{
		private var _textfield:TextField;
		
		private var _shape:Shape;
		
		private var _value:Boolean;
		
		public function Checkbox(value:Boolean) 
		{
			//Create a shape
			_shape = new Shape();
			_shape.x = 8;
			_shape.y = 6;
			addChild(_shape);
			
			//Create a textfield
			_textfield = new TextField(100, 14, "", "Verdana", 10, 0xFFFFFF);
			_textfield.hAlign = HAlign.LEFT;
			_textfield.vAlign = HAlign.CENTER;
			_textfield.x = 16;
			_textfield.y = -1;
			addChild(_textfield);
			
			//Set value
			this.value = value;
			
			//Listen for touch
			addEventListener(TouchEvent.TOUCH, _onTouch);
		}
		
		public function get value():Boolean
		{
			return _value;
		}
		
		public function set value(val:Boolean):void
		{
			//Set value
			_value = val;
			
			//Dispatch event
			dispatchEventWith(Oni.UPDATE_DATA, false, { name: name, value: value });
			
			//Set text
			_textfield.text = val.toString();
			
			//Draw checkbox
			_shape.graphics.clear();
			_shape.graphics.lineStyle(1, 0x333333, 1);
			_shape.graphics.beginFill(0x242424);
			_shape.graphics.drawCircle(0, 0, 6);
			_shape.graphics.endFill();
			
			//Draw selection
			if (value)
			{
				_shape.graphics.lineStyle(0);
				_shape.graphics.beginFill(0xFFFFFF, 0.5);
				_shape.graphics.drawCircle(0, 0, 5);
				_shape.graphics.endFill();
			}
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Get touch
			var touch:Touch = e.getTouch(this, TouchPhase.ENDED);
			
			//Check if touch exists
			if (touch != null)
			{
				value = !value;
			}
		}
		
	}

}