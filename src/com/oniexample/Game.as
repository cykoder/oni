package com.oniexample 
{
	import com.oniexample.assets.AssetStoreSD;
	import com.oniexample.assets.AssetStoreHD;
	import oni.assets.AssetManager;
	import oni.Startup;
	import oni.utils.Backend;
	
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Game extends Startup
	{
		
		public function Game() 
		{
			//Set asset stores, you must always do this in your document class constructor
			AssetManager.AssetStoreSD = AssetStoreSD;
			AssetManager.AssetStoreHD = AssetStoreHD;
		}
		
	}

}