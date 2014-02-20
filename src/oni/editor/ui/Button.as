package oni.editor.ui 
{
	import oni.assets.AssetManager;
	import oni.editor.EditorScreen;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
    import starling.text.BitmapFont;
    import starling.text.TextField;
    import starling.utils.HAlign;
    import starling.utils.VAlign;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Button extends Shape
	{
		public static const PRESSED:String = "pressed";
		
		private var _icon:Image;
		
		private var _textfield:TextField;
		
		public function Button(icon:String, text:String) 
		{
			//Draw base rect
			graphics.lineStyle(1, 0x333333, 1);
			graphics.beginFill(0x0F0F0F);
			graphics.drawRect(0,0,136,44);
			graphics.endFill();
			
			//Set name
			this.name = icon + "_" + text;
			
			//Add an icon
			_icon = new Image(AssetManager.getTexture("editor_icon_" + icon));
			addChild(_icon);
			
			//Create a text field
            _textfield = new TextField(width - 22, height, text, "Verdana", 16, 0xFFFFFF);
			_textfield.x = 22;
            _textfield.hAlign = HAlign.CENTER;
            _textfield.vAlign = VAlign.CENTER;
			addChild(_textfield);
			
			//Listen for touch
			addEventListener(TouchEvent.TOUCH, _onTouch);
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Get touch
			var touch:Touch = e.getTouch(this);
			
			//Check if touched
			if (!disabled && touch != null)
			{
				//Check if we should select
				if (touch.phase == TouchPhase.ENDED)
				{
					//Dispatch event
					dispatchEventWith(Button.PRESSED);
					
					//Set alpha
					_icon.alpha = _textfield.alpha = 1;
				}
				else if(touch.phase == TouchPhase.BEGAN) //Little select effect
				{
					_icon.alpha = _textfield.alpha = 0.5;
				}
			}
		}
		
		public function get disabled():Boolean
		{
			return alpha == 0.25;
		}
		
		public function set disabled(value:Boolean):void
		{
			//Set disabled
			if (value)
			{
				alpha = 0.25;
			}
			else
			{
				alpha = 1;
			}
		}
		
	}

}