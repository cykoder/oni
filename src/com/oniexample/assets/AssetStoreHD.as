package com.oniexample.assets 
{
	/**
	 * Literally a store for all game assets
	 * @author Sam Hellawell
	 */
	public class AssetStoreHD
	{
		/*
		 * Weather textures
		 */
        [Embed(source="../../../../lib/textures/hd/weather/haze.png")]
        public static const weather_haze:Class;
		
		/*
		 * Light textures
		 */
        [Embed(source="../../../../lib/textures/hd/lights/point.png")]
        public static const light_point:Class;
		
		/*
		 * Smart textures
		 */
        [Embed(source="../../../../lib/example/hd/smarttextures/debug/background.png")]
        public static const smarttexture_debug_background:Class;
        [Embed(source="../../../../lib/example/hd/smarttextures/debug/floor.png")]
        public static const smarttexture_debug_floor:Class;
        [Embed(source="../../../../lib/example/hd/smarttextures/debug/wall.png")]
        public static const smarttexture_debug_wall:Class;
		
        [Embed(source="../../../../lib/example/hd/smarttextures/grass/background.png")]
        public static const smarttexture_grass_background:Class;
        [Embed(source="../../../../lib/example/hd/smarttextures/grass/floor.png")]
        public static const smarttexture_grass_floor:Class;
        [Embed(source="../../../../lib/example/hd/smarttextures/grass/wall.png")]
        public static const smarttexture_grass_wall:Class;
		
        [Embed(source="../../../../lib/example/hd/smarttextures/factory_metal/background.png")]
        public static const smarttexture_factory_metal_background:Class;
        [Embed(source="../../../../lib/example/hd/smarttextures/factory_metal/floor.png")]
        public static const smarttexture_factory_metal_floor:Class;
        [Embed(source="../../../../lib/example/hd/smarttextures/factory_metal/wall.png")]
        public static const smarttexture_factory_metal_wall:Class;
		
		/*
		 * Background textures
		 */
        [Embed(source="../../../../lib/example/hd/backgrounds/sky.png")]
        public static const background_sky:Class;
		
		/*
		 * Light textures (not required)
		 */
        [Embed(source="../../../../lib/example/hd/lights/oniworks.png")]
        public static const light_oniworks:Class;
		
		/*
		 * Entity textures
		 */
        [Embed(source="../../../../lib/example/hd/levels/factory.png")]
        public static const scene_factory:Class;
        [Embed(source="../../../../lib/example/hd/levels/factory.xml", mimeType="application/octet-stream")]
        public static const scene_factoryAtlas:Class;
		
		
	}

}