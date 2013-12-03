package oni.entities.lights 
{
	import oni.Oni;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PolygonLight extends Light
	{
		/**
		 * The array of points to follow
		 */
		private var _lightPoints:Array;
		
		/**
		 * The shape to draw to
		 */
		protected var _shape:Shape;
		
		/**
		 * Creates a new polygon light with the given parameters
		 * @param	colour
		 * @param	intensity
		 * @param	lightPoints
		 */
		public function PolygonLight(params:Object) 
		{
			//Super
			super(params);
			
			//Create a shape
			_shape = new Shape();
			addChild(_shape);
			
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _redraw);
			
			//Update collision
			dispatchEventWith(Oni.UPDATE_DATA, false, params);
		}
		
		/**
		 * Redraws the light
		 * @param	e
		 */
		private function _redraw(e:Event):void
		{
			//Get collision data
			if(e.data.lightPoints != null) _lightPoints = e.data.lightPoints;
			
			//Add first element (fixes drawing errors)
			_lightPoints.push(_lightPoints[0]);
			
			//Clear graphics
			_shape.graphics.clear();
			
			//Colour fill
			_shape.graphics.beginFill(colour, intensity);
			
			//Loop through each point and redraw
			for (var i:uint = 0; i < _lightPoints.length; ++i)
			{
				if (i == 0)
				{
					_shape.graphics.moveTo(_lightPoints[i].x, _lightPoints[i].y);
				}
				else
				{
					_shape.graphics.lineTo(_lightPoints[i].x, _lightPoints[i].y);
				}
			}
			
			//End fill
			_shape.graphics.endFill();
			
			//Remove element added at start
			_lightPoints.pop();
			
			//Set cull bounds
			cullBounds.setTo(0, 0, width + 64, height + 64);
				
			//Change pivot
			this.pivotX = width / 2;
			this.pivotY = height / 2;
		}
		
	}

}