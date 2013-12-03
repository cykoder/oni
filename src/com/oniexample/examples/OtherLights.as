package com.oniexample.examples 
{
	import flash.geom.Point;
	import nape.shape.Polygon;
	import oni.core.Scene;
	import oni.entities.environment.SmartTexture;
	import oni.entities.lights.AmbientLight;
	import oni.entities.lights.Light;
	import oni.entities.lights.PointLight;
	import oni.entities.lights.PolygonLight;
	import oni.entities.lights.TexturedLight;
	import oni.entities.scene.Prop;
	import oni.Oni;
	import oni.assets.AssetManager;
	import oni.screens.GameScreen;
	import oni.utils.Platform;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	/**
	 * "Other lights" tech demo
	 * @author Sam Hellawell
	 */
	public class OtherLights extends GameScreen
	{
		/**
		 * Ambient light intensity change increment
		 */
		private var _ambientLight:AmbientLight, _ambientIntensityIncrement:Number = 1;
		
		private var _polygonLight:PolygonLight;
		
		public function OtherLights(oni:Oni) 
		{
			//Super
			super(oni);
			
			//Create a little scene
			scene = new Scene(true);
			
			//Remove the camera
			components.remove(camera);
			
			//Create a background
			var debugTexture:SmartTexture = new SmartTexture("debug", [new Point(0, 0),
																	   new Point(Platform.STAGE_WIDTH, 0),
																	   new Point(Platform.STAGE_WIDTH, Platform.STAGE_HEIGHT),
																	   new Point(0, Platform.STAGE_HEIGHT),
																	   new Point(0, 0)], false);
			entities.add(debugTexture);
		
			//Create an ambient light
			_ambientLight = new AmbientLight(0xFFFFFF, 0.1);
			entities.add(_ambientLight);
			
			//Create a polygon light
			_polygonLight = new PolygonLight(0xFF0000, 1, [new Point(0, 100),
														   new Point(100,0),
														   new Point(200,100),
														   new Point(150,200),
														   new Point(50, 200),
														   new Point(0, 100)]);
			_polygonLight.x = 150;
			_polygonLight.y = 200;
			entities.add(_polygonLight);
			
			//Create 3 static point lights (red, green, blue)
			var light:Light;
			light = new PointLight(0xFF0000, 1, 256);
			light.x = 300+100;
			light.y = 100+128;
			entities.add(light);
			
			light = new PointLight(0x00FF00, 1, 256);
			light.x = 428+100;
			light.y = 100+128;
			entities.add(light);
			
			light = new PointLight(0x0000FF, 1, 256);
			light.x = 364+100;
			light.y = 228-32+128;
			entities.add(light);
			
			//Create a textured light
			light = new TexturedLight(AssetManager.getTexture("light_oniworks"), 0xFFFFFF, 1);
			light.x = 780;
			light.y = 350;
			entities.add(light);
			
			//Listen for update
			addEventListener(Oni.UPDATE, _onUpdate);
		}
		
		/**
		 * Called when the update event is fired
		 * @param	e
		 */
		private function _onUpdate(e:Event):void
		{
			//Change intensity
			if (_ambientLight.intensity <= 0) _ambientIntensityIncrement = 0.005;
			if (_ambientLight.intensity >= 1) _ambientIntensityIncrement = -0.005;
			_ambientLight.intensity += _ambientIntensityIncrement;
			scene.lighting.ambientLight = _ambientLight;
			
			_polygonLight.rotation += 0.05;
		}
		
	}

}