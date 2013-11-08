package oni.entities.lights 
{
	import oni.assets.AssetManager;
	import oni.Oni;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PointLight extends Light
	{
		/**
		 * The radius of the point light
		 */
		protected var _radius:int;
		
		/**
		 * The base point light image
		 */
		protected var _baseImage:Image;
		
		/**
		 * Crates a point light
		 * @param	colour
		 * @param	intensity
		 * @param	radius
		 */
		public function PointLight(colour:uint, intensity:Number, radius:int) 
		{
			//Super
			super(colour, intensity);
			
			//Create a base image
			_baseImage = new Image(AssetManager.getTexture("light_point"));
			addChild(_baseImage);
			
			//Listen for data update
			addEventListener(Oni.UPDATE_DATA, _redraw);
			
			//Update collision
			dispatchEventWith(Oni.UPDATE_DATA, false, { radius: radius } );
		}
		
		/**
		 * Redraws/updates the light
		 * @param	e
		 */
		private function _redraw(e:Event):void
		{
			//Check if we should set the radius
			if (e.data != null && e.data.radius && e.data.radius != _radius)
			{
				//Set radius
				_radius = e.data.radius;
				
				//Change pivot
				this.pivotX = this.pivotY = _radius / 2;
				
				//Resize base image
				_baseImage.width = _radius;
				_baseImage.height = _radius;
			}
			
			//Tint the base image
			if(_baseImage.color != colour) _baseImage.color = colour;
			
			//Set alpha
			if(this.alpha != intensity) this.alpha = intensity;
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _radius + 64, _radius + 64);
		}
		
		/**
		 * The radius of the point light
		 */
		public function get radius():int
		{
			return _radius;
		}
		
		/**
		 * The radius of the point light
		 */
		public function set radius(value:int):void
		{
			dispatchEventWith(Oni.UPDATE_DATA, false, { radius: value } );
		}
		
	}

}