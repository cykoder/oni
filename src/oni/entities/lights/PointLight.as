package oni.entities.lights 
{
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import oni.assets.AssetManager;
	import oni.Oni;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.textures.GradientTexture;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PointLight extends Light
	{
		/**
		 * A static base texture for all point lights
		 */
		private static var _lightTexture:Texture;
		
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
		public function PointLight(params:Object) 
		{
			//Super
			super(params);
			
			//Do we need to create a texture?
			if (_lightTexture == null)
			{
				//Calculate a base radius
				var radius:int = 64;
				
				//Create a background matrix 
				var bgMatrix:Matrix = new Matrix();
				bgMatrix.createGradientBox(radius, radius, Math.PI / 2);
				
				//Create the texture
				_lightTexture = GradientTexture.create(radius,
													   radius,
													   "radial",
													   [0xFFFFFF, 0x0],
													   [0, 1], 
													   [0, 255], 
													   bgMatrix);
			}
			
			//Create a base image
			_baseImage = new Image(_lightTexture);
			addChild(_baseImage);
			
			//Listen for data update
			addEventListener(Oni.UPDATE_DATA, _redraw);
			
			//Update collision
			dispatchEventWith(Oni.UPDATE_DATA, false, { radius: params.radius } );
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
			if (this.alpha != intensity) this.alpha = intensity;
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _radius, _radius);
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