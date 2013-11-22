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
		
		public function StaticTexture(atlas:String, texture:String) 
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
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _image.width, _image.height);
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
			
				//Set cull bounds
				cullBounds.setTo(0, 0, _image.width, _image.height);
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
			
				//Set cull bounds
				cullBounds.setTo(0, 0, _image.width, _image.height);
			}
		}
		
	}

}