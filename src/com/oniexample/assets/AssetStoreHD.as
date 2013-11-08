package com.oniexample.assets 
{
	/**
	 * Literally a store for all game assets
	 * @author Sam Hellawell
	 */
	public class AssetStoreHD
	{
		/*
		 * Light textures (required)
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
		 * Light textures
		 */
        [Embed(source="../../../../lib/example/hd/lights/oniworks.png")]
        public static const light_oniworks:Class;
		
		/*
		 * Sky textures
		 */
        [Embed(source="../../../../lib/example/hd/backgrounds/dawn.png")]
        public static const scene_background_dawn:Class;
        [Embed(source="../../../../lib/example/hd/backgrounds/midday.png")]
        public static const scene_background_midday:Class;
        [Embed(source="../../../../lib/example/hd/backgrounds/dusk.png")]
        public static const scene_background_dusk:Class;
        [Embed(source="../../../../lib/example/hd/backgrounds/midnight.png")]
        public static const scene_background_midnight:Class;
		
		/*
		 * Entity textures
		 */
        [Embed(source="../../../../lib/example/hd/levels/factory.png")]
        public static const scene_factory:Class;
        [Embed(source="../../../../lib/example/hd/levels/factory.xml", mimeType="application/octet-stream")]
        public static const scene_factoryAtlas:Class;
		
		
	}

}