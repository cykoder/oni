package com.oniexample 
{
	import com.oniexample.assets.AssetStoreSD;
	import com.oniexample.assets.AssetStoreHD;
	import oni.assets.AssetManager;
	import oni.Startup;
	import oni.utils.Backend;
	
	/**
	 * This class doesn't do much besides boot up the game engine and set asset stores
	 * @author Sam Hellawell
	 */
	public class Main extends Startup
	{
		/**
		 * Bootloader!
		 */
		public function Main() 
		{
			//Set asset stores, you must always do this in your document class constructor
			AssetManager.AssetStoreSD = AssetStoreSD;
			AssetManager.AssetStoreHD = AssetStoreHD;
			
			//Set startup class
			Startup.StartupClass = ExampleGame;
			
			//Super, because we want to use the default initialiser!
			super();
		}
		
	}

}