package oni.editor.ui 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import oni.entities.Entity;
	import oni.entities.environment.SmartTexture;
	import oni.Oni;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class VectorEditor extends Shape
	{
		private var _points:Array;
		
		private var selectedPoint:int = -1;
		
		private var _hasSelectedControlPoint:Boolean;
		
		private var _entity:Entity;
		
		public function VectorEditor() 
		{
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _onUpdateData);
			
			//Listen for touch
			addEventListener(TouchEvent.TOUCH, _onTouch);
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		private function _onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
		}
		
		private function _onUpdateData(e:Event):void
		{
			//Set visible
			this.visible = (e.data.entity != null);
			
			//Only proceed if visible
			if (visible)
			{
				//Set entity
				_entity = e.data.entity;
				
				//Set points
				_points = (e.data.entity as SmartTexture).points;
				
				//Redraw
				_redraw();
			}
		}
		
		private function _onTouch(e:TouchEvent):void
		{
			//Check if there is a touch
			var j:uint, i:uint;
			var touch:Touch = e.getTouch(this);
			if (touch != null)
			{
				//Get the touch location
				var touchLocation:Point = touch.getLocation(this);
				if (touch.phase == TouchPhase.BEGAN)
				{
					//Calculate the touch rectangle
					var touchRect:Rectangle = new Rectangle(touchLocation.x-16, touchLocation.y-16, 32, 32);
					for (i = 0; i < _points.length; i++)
					{
						//Check if we're touching point i
						if (touchRect.contains(_points[i].x, _points[i].y))
						{
							selectedPoint = i;
							_hasSelectedControlPoint = false;
							break;
						}
						else if (_points[i].control != null && touchRect.contains(_points[i].control.x, _points[i].control.y)) //Point i's control point
						{
							selectedPoint = i;
							_hasSelectedControlPoint = true;
							break;
						}
					}
					
					//Check for double click
					if (touch.tapCount == 2 && !_hasSelectedControlPoint)
					{
						if (selectedPoint >= 0 && e.ctrlKey)
						{
							trace("EY");
						}
						else
						{
							//Calculate where to begin and end the ray
							var rayStart:Point = new Point(touchLocation.x - 32, touchLocation.y - 32);
							var rayEnd:Point = new Point(touchLocation.x + 32, touchLocation.y + 16);
							
							//Go through every point
							var n:int = _points.length;
							for (i = 0; i < n; i++)
							{
								//Check for intersection
								j = i + 1 == n ? 0: i + 1;
								var intersection:Point = _getIntersection(rayStart, rayEnd, new Point(_points[i].x, _points[i].y), new Point(_points[j].x, _points[j].y));
								if (intersection != null)
								{
									//Add new point in between i and j
									_points.splice(i + 1, 0, { x: intersection.x, y: intersection.y });
									
									//Update data
									_entity.dispatchEventWith(Oni.UPDATE_DATA, false, { points:_points });
									
									//Redraw
									_redraw();
									
									//And finally, break the loop!
									break;
								}
							}
						}
					}
				}
				else if (selectedPoint > -1 &&
						 touch.phase == TouchPhase.MOVED) //Moving a selected point
				{
					//Check if we have a control point selected
					if (_hasSelectedControlPoint)
					{
						//Set
						_points[selectedPoint].control.x = touchLocation.x;
						_points[selectedPoint].control.y = touchLocation.y;
					}
					else //Nope, normal point
					{
						//Set
						_points[selectedPoint].x = touchLocation.x;
						_points[selectedPoint].y = touchLocation.y;
						
						//Limit
						if (_points[selectedPoint].x < 0) _points[selectedPoint].x = 0;
						if (_points[selectedPoint].y < 0) _points[selectedPoint].y = 0;
					}
					
					//Update data
					_entity.dispatchEventWith(Oni.UPDATE_DATA, false, { points: _points, collision: false } );
					
					//Redraw
					_redraw();
				}
				else if (touch.phase == TouchPhase.ENDED) //Ended touch
				{
					//Deselect point
					//selectedPoint = -1;
					//_hasSelectedControlPoint = false;
					
					//Update data (with collision this time)
					_entity.dispatchEventWith(Oni.UPDATE_DATA, false, { points: _points, collision: true } );
					
					//Redraw
					_redraw();
				}
			}
		}
		
		private function _getIntersection(a:Point, b:Point, c:Point, d:Point):Point
		{
			var distAB:Number, cos:Number, sin:Number, newX:Number, ABpos:Number;
			if ((a.x == b.x && a.y == b.y) || (c.x == d.x && c.y == d.y)) return null;
		 
			if ( a == c || a == d || b == c || b == d ) return null;
		 
			b = b.clone();
			c = c.clone();
			d = d.clone();
		 
			b.offset( -a.x, -a.y);
			c.offset( -a.x, -a.y);
			d.offset( -a.x, -a.y);
			// a is now considered to be (0,0)
		 
			distAB = b.length;
			cos = b.x / distAB;
			sin = b.y / distAB;
		 
			c = new Point(c.x * cos + c.y * sin, c.y * cos - c.x * sin);
			d = new Point(d.x * cos + d.y * sin, d.y * cos - d.x * sin);
		 
			if ((c.y < 0 && d.y < 0) || (c.y >= 0 && d.y >= 0)) return null;
		 
			ABpos = d.x + (c.x - d.x) * d.y / (d.y - c.y); // what.
			if (ABpos < 0 || ABpos > distAB) return null;
		 
			return new Point(a.x + ABpos * cos, a.y + ABpos * sin);			
		}
		
		private function _redraw():void
		{
			//Clear graphics
			graphics.clear();
			
			//Draw outlines
			graphics.lineStyle(5, 0xFFFFFF);
			var i:uint = 0;
			for (i = 0; i < _points.length; ++i)
			{
				if (i == 0)
				{
					graphics.moveTo(_points[i].x, _points[i].y);
				}
				else
				{
					
					//Draw line
					if (_points[i].control == null)
					{
						graphics.lineTo(_points[i].x, _points[i].y);
					}
					else
					{
						graphics.curveTo(_points[i].control.x, _points[i].control.y, _points[i].x, _points[i].y);
					}
					
					
					//graphics.lineTo(_points[i].x, _points[i].y);
				}
			}
			
			//Draw points
			graphics.lineStyle(5, 0xFFFFFF);
			for (i = 0; i < _points.length; i++)
			{
				if (i == selectedPoint)
				{
					graphics.beginFill(0xFF0000);
				}
				else
				{
					graphics.beginFill(0xFFFFFF, 0);
				}
				
				graphics.drawCircle(_points[i].x, _points[i].y, 10);
				
				if (_points[i].control != null)
				{
					graphics.drawCircle(_points[i].control.x, _points[i].control.y, 5);
				}
			}
			graphics.endFill();
		}
		
		public function deletePoint():void
		{
			if (selectedPoint >= 0)
			{
				if (_hasSelectedControlPoint)
				{
					//Remove the selected control point
					_points[selectedPoint].control = null;
				}
				else
				{
					//Remove the selected point
					_points.splice(selectedPoint, 1);
				}
				
				//Update data
				_entity.dispatchEventWith(Oni.UPDATE_DATA, false, { points: _points, collision: true } );
				
				//Redraw
				_redraw();
				
				//Deselect point
				selectedPoint = -1;
				_hasSelectedControlPoint = false;
			}
		}
		
		private function _onKeyUp(e:KeyboardEvent):void
		{
			//Key controls
			switch(e.keyCode)
			{
				case 46: //Delete
					deletePoint();
					break;
				
				case 67: //C
					if (selectedPoint >= 0 && !_hasSelectedControlPoint)
					{
						_points[selectedPoint].control = { x: _points[selectedPoint].x - 32, y: _points[selectedPoint].y - 32 };
						
						//Update data
						_entity.dispatchEventWith(Oni.UPDATE_DATA, false, { points: _points } );
						
						//Redraw
						_redraw();
					}
					break;
			}
		}

	}

}