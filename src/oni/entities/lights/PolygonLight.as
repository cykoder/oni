package oni.entities.lights 
{
	import oni.Oni;
	import oni.rendering.Light;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PolygonLight extends Light
	{
		private var _collisionData:Array;
		
		protected var _shape:Shape;
		
		public function PolygonLight(colour:uint, intensity:Number, collisionData:Array) 
		{
			//Super
			super(colour, intensity);
			
			//Create a shape
			_shape = new Shape();
			addChild(_shape);
			
			//Set touchable
			//this.touchable = true;
			
			//Listen for collision update
			addEventListener(Oni.UPDATE_DATA, _redraw);
			
			//Update collision
			dispatchEventWith(Oni.UPDATE_DATA, false, { collisionData: collisionData } );
		}
		
		private function _redraw(e:Event):void
		{
			//Get collision data
			_collisionData = e.data.collisionData;
			
			//Add first element (fixes drawing errors)
			_collisionData.push(_collisionData[0]);
			
			//Clear graphics
			_shape.graphics.clear();
			
			//Colour fill
			_shape.graphics.beginFill(color, intensity);
			
			//Loop through each point and redraw
			for (var i:uint = 0; i < _collisionData.length; ++i)
			{
				if (i == 0)
				{
					_shape.graphics.moveTo(_collisionData[i].x, _collisionData[i].y);
				}
				else
				{
					_shape.graphics.lineTo(_collisionData[i].x, _collisionData[i].y);
				}
			}
			
			//End fill
			_shape.graphics.endFill();
			
			//Draw debug outlines
			/*_shape.graphics.lineStyle(5, 0xFFFFFF);
			for (i = 0; i < _collisionData.length; ++i)
			{
				if (i == 0)
				{
					_shape.graphics.moveTo(_collisionData[i].x, _collisionData[i].y);
				}
				else
				{
					_shape.graphics.lineTo(_collisionData[i].x, _collisionData[i].y);
				}
			}
			
			//Draw debug points
			_shape.graphics.lineStyle(1, 0xCCCCCC);
			_shape.graphics.beginFill(0xFFFFFF, 1);
			for (i = 0; i < _collisionData.length; ++i)
			{
				_shape.graphics.drawCircle(_collisionData[i].x, _collisionData[i].y, 10);
			}
			_shape.graphics.endFill();*/
			
			//Remove element added at start
			_collisionData.pop();
			
			//Set cull bounds
			cullBounds.setTo(0, 0, width + 64, height + 64);
		}
		
	}

}