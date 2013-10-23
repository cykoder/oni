package com.oniexample 
{
	import com.oniworks.assets.AssetStoreSD;
	import com.oniworks.assets.AssetStoreHD;
	import oni.assets.AssetManager;
	import oni.utils.Backend;
	
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Game extends Main
	{
		
		public function Game() 
		{
			//Set asset stores
			AssetManager.AssetStoreSD = AssetStoreSD;
			AssetManager.AssetStoreHD = AssetStoreHD;
		}
		
	}

}