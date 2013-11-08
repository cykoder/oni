package oni.entities.environment 
{
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
		
		private var _image:Image;
		
		public function StaticTexture(texture:String) 
		{
			//Create an image
			_image = new Image(AssetManager.getTexture(texture));
			addChild(_image);
			
			//Set texture
			_texture = texture;
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
				_image.texture = AssetManager.getTexture(value);
			}
		}
		
	}

}