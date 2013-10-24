package oni.screens 
{
	import oni.editor.EditorScreen;
	import oni.entities.debug.DebugCircle;
	import oni.entities.debug.DebugSquare;
	import oni.entities.Entity;
	import oni.entities.EntityManager;
	import oni.entities.environment.SmartTexture;
	import oni.entities.lights.Light;
	import oni.entities.lights.PointLight;
	import oni.entities.lights.PolygonLight;
	import oni.entities.scene.Prop;
	import oni.rendering.SceneRenderer;
	import oni.screens.GameScreen;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nape.shape.Circle;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import oni.Oni;
	import oni.rendering.SceneRenderer;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	/**
	 * TODO: This class really shouldn't be here, will tidy
	 * @author Sam Hellawell
	 */
	public class GameScreen extends Screen
	{
		public var scene:SceneRenderer;
		
		public var entityManager:EntityManager;
		
		public function GameScreen() 
		{
			//Super
			super("game");
			
			//Create an entity manager
			entityManager = new EntityManager();
			
			//Create a scene renderer
			//Set second parameter to "true" to enable a crappy lighting test
			scene = new SceneRenderer("midday", false);
			addChild(scene);
			
			//Listen for events
			entityManager.addEventListener(Oni.ENTITY_ADDED, _addEntity);
			entityManager.addEventListener(Oni.ENTITY_REMOVED, _removeEntity);
			
			var polygonPoints:Array = [new Point(0, 0),
									   new Point(256, 0),
									   new Point(256, 256),
									   new Point(0, 256),
									   new Point(0, 0)];
									   
			/*polygonPoints = [new Point(150, 100*4),
													  new Point(200*4, 100*4),
													  new Point(200*4, 150),
													  new Point(300*4, 150),
													  new Point(300*4, 150*4),
													  new Point(500*4, 150*4),
													  new Point(500*4, 300*4),
													  new Point(150, 300 * 4)];
													  
			polygonPoints = [new Point(50, 200*2),
													  new Point(100*2, 180*2),
													  new Point(130*2, 50*2),
													  new Point(150*2, 0),
													  new Point(300*2, 160*2),
													  new Point(350*2, 180*2),
													  new Point(350*2, 225*2),
													  new Point(50, 225 * 2)];*/
			
			var debugTexture:SmartTexture = new SmartTexture("debug", polygonPoints, false);
									   debugTexture.y = 100;
									   debugTexture.x = 300;
									   debugTexture.z = 0.5;
			//entityManager.addEntity(debugTexture);
			
			debugTexture = new SmartTexture("grass", [new Point(0, 100),
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
			entityManager.addEntity(debugTexture);
			
			debugTexture = new SmartTexture("factory_metal", [new Point(0,256), new Point(20,0), new Point(256,30), new Point(300,300)], false);
									   debugTexture.y = 230;
									   debugTexture.x = 450;
									   debugTexture.z = 0.8;
			entityManager.addEntity(debugTexture);
			
			/*
			 * Test lights, this does work if you set lighting enabled when creating the scenerenderer
			 */
			var light:Light;
			/*light = new PolygonLight(0x0000FF, 1, [new Point(50, 200*2),
													  new Point(100*2, 180*2),
													  new Point(130*2, 50*2),
													  new Point(150*2, 0),
													  new Point(300*2, 160*2),
													  new Point(350*2, 180*2),
													  new Point(350*2, 225*2),
													  new Point(50, 225 * 2)]);
									   light.y = 100;
									   light.x = 300;
									   light.z = 0.5;
			entityManager.addEntity(light);
			*/
			light = new PolygonLight(0xFF0000, 1, [new Point(0, 400),
									   new Point(0, 100),
									   new Point(400, 90),
									   new Point(600, 100),
									   new Point(620, 0),
									   new Point(800, 0),
									   new Point(850, 100),
									   new Point(1000, 100),
									   new Point(1000, 400)]);
									   light.y = 300;
									   light.x = 0;
									   light.z = 1;
			entityManager.addEntity(light);
			
			light = new PointLight(0xFFFFFF, 0.75, 128);
			light.x = 200;
			light.y = 150;
			(light as PointLight).radius = 256;
			entityManager.addEntity(light);
			
			//Create a prop, read from the physics data file
			var prop:Prop = new Prop("factory", "bottom_support");
			prop.x = 400;
			prop.y = 300;
			entityManager.addEntity(prop);
			
			//C++, hah!
			for (var c:int = 0; c < 50; c++)
			{
				//Just spawning a few heads for physics testing
				entityManager.addEntity(new Prop("factory", "klankywanky")).x=600;
			}
			
			
			//addChild(new EditorScreen(scene, entityManager)).visible = true;
			
			
			//Listen for update
			addEventListener(Oni.UPDATE, _update);
		}
		
		/**
		 * Called when an entity needs to be added to the scene
		 * @param	e
		 */
		private function _addEntity(e:Event):void
		{
			//Add to scene
			scene.addChild(e.data.entity);
			
			//Relay event
			dispatchEvent(e);
		}
		
		/**
		 * Called when an entity needs to be removed from the scene
		 * @param	e
		 */
		private function _removeEntity(e:Event):void
		{
			//Remove from scene
			scene.removeChild(e.data.entity);
			
			//Relay event
			dispatchEvent(e);
		}
		
		/**
		 * Update
		 * @param	e
		 */
		private function _update(e:Event):void
		{
			//Update the scene
			this.scene.dispatchEvent(e);
			
			//Update the entity manager
			this.entityManager.dispatchEvent(e);
			
			//TODO: Other stuff
			
		}
		
	}

}