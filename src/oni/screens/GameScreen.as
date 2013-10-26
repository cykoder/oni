package oni.screens 
{
	import oni.assets.AssetManager;
	import oni.components.Camera;
	import oni.editor.EditorScreen;
	import oni.core.Scene;
	import oni.entities.EntityManager;
	import oni.screens.GameScreen;
	import flash.geom.Point;
	import oni.Oni;
	import oni.core.Scene;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * A base class for game screens
	 * @author Sam Hellawell
	 */
	public class GameScreen extends Screen
	{
		public var camera:Camera;
		
		public var scene:Scene;
		
		public var entityManager:EntityManager;
		
		public function GameScreen(oni:Oni) 
		{
			//Super
			super(oni, "game");
			
			//Create an entity manager
			entityManager = new EntityManager();
			addComponent(entityManager);
			
			//Create a camera
			camera = new Camera();
			addComponent(camera);
			
			//Listen for entity added and removed
			entityManager.addEventListener(Oni.ENTITY_ADDED, _entityAdded);
			entityManager.addEventListener(Oni.ENTITY_REMOVED, _entityRemoved);
			
			//Listen for camera position update
			camera.addEventListener(Oni.UPDATE_POSITION, _updatePosition);
			
			//addChild(new EditorScreen(scene, entityManager)).visible = true;
			
			//Debug
			addEventListener(Oni.UPDATE, _update);
			addEventListener(TouchEvent.TOUCH, _touch);
		}
		
		// TODO: remove this debug
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
		
		// TODO: remove this debug
		private function _update(e:Event):void
		{
			//Move camera by difference
			camera.x += _touchDifference.x*50;
			camera.y += _touchDifference.y * 50;
		}
		
		/**
		 * Create a scene
		 * @param	background
		 * @param	lighting
		 */
		public function createScene(background:String="", lighting:Boolean=true):void
		{
			//Check if we already have a scene
			if (scene != null)
			{
				//Dispose
				scene.dispose();
				removeComponent(scene);
				scene = null;
			}
			
			//Create a scene instance
			scene = new Scene(background, lighting);
			
			//Add to components
			addComponent(scene);
			
			//Add to display list
			addChild(scene);
		}
		
		/**
		 * Called when an entity needs to be added to the scene
		 * @param	e
		 */
		private function _entityAdded(e:Event):void
		{
			//Add to scene
			if(scene != null) scene.addEntity(e.data.entity);
			
			//Relay event
			dispatchEvent(e);
		}
		
		/**
		 * Called when an entity needs to be removed from the scene
		 * @param	e
		 */
		private function _entityRemoved(e:Event):void
		{
			//Remove from scene
			if(scene != null) scene.removeEntity(e.data.entity);
			
			//Relay event
			dispatchEvent(e);
		}
		
		/**
		 * Called when the camera updates its position
		 * @param	e
		 */
		private function _updatePosition(e:Event):void
		{
			//Relay to scene
			if(scene != null) this.scene.dispatchEvent(e);
		}
		
	}

}