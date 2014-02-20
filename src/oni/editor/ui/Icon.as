package oni.editor.ui 
{
	import oni.assets.AssetManager;
	import oni.editor.EditorScreen;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Icon extends Shape
	{
		public static const SELECTED:String = "selected";
		
		private var _icon:Image;
		
		private var _toggle:Boolean;
		
		public function Icon(icon:String, toggle:Boolean=false) 
		{
			//Draw base rect
			graphics.lineStyle(1, 0x333333, 1);
			graphics.beginFill(0x0F0F0F);
			graphics.drawRect(0,0,44,44);
			graphics.endFill();
			
			//Set name
			this.name = icon;
			
			//Set toggle
			_toggle = toggle;
			
			//Add actual icon
			_icon = new Image(AssetManager.getTexture("editor_icon_" + icon));
			addChild(_icon);
			
			//Deselect
			selected = false;
			
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
					if (!selected)
					{
						select();
					}
					else if(_toggle)
					{
						selected = false;
					}
				}
				else if(touch.phase == TouchPhase.BEGAN) //Little select effect
				{
					//_icon.alpha = 0.8;
				}
			}
		}
		
		public function select():void
		{
			//Set selected
			selected = true;
			
			//Dispatch event
			dispatchEventWith(Icon.SELECTED);
		}
		
		public function get selected():Boolean
		{
			return _icon.alpha == 1;
		}
		
		public function set selected(value:Boolean):void
		{
			if (value)
			{
				_icon.alpha = 1;
			}
			else
			{
				_icon.alpha = 0.5;
			}
		}
		
		public function get disabled():Boolean
		{
			return alpha == 0.25;
		}
		
		public function set disabled(value:Boolean):void
		{
			//Set selected
			selected = value;
			
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