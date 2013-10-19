package oni.entities.lights 
{
	import oni.Oni;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PointLight extends Light
	{
		private var _radius:int;
		
		protected var _shape:Shape;
		
		public function PointLight(colour:uint, intensity:Number, radius:int) 
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
			dispatchEventWith(Oni.UPDATE_DATA, false, { radius: radius } );
		}
		
		private function _redraw(e:Event):void
		{
			//Set radius
			_radius = e.data.radius;
			
			//Clear graphics
			_shape.graphics.clear();
			
			//Colour fill
			_shape.graphics.beginFill(colour, intensity);
			
			//Draw circle
			_shape.graphics.drawCircle(_radius, _radius, _radius);
			
			//End
			_shape.graphics.endFill();
			
			//Set cull bounds
			cullBounds.setTo(0, 0, width + 64, height + 64);
		}
		
		public function get radius():int
		{
			return _radius;
		}
		
		public function set radius(value:int):void
		{
			dispatchEventWith(Oni.UPDATE_DATA, false, { radius: value } );
		}
		
	}

}