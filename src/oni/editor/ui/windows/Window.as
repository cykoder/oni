package oni.editor.ui.windows 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.Shape;
	import starling.display.Sprite;
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
	public class Window extends Sprite
	{
		protected var _background:Shape;
		
		private var _title:TextField;;
		
		private var _isDragging:Boolean = true;
		
		public function Window(width:int, height:int, title:String) 
		{
			//Create a background
			_background = new Shape();
			addChild(_background);
			
			//Base bg
			_background.graphics.beginFill(0x0F0F0F);
			_background.graphics.lineStyle(1, 0x333333);
			_background.graphics.drawRect(0, 0, width, height);
			_background.graphics.endFill();
			
			//Close bg
			_background.graphics.beginFill(0xFFFFFF, 0.025);
			_background.graphics.lineStyle(1, 0x333333, 0.75);
			_background.graphics.drawRect(width-22, 0, 22, 22);
			_background.graphics.endFill();
			
			//Close X
			_background.graphics.lineStyle(2, 0xFFFFFF, 0.75);
			_background.graphics.moveTo(width - 16, 6);
			_background.graphics.lineTo(width - 6, 16);
			_background.graphics.moveTo(width - 6, 6);
			_background.graphics.lineTo(width - 16, 16);
			
			//Window handle
			_background.graphics.beginFill(0xFFFFFF, 0.05);
			_background.graphics.lineStyle(1, 0x333333, 0.75);
			_background.graphics.drawRect(0, 0, width, 22);
			_background.graphics.endFill();
			
			//Create a title
			_title = new TextField(width-12, 22, title, "Verdana", 10, 0xFFFFFF);
			_title.x = 6;
			_title.hAlign = HAlign.LEFT;
			_title.vAlign = VAlign.CENTER;
			addChild(_title);
			
			//Position
			this.x = Starling.current.stage.stageWidth / 2 - width / 2;
			this.y = Starling.current.stage.stageHeight / 2 - height / 2;
			
			//Listen for touch
			addEventListener(TouchEvent.TOUCH, _onTouch);
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Get tough
			var touch:Touch = e.getTouch(this);
			
			//Touch ended?
			if (touch != null)
			{
				//Get touch location
				var touchPoint:Point = touch.getLocation(this);
				
				//Ended touch
				if (touch.phase == TouchPhase.ENDED)
				{
					//Stop dragging
					_isDragging = false;
					
					//Check if touched X
					if (touchPoint.x > width - 22 &&
						touchPoint.y < 22)
					{
						//Close!
						visible = false;
					}
				}
				else if (touch.phase == TouchPhase.BEGAN && touchPoint.y < 22) //Start touch
				{
					_isDragging = true;
				}
				else if (touch.phase == TouchPhase.MOVED && _isDragging) //Dragging window
				{
					var delta:Point = touch.getMovement(this);
					this.x += delta.x;
					this.y += delta.y;
					if (this.x < 0) this.x = 0;
					if (this.y < 0) this.y = 0;
				}
			}
		}
		
		public function set title(value:String):void
		{
			_title.text = value;
		}
		
		public function get title():String
		{
			return _title.text;
		}
		
	}

}