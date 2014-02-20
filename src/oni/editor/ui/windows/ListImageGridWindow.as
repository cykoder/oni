package oni.editor.ui.windows 
{
	import flash.geom.Rectangle;
	import oni.editor.ui.Button;
	import oni.editor.ui.Icon;
	import oni.Oni;
	import starling.display.Shape;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class ListImageGridWindow extends Window
	{
		public static const SELECTED:String = "selected";
		
		private var _grid:Sprite;
		
		private var _scrollUpArrow:Icon;
		
		private var _scrollDownArrow:Icon;
		
		private var _selectedItem:Image;
		
		private var _selectedLabel:String;
		
		private var _labels:Vector.<TextField>;
		
		private var _data:Array;
		
		public function ListImageGridWindow(width:int, height:int, title:String, data:Array) 
		{
			//Super
			super(width, height, title);
			
			//Side bg
			_background.graphics.beginFill(0xFFFFFF, 0.05);
			_background.graphics.lineStyle(1, 0x333333);
			_background.graphics.drawRect(0, 22, 128, height-22);
			_background.graphics.endFill();
			
			//Create a grid
			_grid = new Sprite();
			_grid.x = 70;
			_grid.y = 22;
			_grid.clipRect = new Rectangle(0, 0, width-100, height-22);
			addChild(_grid);
			
			_scrollUpArrow = new Icon("up", true);
			_scrollUpArrow.x = width - 26;
			_scrollUpArrow.y = 24;
			_scrollUpArrow.scaleX = _scrollUpArrow.scaleY = 0.6;
			_scrollUpArrow.addEventListener(Icon.SELECTED, _onScroll);
			addChild(_scrollUpArrow);
			
			_scrollDownArrow = new Icon("down", true);
			_scrollDownArrow.x = _scrollUpArrow.x;
			_scrollDownArrow.y = height - 26;
			_scrollDownArrow.scaleX = _scrollDownArrow.scaleY = 0.6;
			_scrollDownArrow.addEventListener(Icon.SELECTED, _onScroll);
			addChild(_scrollDownArrow);
			
			
			
			//Populate
			populate(data);
		}
		
		public function populate(arr:Array):void
		{
			//Set data
			_data = arr;
			
			//Remove
			var i:uint;
			if (_labels != null)
			{
				for (i = 0; i < _labels.length; i++) removeChild(_labels[i]);
			}
			
			//Create labels
			_labels = new Vector.<TextField>();
			for (i = 0; i < _data.length; i++)
			{
				_labels.push(new TextField(128, 22, _data[i].name, "Verdana", 10, 0xFFFFFF));
				_labels[i].y = (i + 1) * 22;
				_labels[i].alpha = 0.5;
				_labels[i].addEventListener(TouchEvent.TOUCH, _onLabelTouch);
				addChild(_labels[i]);
			}
			
			//Select debug
			_selectLabel(_labels[0].text);
		}
		
		private function _onLabelTouch(e:TouchEvent):void
		{
			//Check if pressed
			var touch:Touch = e.getTouch(this, TouchPhase.ENDED);
			
			//Select the label
			if (touch != null) _selectLabel((e.currentTarget as TextField).text);
		}
		
		public function get selectedLabel():String
		{
			return _selectedLabel;
		}
		
		private function _selectLabel(label:String):void
		{
			//Different?
			if (_selectedLabel != label)
			{
				//Remove grid children
				var i:uint;
				while (_grid.numChildren > 0) _grid.removeChildAt(0);
				
				//Set selected label
				_selectedLabel = label;
				
				//Work out max items
				var maxRows:uint = uint((width-136)/128);
				
				//Loop through array
				var c:uint = 0;
				for (i = 0; i < _data.length; i++)
				{
					if (_data[i].name == label)
					{
						//Set selected
						_labels[i].alpha = 1;
						
						var rowCount:uint = 0, columnCounter:uint = 0;
						for (c = 0; c < _data[i].textures.length; c++)
						{
								//Create image
								var img:Image = new Image(_data[i].textures[c]);
								img.name = _data[i].names[c];
								img.addEventListener(TouchEvent.TOUCH, _onItemTouch);
								
								//Scale, but keep aspect ratio
								var k:Number = 1;
								if (img.width > 128 || img.height > 128)
								{
									if(img.width > img.height)
									{
										k = Number(128 / img.width);
									}
									else
									{
										k = Number(128 / img.height);
									}
								}
								
								//Set pivot
								img.pivotX = img.width / 2;
								img.pivotY = img.height / 2;
								
								//Set scale
								img.scaleX = img.scaleY = k;
								
								//Count da columnz
								if (columnCounter >= maxRows)
								{
									columnCounter = 0;
									rowCount++;
								}
								
								//Position
								img.x = 132 + (146 * (columnCounter));
								img.y = 50 + (140 * rowCount);
								
								//Set alpha
								img.alpha = 0.5;
								
								//Add
								_grid.addChild(img);
							
							//Increment column counter
							columnCounter++;
						}
					}
					else
					{
						_labels[i].alpha = 0.5;
					}
				}
			}
		}
		
		private function _onItemTouch(e:TouchEvent):void
		{
			//Get touch
			var touch:Touch = e.getTouch(this);
			
			//Check
			if (touch != null)
			{
				var item:Image = e.currentTarget as Image;
				switch(touch.phase)
				{
					case TouchPhase.HOVER: //Mouse hover over, do a little select effect
						if (item != _selectedItem)
						{
							if (_selectedItem != null) _selectedItem.alpha = 0.5;
							
							_selectedItem = item;
							_selectedItem.alpha = 1;
						}
						break;
						
					case TouchPhase.ENDED:
						dispatchEventWith(ListImageGridWindow.SELECTED, false, { name: item.name });
						break;
				}
			}
		}
		
		private function _onScroll(e:Event):void
		{
			//Set new y
			var newY:int = 0;
			
			//Check if we want to be scrolling
			if (e.currentTarget == _scrollDownArrow)
			{
				//Scroll down
				newY -= 100;
			}
			else if (e.currentTarget == _scrollUpArrow && _grid.getChildAt(0).y < 50)
			{
				//Scroll up
				newY += 100;
			}
			
			//Set grid children position
			for (var i:uint = 0; i < _grid.numChildren; i++)
			{
				_grid.getChildAt(i).y += newY;
			}
		}
		
	}

}