package oni.entities.environment 
{
	import flash.geom.Rectangle;
	import oni.assets.AssetManager;
	import oni.entities.Entity;
	import starling.display.Image;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class StaticTexture extends Entity
	{
		private var _image:Image;
		
		public function StaticTexture(params:Object) 
		{
			//Default
			if (params.pivot == null) params.pivot = true;
			
			//Create an image
			if (params.atlas == "" || params.atlas == null)
			{
				_image = new Image(AssetManager.getTexture(params.texture));
			}
			else
			{
				_image = new Image(AssetManager.getTextureAtlas(params.atlas).getTexture(params.texture));
			}
			
			//Super
			super(params);
			addChild(_image);
			
			//Readjust
			_readjust();
		}
		
		public function get texture():String
		{
			return _params.texture;
		}
		
		public function set texture(value:String):void
		{
			//Only change if different
			if (_params.texture != value)
			{
				//Set
				_params.texture = value;
				
				//Set image texture
				if (_params.atlas == "" || _params.atlas == null)
				{
					_image.texture = AssetManager.getTexture(value);
				}
				else
				{
					_image.texture = AssetManager.getTextureAtlas(atlas).getTexture(_params.texture);
				}
			
				//Readjust
				_readjust();
			}
		}
		
		public function get atlas():String
		{
			return _params.atlas;
		}
		
		public function set atlas(value:String):void
		{
			//Only change if different
			if (_params.atlas != value)
			{
				//Set
				_params.atlas = value;
				
				//Set image texture
				if (_params.atlas == "" || _params.atlas == null)
				{
					_image.texture = AssetManager.getTexture(value);
				}
				else
				{
					_image.texture = AssetManager.getTextureAtlas(atlas).getTexture(_params.texture);
				}
			
				//Readjust
				_readjust();
			}
		}
		
		override public function get width():Number 
		{
			return _image.width;
		}
		
		override public function set width(value:Number):void 
		{
			_image.width = value;
			_readjust();
		}
		
		override public function get height():Number 
		{
			return _image.height;
		}
		
		override public function set height(value:Number):void 
		{
			_image.height = value;
			_readjust();
		}
		
		override public function get x():Number 
		{
			return super.x;
		}
		
		override public function set x(value:Number):void 
		{
			super.x = value;
		}
		
		override public function get y():Number 
		{
			return super.y;
		}
		
		override public function set y(value:Number):void 
		{
			super.y = value;
		}
		
		public function get pivot():Boolean
		{
			return _params.pivot;
		}
		
		public function set pivot(value:Boolean):void
		{
			_params.pivot = value;
			_readjust();
		}
		
		public function get image():Image
		{
			return _image;
		}
		
		private function _readjust():void
		{
			//Set pivot
			if (_params.pivot)
			{
				pivotX = _image.width / 2;
				pivotY = _image.height / 2;
			}
			else
			{
				pivotX = pivotY = 0;
			}
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _image.width, _image.height);
		}
		
	}

}