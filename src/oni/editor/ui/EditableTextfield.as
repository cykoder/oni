package oni.editor.ui 
{
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import oni.Oni;
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
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
	public class EditableTextfield extends Sprite
	{
		private var _shape:Shape;
		
		private var _textfield:TextField;
		
		private var _flashTextfield:flash.text.TextField;
		
		private var _value:String;
		
		public function EditableTextfield(value:String, fieldWidth:int=100) 
		{
			//Create a shape
			_shape = new Shape();
			_shape.graphics.lineStyle(1, 0x333333, 1);
			_shape.graphics.beginFill(0x242424);
			_shape.graphics.drawRect(0,0,fieldWidth,16);
			_shape.graphics.endFill();
			addChild(_shape);
			
			//Create a textfield
			_textfield = new TextField(fieldWidth, 16, value, "Verdana", 10, 0xFFFFFF);
			_textfield.hAlign = HAlign.LEFT;
			_textfield.vAlign = VAlign.CENTER;
			addChild(_textfield);
			
			//Create a flash text field
			_flashTextfield = new flash.text.TextField();
			_flashTextfield.defaultTextFormat = new TextFormat("Verdana", 10, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
			_flashTextfield.text = value;
			_flashTextfield.visible = false;
			_flashTextfield.width = fieldWidth;
			_flashTextfield.height = 16;
			_flashTextfield.type = TextFieldType.INPUT;
			_flashTextfield.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
			_flashTextfield.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _onFocusOut);
			_flashTextfield.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
			Starling.current.nativeOverlay.addChild(_flashTextfield);
			
			//Listen for touch
			addEventListener(TouchEvent.TOUCH, _onTouch);
		}
		
		public function get value():String
		{
			return _textfield.text;
		}
		
		public function set value(val:String):void
		{
			//Set
			_textfield.text = val;
			
			//Dispatch event
			dispatchEventWith(Oni.UPDATE_DATA, false, { name: name, value: value });
		}
		
		private function _onFocusOut(e:FocusEvent):void
		{
			//Set value
			value = _flashTextfield.text;
			
			//Hide flash textfield
			_flashTextfield.visible = false;
			_textfield.visible = true;
		}
		
		private function _onKeyUp(e:KeyboardEvent):void
		{
			//Listen for enter
			if (e.keyCode == 13) _onFocusOut(null);
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Get touch
			var touch:Touch = e.getTouch(this);
			
			//Check if touch exists
			if (touch != null && touch.phase == TouchPhase.BEGAN)
			{
				//Position textfield
				_flashTextfield.x = this.x + parent.x + parent.parent.x;
				_flashTextfield.y = this.y + parent.y + parent.parent.y;
				
				//We've got to go deeper!
				if (parent.parent.parent != null)
				{
					_flashTextfield.x += parent.parent.parent.x;
					_flashTextfield.y += parent.parent.parent.y;
				}
			
				//Show textfield
				_flashTextfield.visible = true;
				_textfield.visible = false;
				Starling.current.nativeStage.focus = _flashTextfield;
			}
		}
		
		public function get text():String
		{
			return _textfield.text;
		}
		
	}

}