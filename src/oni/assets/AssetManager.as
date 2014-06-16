package oni.assets 
{
	import oni.sound.MSound;
	import oni.utils.Backend;
	import oni.utils.Platform;
    import flash.utils.Dictionary;
    import flash.display.Bitmap;
    import flash.media.Sound;
    import flash.utils.ByteArray;
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * Manages all game assets, from textures to sounds
	 * @author Sam Hellawell
	 */
	public class AssetManager 
	{
		/**
		 * The textures dictionary
		 */
        private static var _textures:Dictionary = new Dictionary();
		
		/**
		 * The sounds dictionary
		 */
        private static var _sounds:Dictionary = new Dictionary();
		
		/**
		 * The objects dictionary
		 */
		private static var _objects:Dictionary = new Dictionary();
		
		/**
		 * Asset stores
		 */
		public static var AssetStoreSD:Class, AssetStoreHD:Class;
		
		/**
		 * The class in which assets are stored
		 */
		public static var assetStore:Class;
		
		/**
		 * The scale factor for the textures
		 */
		public static var scaleFactor:Number;
		
		/**
		 * Whether to force standard definiton graphics mode
		 */
		public static var forceSD:Boolean = false;
		
		/**
		 * Gets an asset and returns it as an object
		 * @param	name
		 * @return
		 */
		public static function getAsset(name:String):Object 
		{
			//Check if asset store exists
			if (assetStore == null)
			{
				//Get scale factor
				scaleFactor = (Starling.current.viewPort.width <= Platform.STAGE_WIDTH || forceSD) ? 1 : 2;
				
				//Get asset store
				if (scaleFactor <= 1)
				{
					Backend.log("Standard definition graphics mode");
					assetStore = AssetStoreSD;
				}
				else
				{
					Backend.log("High definition graphics mode");
					assetStore = AssetStoreHD;
				}
				
				//Check if still null
				if (assetStore == null) throw new Error("You must set AssetStoreSD and AssetStoreHD in your document class!");
			}
			
			//Return the reference
			try
			{
				if (assetStore[name] != null) return new assetStore[name];
				if (AssetStore[name] != null) return new AssetStore[name];
				//Backend.log("AssetManager: Can't find asset: " + name, "error");
			}
			catch(error:Error)
			{
				Backend.log("AssetManager: " + error.message, "error");
			}
			
			return null;
		}
		
		/**
		 * Gets a texture, stores in dictionary and returns it
		 * @param	name
		 * @return
		 */
		public static function getTexture(name:String):Texture
		{
			//Is it in the dictionary?
			if (_textures[name] == undefined)
			{
				//Get asset
				var data:Object = getAsset(name);
                if (data is Bitmap)
				{
					//Bitmap data
                    _textures[name] = Texture.fromBitmap(data as Bitmap, false, false, scaleFactor);
				}
                else if (data is ByteArray)
				{
					//Byte array data
                    _textures[name] = Texture.fromAtfData(data as ByteArray, scaleFactor);
				}
			}
			
			//Return the texture
			return _textures[name];
		}
		
		/**
		 * Gets an asset as a bitmap
		 * @param	name
		 * @return
		 */
		public static function getBitmap(name:String):Bitmap
		{
			return getAsset(name) as Bitmap;
		}
		
		/**
		 * Gets a texture atlas, stores in dictionary and returns it
		 * @param	name
		 * @return
		 */
		public static function getTextureAtlas(name:String):TextureAtlas
		{
			//Is it in the dictionary?
			if (_textures[name + "Atlas"] == undefined)
			{
				//Create atlas
				_textures[name + "Atlas"] = new TextureAtlas(getTexture(name), XML(getAsset(name + "Atlas")));
			}
			
			//Return the texture atlas
			return _textures[name + "Atlas"];
		}
		
		/**
		 * Gets a sound, stores in dictionary and returns it
		 * @param	name
		 * @return
		 */
		public static function getSound(name:String):MSound
		{
			//Is it in the dictionary?
			if (_sounds[name] == undefined)
			{
				//Get asset
				var data:Object = getAsset("sound_" + name);
				
				//Set the sound
                if (data is Sound) _sounds[name] = new MSound(data as Sound);
			}
			
			//Return the texture
			return _sounds[name];
		}
		
		/**
		 * Gets a text asset as an XML instance
		 * @param	name
		 * @return
		 */
		public static function getXML(name:String):XML
		{
			//Get file as byte array
			var contentByteArray:ByteArray = getAsset(name) as ByteArray;
			
			//Get content as string
			var contentString:String = contentByteArray.readUTFBytes(contentByteArray.length);
			
			//Create an XML object
			var xml:XML = new XML(contentString);
			
			//Do some GC
			contentByteArray=null;
			contentString=null;
			
			//Return xml
			return xml;
		}
		
		/**
		 * Gets a text asset as a JSON instance
		 * @param	name
		 * @return
		 */
		public static function getJSON(name:String):Object
		{
			//Is it in the dictionary?
			if (_objects[name] == undefined)
			{
				//Get asset as byte array
				var contentByteArray:ByteArray = getAsset(name) as ByteArray;
				
				//Get content as string
				var contentString:String = contentByteArray.readUTFBytes(contentByteArray.length);
				
				//Create a JSON object
				_objects[name] = JSON.parse(contentString);
			
				//Do some GC
				contentByteArray=null;
				contentString=null;
			}
			
			//Return the texture
			return _objects[name];
		}
	}

}