package oni.editor.ui.windows 
{
	import oni.components.ComponentManager;
	import oni.core.Scene;
	import oni.entities.EntityManager;
	import oni.Oni;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class SceneEditorWindow extends PropertyEditorWindow
	{
		private var _scene:Scene;
		
		private var _entities:EntityManager;
		
		private var _components:ComponentManager;
		
		public function SceneEditorWindow(scene:Scene, entities:EntityManager, components:ComponentManager) 
		{
			//Super
			super(500, 270, "Scene properties"); 
			
			//Set entity manager
			_entities = entities;
			
			//Set components
			_components = components;
			
			//Set scene
			this.scene = scene;
			
			//Listen for data update
			addEventListener(Oni.UPDATE_DATA, _onDataUpdated);
		}
		
		public function get scene():Scene
		{
			return _scene;
		}
		
		public function set scene(value:Scene):void
		{
			//Set the scene
			_scene = value;
			
			//Set default properties
			var ambientColour:uint = 0xFFFFFF;
			if (scene.lightMap != null && scene.lightMap.ambientLight != null)
			{
				ambientColour = scene.lightMap.ambientLight.colour;
			}
			
			//Set properties
			properties = [//Metadata
						  { name: "name", type: "text", value: "" },
						  
						  //Lighting
						  { name: "lighting", type: "label" },
						  { name: "ambient colour", type: "colour", value: ambientColour },
						  
						  //Physics
						  { name: "physics", type: "label" },
						  { name: "physics enabled", type: "boolean", value: _entities.physicsEnabled },
						  { name: "gravity", type: "point", value: _entities.gravity }
						 ];
		}
		
		private function _onDataUpdated(e:Event):void
		{
			//Check what data to update
			switch(e.data.name)
			{
				case "ambient colour":
					if (scene.lightMap != null && scene.lightMap.ambientLight != null)
					{
						scene.lightMap.ambientLight.colour = uint(e.data.value);
					}
					break;
				
				case "physics enabled":
					_entities.physicsEnabled = Boolean(e.data.value);
					break;
				
				case "gravity":
					_entities.gravity = e.data.value;
					break;
			}
		}
		
	}

}