package com.oniexample.examples 
{
	import flash.geom.Point;
	import oni.entities.environment.SmartTexture;
	import oni.entities.environment.StaticTexture;
	import oni.entities.lights.AmbientLight;
	import oni.entities.lights.Light;
	import oni.entities.lights.PointLight;
	import oni.entities.lights.PolygonLight;
	import oni.entities.lights.TexturedLight;
	import oni.entities.scene.Prop;
	import oni.utils.Platform;
	import oni.Oni;
	import oni.assets.AssetManager;
	import oni.screens.GameScreen;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class TestScene extends GameScreen
	{
		
		public function TestScene(oni:Oni) 
		{
			//Super
			super(oni);
			
			//Create a little scene
			createScene(true);
			
			//Add a sky background
			var skyBG:StaticTexture = new StaticTexture("scene_background_sky");
			skyBG.width = Platform.STAGE_WIDTH;
			skyBG.height = Platform.STAGE_HEIGHT;
			skyBG.z = -1;
			entities.add(skyBG);
			
			//Create grass!
			var debugTexture:SmartTexture = new SmartTexture("grass", [new Point(0, 100),
									   new Point(250, 100),
									   new Point(500, 128),
									   new Point(700, 200),
									   new Point(750, 210),
									   new Point(800, 210),
									   new Point(1000, 250),
									   new Point(1200, 210),
									   new Point(1300, 180),
									   new Point(1500, 150),
									   new Point(1600, 125),
									   new Point(1700, 120),
									   new Point(1800, 125),
									   new Point(1900, 150),
									   new Point(2000, 170),
									   new Point(2200, 190),
									   new Point(2300, 210),
									   new Point(2300, 300),
									   new Point(1900, 300),
									   new Point(1900, 428),
									   new Point(2400, 450),
									   new Point(2600, 475),
									   new Point(2800, 450),
									   new Point(3200, 400),
									   new Point(3250, 400),
									   new Point(3325, 425),
									   new Point(3400, 440),
									   new Point(3500, 450),
									   
									   new Point(5000, 450),
									   new Point(5000, 1000),
									   new Point(0, 1000),
									   new Point(0, 100)], true);
									   debugTexture.y = 300;
									   debugTexture.x = 0;
									   debugTexture.z = 1;
									   debugTexture.cull = false;
			entities.add(debugTexture);
			
			debugTexture = new SmartTexture("factory_metal", [new Point(0,256), new Point(20,0), new Point(256,30), new Point(300,300)], false);
									   debugTexture.y = 230;
									   debugTexture.x = 450;
									   debugTexture.z = 0.8;
			entities.add(debugTexture);
			
			//Ambient!
			//entities.add(new AmbientLight(0x1B2D54, 1));
			//entities.add(new AmbientLight(0x000033, 1));
			entities.add(new AmbientLight(0xFFFFFF, 1));
			
			//Create a prop, read from the physics data file
			var prop:Prop = new Prop("factory", "bottom_support");
			prop.x = 400;
			prop.y = 300;
			entities.add(prop);
			
			//C++, hah!
			for (var c:int = 0; c < 50; c++)
			{
				//Just spawning a few heads for physics testing
				if ((Math.floor(Math.random() * (1 + 1))) == 0)
				{
					entities.add(new Prop("factory", "wardenjordan")).x = 600;
				}
				else
				{
					entities.add(new Prop("factory", "klankywanky")).x = 600;
				}
			}
			
			//Debug
			addEventListener(Oni.UPDATE, _update);
			addEventListener(TouchEvent.TOUCH, _touch);
		}
	
		private var _lastTouchPosition:Point = new Point();
		private var _touchDifference:Point = new Point();
		private function _touch(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(this);
			if (touch != null)
			{
				if (touch.phase == TouchPhase.BEGAN ||touch.phase == TouchPhase.MOVED)
				{
					_lastTouchPosition.setTo(stage.stageWidth / 2, stage.stageHeight / 2);
					_touchDifference.setTo(((_lastTouchPosition.x - touch.globalX) < 0) ? 1 : -1, ((_lastTouchPosition.y - touch.globalY) < 0) ? 1 : -1);
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					_touchDifference.setTo(0,0);
				}
			}
		}
		
		private function _update(e:Event):void
		{
			//Move camera by difference
			camera.x += _touchDifference.x * 50;
			camera.y += _touchDifference.y * 50;
		}
		
	}

}