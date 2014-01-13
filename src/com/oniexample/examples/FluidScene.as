package com.oniexample.examples 
{
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import oni.components.weather.WeatherSystem;
	import oni.core.Scene;
	import oni.entities.debug.DebugCircle;
	import oni.entities.debug.DebugSquare;
	import oni.entities.environment.FluidBody;
	import oni.entities.environment.SmartTexture;
	import oni.entities.environment.StaticTexture;
	import oni.entities.lights.AmbientLight;
	import oni.entities.lights.Light;
	import oni.entities.lights.PointLight;
	import oni.entities.lights.PolygonLight;
	import oni.entities.lights.TexturedLight;
	import oni.entities.platformer.Character;
	import oni.entities.scene.Prop;
	import oni.utils.Platform;
	import oni.Oni;
	import oni.assets.AssetManager;
	import oni.screens.GameScreen;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class FluidScene extends GameScreen
	{
		
		public function FluidScene(oni:Oni) 
		{
			//Super
			super(oni);
			
			scene = new Scene(false, false);
			
			//Add a sky background
			var skyBG:StaticTexture = new StaticTexture({atlas: null, texture: "background_sky", pivot: false});
			skyBG.width = Platform.STAGE_WIDTH;
			skyBG.height = Platform.STAGE_HEIGHT;
			skyBG.z = -1;
			skyBG.blendMode = BlendMode.NONE;
			entities.add(skyBG);
			
			entities.add(new SmartTexture( { texture: "grass", x: -160, y: 360,
				points: [ { x: 0, y: 0 },
						  { x: 400-64, y: 0 },
						  { x: 400, y: 64, control: { x: 400, y: 0 } },
						  { x: 400, y: 256 },
						  { x: 900, y: 256 },
						  { x: 900, y: 64 },
						  { x: 900+64, y: 0, control: { x: 900, y: 0 } },
						  { x: 1280, y: 0 },
						  { x: 1280, y: 512 },
						  { x: 0, y: 512 },
						  { x: 0, y: 0 } ]
			}));
			
			//C++, hah!
			var c:int
			for (c = 0; c < 1; c++)
			{
				//entities.add(new Prop( { atlas: "factory", name: "wardenjordan", x: 500, y: -200 } )).x = 300 + (c*100);
			}
			for (c = 0; c < 1; c++)
			{
				//entities.add(new Prop( { atlas: "factory", name: "bottom_support", y: -100, x: 500+(c*200) } ));
			}
			
			hero = new Character({bodyWidth: 64, bodyHeight: 128});
			hero.x = 100;
			hero.y = 100;
			entities.add(hero);
			
			entities.add(new FluidBody( { width: 500, height: 192, x: 240, y: 420 } ));
			//entities.add(new FluidBody( { width: 500, height: 192, x: 240, y: 420, density: 1000, viscosity: 0.075, topColor: 0xFFFF99, bottomColor: 0xFF9900 } ));
			//entities.add(new FluidBody( { width: 500, height: 192, x: 240, y: 420, density: 0.15, viscosity:100, topColor: 0x222222, bottomColor: 0x0 } ));
			
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			
			addEventListener(oni.Oni.UPDATE, _onUpdate);
			
			camera.z = 1.25;
		}
		
		private var hero:Character;
	
		private function _onUpdate(e:Event):void
		{
			camera.x = (hero.x) - Platform.STAGE_WIDTH/2;
			camera.y = (hero.y) - 100;
		}
		
		private function _onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == 39)
			{
				hero.move(1);
			}
			else if (e.keyCode == 37)
			{
				hero.move(-1);
			}
			else if (e.keyCode == 38)
			{
				hero.jump();
			}
		}
	
		private function _onKeyUp(e:KeyboardEvent):void
		{
			trace(e.keyCode);
			if (e.keyCode == 38)
			{
				hero.stopJumping();
			}
			else if (e.keyCode == 39 || e.keyCode == 37)
			{
				hero.stop();
			}
			else if (e.keyCode == 80)
			{
				entities.paused = !entities.paused;
			}
			else if (e.keyCode == 79)
			{
				entities.add(new Prop( { atlas: "factory", name: "wardenjordan", x: 300+(Math.random()*200), y: -200 } ));
			}
			else if (e.keyCode == 73)
			{
				entities.add(new Prop( { atlas: "factory", name: "bottom_support", x: 300+(Math.random()*200), y: -200 } ));
			}
		}
		
	}

}