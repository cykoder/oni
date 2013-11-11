package com.oniexample.assets 
{
	/**
	 * Literally a store for all game assets
	 * @author Sam Hellawell
	 */
	public class AssetStoreSD
	{
		/*
		 * Weather textures
		 */
        [Embed(source="../../../../lib/textures/sd/weather/haze.png")]
        public static const weather_haze:Class;
		
		/*
		 * Light textures
		 */
        [Embed(source="../../../../lib/textures/sd/lights/point.png")]
        public static const light_point:Class;
		
		/*
		 * Smart textures
		 */
        [Embed(source="../../../../lib/example/sd/smarttextures/debug/background.png")]
        public static const smarttexture_debug_background:Class;
        [Embed(source="../../../../lib/example/sd/smarttextures/debug/floor.png")]
        public static const smarttexture_debug_floor:Class;
        [Embed(source="../../../../lib/example/sd/smarttextures/debug/wall.png")]
        public static const smarttexture_debug_wall:Class;
		
        [Embed(source="../../../../lib/example/sd/smarttextures/grass/background.png")]
        public static const smarttexture_grass_background:Class;
        [Embed(source="../../../../lib/example/sd/smarttextures/grass/floor.png")]
        public static const smarttexture_grass_floor:Class;
        [Embed(source="../../../../lib/example/sd/smarttextures/grass/wall.png")]
        public static const smarttexture_grass_wall:Class;
		
        [Embed(source="../../../../lib/example/sd/smarttextures/factory_metal/background.png")]
        public static const smarttexture_factory_metal_background:Class;
        [Embed(source="../../../../lib/example/sd/smarttextures/factory_metal/floor.png")]
        public static const smarttexture_factory_metal_floor:Class;
        [Embed(source="../../../../lib/example/sd/smarttextures/factory_metal/wall.png")]
        public static const smarttexture_factory_metal_wall:Class;
		
		/*
		 * Background textures
		 */
        [Embed(source="../../../../lib/example/sd/backgrounds/sky.png")]
        public static const background_sky:Class;
		
		/*
		 * Light textures (not required)
		 */
        [Embed(source="../../../../lib/example/sd/lights/oniworks.png")]
        public static const light_oniworks:Class;
		
		/*
		 * Entity textures
		 */
        [Embed(source="../../../../lib/example/sd/levels/factory.png")]
        public static const scene_factory:Class;
        [Embed(source="../../../../lib/example/sd/levels/factory.xml", mimeType="application/octet-stream")]
        public static const scene_factoryAtlas:Class;
		
	}

}