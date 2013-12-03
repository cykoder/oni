package oni.components.weather.entities 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import oni.core.Scene;
	import oni.entities.Entity;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.materials.StandardMaterial;
	import starling.display.shaders.fragment.TextureFragmentShader;
	import starling.display.shaders.vertex.AnimateUVVertexShader;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Clouds extends Entity
	{
		private var _cloudData:BitmapData;
		
		private var _shape:Shape;
		
		private var _colourFilter:ColorMatrixFilter;
		
		private var _contrastFilter:ColorMatrixFilter;
		
		private var _brightnessFilter:ColorMatrixFilter;
		
		private var _spread:int;
		
		private var _octaves:int;
		
		private var _perlinBase:int;
		
		private var _windDirection:Point;
		
		private var _seed:uint;
		
		private var _material:StandardMaterial;
		
		public function Clouds(params:Object) 
		{
			//Default parameters
			if (params.windDirection == null) params.windDirection = new Point(-0.025, 0);
			if (params.intensity == null || isNaN(intensity)) params.intensity = 1;
			if (params.perlinBase == null || isNaN(perlinBase)) params.perlinBase = 100;
			if (params.octaves == null || isNaN(octaves)) params.octaves = 8;
			
			//Super
			super(params);
			
			//Set data
			this.z = params.z;
			_windDirection = params.windDirection;
			_perlinBase = params.perlinBase;
			_octaves = params.octaves;
			_seed = uint(Math.random() * 10);
			
			//Set entity stuff
			scrollX = scrollY = cull = false;
			
			//Create cloud data
			_cloudData = new BitmapData(256, 256);
			
			//Create a colour filter
			_colourFilter = new ColorMatrixFilter([0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 0, 0, 0, 0, 255, 1, 0, 0, 0, 0]);
			
			//Set spread
			this.spread = params.spread;
			
			//Set intensity
			this.intensity = params.intensity;
			
			//Set blend mode
			this.blendMode = BlendMode.ADD;
		}
		
		public function get spread():int
		{
			return _spread;
		}
		
		public function set spread(value:int):void
		{
			if (_spread != value || _contrastFilter == null || _brightnessFilter == null)
			{
				//Set
				_spread = value;
				
				//Create a contrast filter
				var s:Number = (_spread/100) + 1;
				var o:Number = 128 * (1 - s);
				_contrastFilter = new ColorMatrixFilter([s, 0, 0, 0, o, 0, s, 0, 0, o, 0, 0, s, 0, o, 0, 0, 0, 1, 0]);
				
				//Create a brightness filter
				var b:Number = (-_spread * 2.55);
				_brightnessFilter = new ColorMatrixFilter([1, 0, 0, 0, b, 0, 1, 0, 0, b, 0, 0, 1, 0, b, 0, 0, 0, 1, 0]);
				
				//Regenerate
				_generateClouds();
			}
		}
		
		private function _generateClouds():void
		{
			//Perlin noise
			_cloudData.perlinNoise(_perlinBase, _perlinBase, _octaves, _seed, true, true, 1, true);
			
			//Apply filters
			_cloudData.applyFilter(_cloudData, _cloudData.rect, new Point(), _contrastFilter);
			_cloudData.applyFilter(_cloudData, _cloudData.rect, new Point(), _brightnessFilter);
			_cloudData.applyFilter(_cloudData, _cloudData.rect, new Point(), _colourFilter);
			
			//Create a shape
			if (_shape == null)
			{
				//Create a material to draw clouds onto
				_material = new StandardMaterial(new AnimateUVVertexShader(_windDirection.x, _windDirection.y), new TextureFragmentShader());
				_material.textures[0] = Texture.fromBitmapData(_cloudData, false);
				
				//Create a shape
				_shape = new Shape();
				addChild(_shape);
				
				//Fill!
				_shape.graphics.beginMaterialFill(_material);
				_shape.graphics.drawRect(0, 0, 256, 256);
				_shape.graphics.endFill();
				
				//Stretch!
				_shape.width = Platform.STAGE_WIDTH;
				_shape.height = Platform.STAGE_HEIGHT;
			}
			else
			{
				//Dispose of current texture
				if (_material.textures[0] != null) _material.textures[0].dispose();
				
				//Set image texture
				_material.textures[0] = Texture.fromBitmapData(_cloudData, false);
			}
		}
		
		public function get windDirection():Point
		{
			return _windDirection;
		}
		
		public function set windDirection(value:Point):void
		{
			//Set
			_windDirection = value;
			
			//Set vertex shader
			_material.vertexShader = new AnimateUVVertexShader(_windDirection.x, _windDirection.y);
		}
		
		public function get octaves():int
		{
			return _octaves;
		}
		
		public function set octaves(value:int):void
		{
			//Set
			_octaves = value;
			
			//Regenerate
			_generateClouds();
		}
		
		public function get perlinBase():int
		{
			return _perlinBase;
		}
		
		public function set perlinBase(value:int):void
		{
			//Set
			_perlinBase = value;
			
			//Regenerate
			_generateClouds();
		}
		
		public function get intensity():Number
		{
			return alpha;
		}
		
		public function set intensity(value:Number):void
		{
			alpha = value;
		}
		
	}

}