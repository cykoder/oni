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
		private var _texture:String;
		
		private var _atlas:String;
		
		private var _image:Image;
		
		private var _pivot:Boolean;
		
		public function StaticTexture(atlas:String, texture:String, pivot:Boolean=true) 
		{
			//Create an image
			if (atlas == "" || atlas == null)
			{
				_image = new Image(AssetManager.getTexture(texture));
			}
			else
			{
				_image = new Image(AssetManager.getTextureAtlas(atlas).getTexture(texture));
			}
			addChild(_image);
			
			//Set texture and atlas
			_texture = texture;
			_atlas = atlas;
			
			//Set pivot or not
			_pivot = pivot;
			
			//Readjust
			_readjust();
		}
		
		public function get texture():String
		{
			return _texture;
		}
		
		public function set texture(value:String):void
		{
			//Only change if different
			if (_texture != value)
			{
				//Set
				_texture = value;
				
				//Set image texture
				if (atlas == "" || atlas == null)
				{
					_image.texture = AssetManager.getTexture(value);
				}
				else
				{
					_image.texture = AssetManager.getTextureAtlas(atlas).getTexture(texture);
				}
			
				//Readjust
				_readjust();
			}
		}
		
		public function get atlas():String
		{
			return _atlas;
		}
		
		public function set atlas(value:String):void
		{
			//Only change if different
			if (_atlas != value)
			{
				//Set
				_atlas = value;
				
				//Set image texture
				if (atlas == "" || atlas == null)
				{
					_image.texture = AssetManager.getTexture(value);
				}
				else
				{
					_image.texture = AssetManager.getTextureAtlas(atlas).getTexture(texture);
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
		
		private function _readjust():void
		{
			//Set pivot
			if (_pivot)
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