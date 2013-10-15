package oni.editor 
{
	import oni.entities.EntityManager;
	import oni.Oni;
	import oni.rendering.SceneRenderer;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	/**
	 * The editor screen - not an actual screen, just an overlay
	 * @author Sam Hellawell
	 */
	public class EditorScreen extends Sprite
	{
		public var scene:SceneRenderer;
		
		public var entityManager:EntityManager;
		
		public function EditorScreen(scene:SceneRenderer, entityManager:EntityManager) 
		{
			//Set the scene
			this.scene = scene;
			
			//Set the entity manager
			this.entityManager = entityManager;
			
			//Setup basic UI elements
			addChild(new Quad(Starling.current.stage.stageWidth, 100, 0x0));
			
			var play:Shape = new Shape();
			play.x = 175;
			play.y = 10;
			play.graphics.beginFill(0xfffffff);
			play.graphics.moveTo(0, 0);
			play.graphics.lineTo(0, 30);
			play.graphics.lineTo(30, 15);
			play.graphics.lineTo(0, 0);
			play.graphics.endFill();
			addChild(play);
			
			var pause:Shape = new Shape();
			pause.x = play.x + play.width + 20;
			pause.y = play.y;
			pause.graphics.beginFill(0xfffffff);
			pause.graphics.drawRect(0, 0, 6, 30);
			pause.graphics.drawRect(15, 0, 6, 30);
			pause.graphics.endFill();
			addChild(pause);
			
			var reset:Shape = new Shape();
			reset.x = pause.x + pause.width + 20;
			reset.y = pause.y;
			
			reset.graphics.beginFill(0xfffffff);
			reset.graphics.moveTo(0, 0);
			reset.graphics.lineTo(0, 30);
			reset.graphics.lineTo(30, 15);
			reset.graphics.lineTo(0, 0);
		
			reset.graphics.drawRect(27, 0, 6, 30);
			
			reset.graphics.endFill();
			addChild(reset);
		}
		
		override public function set visible(value:Boolean):void 
		{
			//Show stats
			Starling.current.showStats = value;
			
			//Debug mode
			if (value === true)
			{
				//Enable debug for entities
				entityManager.dispatchEventWith(Oni.ENABLE_DEBUG);
			}
			else
			{
				//Disable debug for entities
				entityManager.dispatchEventWith(Oni.DISABLE_DEBUG);
			}
			
			//Set visible
			super.visible = value;
		}
		
	}

}