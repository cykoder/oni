package oni.editor 
{
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.describeType;
	import oni.components.weather.WeatherSystem;
	import oni.assets.AssetManager;
	import oni.editor.ui.Icon;
	import oni.editor.ui.Button;
	import oni.editor.ui.VectorEditor;
	import oni.editor.ui.windows.ListImageGridWindow;
	import oni.editor.ui.windows.PropertyEditorWindow;
	import oni.editor.ui.windows.SceneEditorWindow;
	import oni.editor.ui.windows.Window;
	import oni.entities.Entity;
	import oni.entities.EntityManager;
	import oni.entities.environment.FluidBody;
	import oni.entities.environment.SmartTexture;
	import oni.entities.environment.StaticTexture;
	import oni.entities.lights.AmbientLight;
	import oni.entities.lights.Light;
	import oni.entities.lights.PointLight;
	import oni.entities.lights.TexturedLight;
	import oni.entities.platformer.Character;
	import oni.entities.scene.Prop;
	import oni.Oni;
	import oni.core.Scene;
	import oni.screens.GameScreen;
	import oni.utils.Platform;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Shape;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.events.KeyboardEvent;
	/**
	 * The editor screen - not an actual screen, just an overlay
	 * @author Sam Hellawell
	 */
	public class EditorScreen extends GameScreen
	{
		private var _pickIcon:Icon, _moveIcon:Icon, _editIcon:Icon,
					_deleteIcon:Icon, _lockIcon:Icon, _lightIcon:Icon,
					_lockRotationIcon:Icon, _lockScaleIcon:Icon;
		
		private var _addStaticButton:Button, _addPropButton:Button, _addEntityButton:Button,
					_addLightButton:Button, _sceneButton:Button, _optionsButton:Button,
					_testButton:Button, _fileButton:Button, _smartTextureButton:Button;
		
		private var _selectedIcon:Icon, _previousIcon:Icon;
		
		private var _staticWindow:ListImageGridWindow, _propWindow:ListImageGridWindow,
					_entityPropertiesWindow:PropertyEditorWindow, _scenePropertiesWindow:PropertyEditorWindow,
					_smartTexturesWindow:ListImageGridWindow;
		
		private var _vectorEditor:VectorEditor;
					
		private var _selectedEntities:Vector.<Entity>;
		
		private var _canClone:Boolean = true;
		
		private var _selectQuad:Shape;
		
		private var _dragStartPoint:Point, _selectionRect:Rectangle = new Rectangle();
		
		public function EditorScreen(oni:Oni) 
		{
			//Super
			super(oni, true);
			
			//Pause!
			this.paused = true;
			
			//Create a select quad
			_selectQuad = new Shape();
			_selectQuad.alpha = 0.75;
			_selectQuad.touchable = false;
			addChild(_selectQuad);
			
			//Create a selected entities vector
			_selectedEntities = new Vector.<Entity>();
			
			//Create a black top bar
			addChild(new Quad(Starling.current.stage.stageWidth, 100, 0x0));
			
			//Create a move icon
			_moveIcon = new Icon("move");
			_moveIcon.x = 4;
			_moveIcon.y = 4;
			_moveIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_moveIcon);
			
			//Create a pick icon
			_pickIcon = new Icon("pick");
			_pickIcon.x = _moveIcon.x + 47;
			_pickIcon.y = 4;
			_pickIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_pickIcon);
			
			//Create a edit icon
			_editIcon = new Icon("edit");
			_editIcon.x = _moveIcon.x;
			_editIcon.y = 4 + 47;
			_editIcon.disabled = true;
			_editIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_editIcon);
			
			//Create a delete icon
			_deleteIcon = new Icon("delete");
			_deleteIcon.x = _pickIcon.x;
			_deleteIcon.y = _editIcon.y;
			_deleteIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_deleteIcon);
			
			//Create a light icon
			_lightIcon = new Icon("light", true);
			_lightIcon.x = _deleteIcon.x+47;
			_lightIcon.y = _pickIcon.y;
			//_lightIcon.selected = true;
			_lightIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_lightIcon);
			
			//Create a lock icon
			_lockIcon = new Icon("lock", true);
			_lockIcon.x = _lightIcon.x;
			_lockIcon.y = _editIcon.y;
			_lockIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_lockIcon);
			
			//Create a lock rotation icon
			_lockRotationIcon = new Icon("lockrotation", true);
			_lockRotationIcon.x = _lightIcon.x + 47;
			_lockRotationIcon.y = _pickIcon.y;
			_lockRotationIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_lockRotationIcon);
			
			//Create a lock scale icon
			_lockScaleIcon = new Icon("lockscale", true);
			_lockScaleIcon.x = _lockRotationIcon.x;
			_lockScaleIcon.y = _lockRotationIcon.y + 47;
			_lockScaleIcon.addEventListener(Icon.SELECTED, _onIconSelected);
			addChild(_lockScaleIcon);
			
			//Create an add static texture button
			_addStaticButton = new Button("add", "static");
			_addStaticButton.x = _lockRotationIcon.x + 47;
			_addStaticButton.y = _lightIcon.y;
			_addStaticButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_addStaticButton);
			
			//Create an add prop button
			_addPropButton = new Button("add", "prop");
			_addPropButton.x = _addStaticButton.x;
			_addPropButton.y = _addStaticButton.y + 47;
			_addPropButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_addPropButton);
			
			//Create an add entity button
			_addEntityButton = new Button("add", "entity");
			_addEntityButton.x = _addStaticButton.x + 139;
			_addEntityButton.y = _addStaticButton.y;
			_addEntityButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_addEntityButton);
			
			//Create an add light button
			_addLightButton = new Button("add", "light");
			_addLightButton.x = _addEntityButton.x;
			_addLightButton.y = _addPropButton.y;
			_addLightButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_addLightButton);
			
			//Create a smart texture button
			_smartTextureButton = new Button("add", "smart");
			_smartTextureButton.x = _addLightButton.x + 139;
			_smartTextureButton.y = _addEntityButton.y;
			_smartTextureButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_smartTextureButton);
			
			//Create a scene button
			_sceneButton = new Button("cog", "scene");
			_sceneButton.x = _addLightButton.x + 139 + 139;
			_sceneButton.y = _addEntityButton.y;
			_sceneButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_sceneButton);
			
			//Create an options button
			_optionsButton = new Button("cog", "options");
			_optionsButton.x = _sceneButton.x;
			_optionsButton.y = _addLightButton.y;
			_optionsButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_optionsButton);
			
			//Create a test scene button
			_testButton = new Button("ironman", "test");
			_testButton.x = _optionsButton.x + 139;
			_testButton.y = _sceneButton.y;
			_testButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_testButton);
			
			//Create a file button
			_fileButton = new Button("file", "menu");
			_fileButton.x = _testButton.x;
			_fileButton.y = _optionsButton.y;
			_fileButton.addEventListener(Button.PRESSED, _onButtonPressed);
			addChild(_fileButton);
			
			//Create a vector editor
			_vectorEditor = new VectorEditor();
			
			//Remove camera limit
			camera.limit = false;
			
			//Select the pick icon by default
			_pickIcon.select();
			
			//Listen for added to stage
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			//Get assets list
			var assets:XMLList = describeType(AssetManager.assetStore).constant;
			var name:String;
			var _staticData:Array = [], _propData:Array = [], _smartTextureData:Array = [];
			
			//Parse all assets
			for each(var asset:XML in assets)
			{
				//trace(name);
				name = String(asset.@name);
				if (name.substr(0, 7) == "static_" && name.lastIndexOf("Atlas") == -1) //Static texture
				{
					_staticData.push({
						name: name.substr(7),
						textures: AssetManager.getTextureAtlas(name).getTextures(),
						names: AssetManager.getTextureAtlas(name).getNames()
					});
				}
				else if (name.substr(0, 6) == "scene_" && name.lastIndexOf("Atlas") == -1) //Static texture
				{
					_propData.push({
						name: name.substr(6),
						textures: AssetManager.getTextureAtlas(name).getTextures(),
						names: AssetManager.getTextureAtlas(name).getNames()
					});
					
					_staticData.push({
						name: "prop_" + name.substr(6),
						textures: AssetManager.getTextureAtlas(name).getTextures(),
						names: AssetManager.getTextureAtlas(name).getNames()
					});
				}
				else if (name.substr(0, 13) == "smarttexture_" && name.substr(-6, 6) == "_floor") //Static texture
				{
					//name.substr(13, name.length-12)
				}
			}
			
			//Create a static window
			_staticWindow = new ListImageGridWindow(860, 486, "Static textures", _staticData);
			_staticWindow.addEventListener(ListImageGridWindow.SELECTED, _onGridItemSelected);
			_staticWindow.visible = false;
			addChild(_staticWindow);
			
			//Create a prop window
			_propWindow = new ListImageGridWindow(860, 486, "Props", _propData);
			_propWindow.addEventListener(ListImageGridWindow.SELECTED, _onGridItemSelected);
			_propWindow.visible = false;
			addChild(_propWindow);
			
			//Create an entity properties window
			_entityPropertiesWindow = new PropertyEditorWindow(400, 270, "Entity properties");
			_entityPropertiesWindow.visible = false;
			_entityPropertiesWindow.addEventListener(Oni.UPDATE_DATA, _onEntityDataUpdated);
			addChild(_entityPropertiesWindow);
			
			//Load a level!
			//scene = new Scene(false, 0x35342A);
			scene = Scene.deserialize(JSON.parse("{\"lighting\":true,\"physicsEnabled\":true,\"background\":\"0x35342A\",\"name\":null,\"components\":[],\"entities\":[{\"height\":110,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":-37,\"y\":81,\"rotation\":0,\"z\":0.5,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"windows\",\"atlas\":\"static_factory\",\"z\":0.5,\"serializable\":true,\"pivot\":false},\"width\":223.5},{\"height\":110,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":292,\"y\":81,\"rotation\":0,\"z\":0.5,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"windows\",\"atlas\":\"static_factory\",\"z\":0.5,\"serializable\":true,\"pivot\":false},\"width\":223.5},{\"height\":110,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":642,\"y\":81,\"rotation\":0,\"z\":0.5,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"windows\",\"atlas\":\"static_factory\",\"z\":0.5,\"serializable\":true,\"pivot\":false},\"width\":223.5},{\"height\":110,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":971,\"y\":81,\"rotation\":0,\"z\":0.5,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"windows\",\"atlas\":\"static_factory\",\"z\":0.5,\"serializable\":true,\"pivot\":false},\"width\":223.5},{\"height\":154.5,\"scaleY\":1.83646616541,\"scaleX\":1.83646616541,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":772.5,\"y\":330.5,\"rotation\":0,\"z\":0.8,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"z\":0.8,\"serializable\":true,\"scaleX\":1.83646616541,\"atlas\":\"static_factory\",\"scaleY\":1.83646616541,\"texture\":\"tub_machine_3\",\"pivot\":true},\"width\":531.5},{\"height\":62,\"scaleY\":2.18867924528,\"scaleX\":2.18867924528,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":374,\"y\":227,\"rotation\":0,\"z\":0.81,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"z\":0.81,\"serializable\":true,\"scaleX\":2.18867924528,\"atlas\":\"static_factory\",\"scaleY\":2.18867924528,\"texture\":\"console_component_two\",\"pivot\":true},\"width\":53.5},{\"height\":267,\"scaleY\":0.7659574468,\"scaleX\":0.7659574468,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":249,\"y\":354,\"rotation\":0,\"z\":0.85,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"z\":0.85,\"serializable\":true,\"scaleX\":0.7659574468,\"atlas\":\"static_factory\",\"scaleY\":0.7659574468,\"texture\":\"generic_machine_1c\",\"pivot\":true},\"width\":281.5},{\"height\":402,\"scaleY\":1.09828009828,\"scaleX\":1.09828009828,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":582.5,\"y\":222.5,\"rotation\":0,\"z\":0.9,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"z\":0.9,\"serializable\":true,\"scaleX\":1.09828009828,\"atlas\":\"static_factory\",\"scaleY\":1.09828009828,\"texture\":\"tub_machine_4\",\"pivot\":true},\"width\":407},{\"height\":168,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":128,\"y\":550,\"rotation\":0,\"z\":0.99,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"under_support\",\"atlas\":\"static_factory\",\"z\":0.99,\"serializable\":true,\"pivot\":true},\"width\":238},{\"height\":168,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":420,\"y\":550,\"rotation\":0,\"z\":0.99,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"under_support\",\"atlas\":\"static_factory\",\"z\":0.99,\"serializable\":true,\"pivot\":true},\"width\":238},{\"height\":168,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":710,\"y\":550,\"rotation\":0,\"z\":0.99,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"under_support\",\"atlas\":\"static_factory\",\"z\":0.99,\"serializable\":true,\"pivot\":true},\"width\":238},{\"height\":168,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":999,\"y\":550,\"rotation\":0,\"z\":0.99,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"under_support\",\"atlas\":\"static_factory\",\"z\":0.99,\"serializable\":true,\"pivot\":true},\"width\":238},{\"height\":20,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::SmartTexture\",\"x\":-3,\"y\":440,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"points\":[{\"y\":0,\"x\":0},{\"y\":0,\"x\":512},{\"y\":0,\"x\":1024},{\"y\":0,\"x\":1280}],\"physics\":true,\"texture\":\"factory_floor_one\",\"serializable\":true},\"width\":1300},{\"height\":20,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::SmartTexture\",\"x\":-3,\"y\":440,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"points\":[{\"y\":0,\"x\":0},{\"y\":0,\"x\":512},{\"y\":0,\"x\":1024},{\"y\":0,\"x\":1280}],\"physics\":false,\"texture\":\"factory_rail_one\",\"serializable\":true},\"width\":1300},{\"height\":278,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":156,\"y\":302,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"static_factory\",\"texture\":\"vent_machine\",\"serializable\":true,\"pivot\":true},\"width\":291},{\"height\":91,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":652,\"y\":394,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"static_factory\",\"texture\":\"console_component_eleven\",\"serializable\":true,\"pivot\":true},\"width\":50},{\"height\":73.5,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":584,\"y\":330,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"static_factory\",\"texture\":\"console_component_seven\",\"serializable\":true,\"pivot\":true},\"width\":121.5},{\"height\":73,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":585,\"y\":401,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"static_factory\",\"texture\":\"console_box_blue\",\"serializable\":true,\"pivot\":true},\"width\":101},{\"height\":73.5,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":795,\"y\":390,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"rotation\":0,\"texture\":\"lever_handle\",\"serializable\":true,\"pivot\":true},\"width\":12},{\"height\":21.5,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":795,\"y\":429,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"texture\":\"lever_box\",\"serializable\":true,\"pivot\":true},\"width\":99},{\"height\":66.5,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":919,\"y\":473,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"texture\":\"girder_dock\",\"serializable\":true,\"pivot\":true},\"width\":209.5},{\"height\":338,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":918,\"y\":339,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"texture\":\"rising_girder\",\"serializable\":true,\"pivot\":true},\"width\":67},{\"height\":10,\"scaleY\":20,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":486,\"y\":100,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"scaleY\":20,\"texture\":\"light_wire\",\"serializable\":true,\"pivot\":true},\"width\":3},{\"height\":61.5,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":486,\"y\":191,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"texture\":\"factory_light_one\",\"serializable\":true,\"pivot\":true},\"width\":86.5},{\"height\":10,\"scaleY\":20,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":685,\"y\":100,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"scaleY\":20,\"texture\":\"light_wire\",\"serializable\":true,\"pivot\":true},\"width\":3},{\"height\":61.5,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::StaticTexture\",\"x\":685,\"y\":191,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"atlas\":\"scene_factory\",\"texture\":\"factory_light_one\",\"serializable\":true,\"pivot\":true},\"width\":86.5},{\"height\":20,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::SmartTexture\",\"x\":-3,\"y\":520,\"rotation\":0,\"z\":1.05,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"texture\":\"pipe_one\",\"points\":[{\"y\":0,\"x\":0},{\"y\":0,\"x\":512},{\"y\":0,\"x\":1024},{\"y\":0,\"x\":1280}],\"physics\":false,\"z\":1.05,\"serializable\":true},\"width\":1300},{\"height\":0,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"add\",\"className\":\"oni.entities.lights::AmbientLight\",\"x\":0,\"y\":0,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"colour\":8092025,\"blendMode\":\"add\",\"intensity\":1,\"serializable\":true},\"width\":0},{\"height\":281,\"scaleY\":2,\"scaleX\":1.9,\"blendMode\":\"add\",\"className\":\"oni.entities.lights::TexturedLight\",\"x\":315,\"y\":180,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"scaleX\":1.9,\"scaleY\":2,\"texture\":\"spotlight_double\",\"serializable\":true,\"colour\":14669513,\"atlas\":\"lights\",\"blendMode\":\"add\",\"intensity\":0.5},\"width\":532},{\"height\":388.4623465145796,\"scaleY\":1.5121832476842476,\"scaleX\":1.5121832476842476,\"blendMode\":\"add\",\"className\":\"oni.entities.lights::PointLight\",\"x\":279.75,\"y\":234.75,\"rotation\":-0.003476391879270402,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"colour\":14669513,\"radius\":256,\"blendMode\":\"add\",\"intensity\":1,\"serializable\":true},\"width\":388.4623465145797},{\"height\":130,\"scaleY\":1,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.platformer::Character\",\"x\":130,\"y\":309.25,\"rotation\":0,\"z\":1,\"scrollX\":true,\"scrollY\":true,\"cull\":true,\"params\":{\"bodyHeight\":128,\"physics\":true,\"bodyWidth\":64,\"serializable\":true},\"width\":70}],\"gravity\":{\"y\":600,\"x\":0,\"length\":600}}"), entities, components);
			//scene = Scene.deserialize(JSON.parse("{\"gravity\":{\"y\":600,\"x\":0,\"length\":600},\"physicsEnabled\":true,\"entities\":[{\"height\":154.5,\"scrollY\":true,\"params\":{\"pivot\":true,\"texture\":\"tub_machine_3\",\"atlas\":\"static_factory\"},\"scaleX\":1.323775228708114,\"blendMode\":\"auto\",\"x\":588.4500000000054,\"y\":318.44999999999857,\"rotation\":0,\"z\":0.8,\"className\":\"oni.entities.environment::StaticTexture\",\"cull\":true,\"scrollX\":true,\"scaleY\":1.323775228708114,\"width\":531.5},{\"height\":62,\"scrollY\":true,\"params\":{\"pivot\":true,\"texture\":\"console_component_two\",\"atlas\":\"static_factory\"},\"scaleX\":1.231998377078595,\"blendMode\":\"auto\",\"x\":291.9732790444715,\"y\":254.15906618080263,\"rotation\":0,\"z\":0.81,\"className\":\"oni.entities.environment::StaticTexture\",\"cull\":true,\"scrollX\":true,\"scaleY\":1.231998377078595,\"width\":53.5},{\"height\":267,\"scrollY\":true,\"params\":{\"pivot\":true,\"texture\":\"generic_machine_1c\",\"atlas\":\"static_factory\"},\"scaleX\":0.5927775162964628,\"blendMode\":\"auto\",\"x\":191.8828183803399,\"y\":320.16172447583585,\"rotation\":0,\"z\":0.85,\"className\":\"oni.entities.environment::StaticTexture\",\"cull\":true,\"scrollX\":true,\"scaleY\":0.5927775162964628,\"width\":281.5},{\"height\":402,\"scrollY\":true,\"params\":{\"pivot\":true,\"texture\":\"tub_machine_4\",\"atlas\":\"static_factory\"},\"scaleX\":0.7925984985747947,\"blendMode\":\"auto\",\"x\":436.2916509780974,\"y\":242.61841118486404,\"rotation\":0,\"z\":0.86,\"className\":\"oni.entities.environment::StaticTexture\",\"cull\":true,\"scrollX\":true,\"scaleY\":0.7925984985747947,\"width\":407},{\"height\":62,\"scrollY\":true,\"params\":{\"pivot\":true,\"texture\":\"console_component_one\",\"atlas\":\"static_factory\"},\"scaleX\":1,\"blendMode\":\"auto\",\"x\":276.6719613003003,\"y\":367.33821056215055,\"rotation\":0,\"z\":0.9,\"className\":\"oni.entities.environment::StaticTexture\",\"cull\":true,\"scrollX\":true,\"scaleY\":1,\"width\":50},{\"height\":66,\"scrollY\":true,\"params\":{\"pivot\":true,\"texture\":\"console_component_five\",\"atlas\":\"static_factory\"},\"scaleX\":1,\"blendMode\":\"auto\",\"x\":275.35607244618933,\"y\":307.3222369062186,\"rotation\":0,\"z\":0.9,\"className\":\"oni.entities.environment::StaticTexture\",\"cull\":true,\"scrollX\":true,\"scaleY\":1,\"width\":89}],\"lighting\":true,\"components\":[]}"), entities, components);
			//scene = Scene.deserialize(JSON.parse("{\"entities\":[{\"height\":\"stageHeight\",\"scrollX\":true,\"className\":\"oni.entities.environment::StaticTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":0,\"params\":{\"texture\":\"background_sky\",\"atlas\":null,\"pivot\":false},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":-1,\"y\":0,\"blendMode\":\"none\",\"width\":\"stageWidth\"},{\"height\":0,\"scrollX\":true,\"className\":\"oni.entities.environment::SmartTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":0,\"params\":{\"texture\":\"factory_floor_two\",\"physicsEnabled\":true,\"points\":[{\"y\":0,\"x\":0,\"length\":0},{\"y\":0,\"x\":1920,\"length\":1920}]},\"scrollY\":true,\"rotation\":0,\"cull\":false,\"z\":1,\"y\":500,\"blendMode\":\"auto\",\"width\":1920},{\"height\":0,\"scrollX\":true,\"className\":\"oni.entities.environment::SmartTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":0,\"params\":{\"texture\":\"factory_rail_one\",\"points\":[{\"y\":0,\"x\":0,\"length\":0},{\"y\":0,\"x\":1920,\"length\":1920}],\"physicsEnabled\":false},\"scrollY\":true,\"rotation\":0,\"cull\":false,\"z\":1,\"y\":500,\"blendMode\":\"auto\",\"width\":1920},{\"height\":402,\"scrollX\":true,\"className\":\"oni.entities.environment::StaticTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":-57.5,\"params\":{\"texture\":\"tub_machine_4\",\"atlas\":\"static_factory\",\"pivot\":true},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":0.85,\"y\":306.5,\"blendMode\":\"auto\",\"width\":407},{\"height\":154.5,\"scrollX\":true,\"className\":\"oni.entities.environment::StaticTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":235.75,\"params\":{\"texture\":\"tub_machine_3\",\"atlas\":\"static_factory\",\"pivot\":true},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":0.849,\"y\":451.25,\"blendMode\":\"auto\",\"width\":531.5},{\"height\":267.5,\"scrollX\":true,\"className\":\"oni.entities.environment::StaticTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":607.5,\"params\":{\"texture\":\"generic_machine_1a\",\"atlas\":\"static_factory\",\"pivot\":true},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":0.85,\"y\":388.75,\"blendMode\":\"auto\",\"width\":282},{\"height\":156,\"scrollX\":true,\"className\":\"oni.entities.environment::StaticTexture\",\"scaleX\":1,\"scaleY\":1,\"x\":360.5,\"params\":{\"texture\":\"standing_node_2\",\"atlas\":\"static_factory\",\"pivot\":true},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":423,\"blendMode\":\"auto\",\"width\":121},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"klankywanky\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"wardenjordan\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":64,\"scrollX\":true,\"className\":\"oni.entities.scene::Prop\",\"scaleX\":1,\"scaleY\":1,\"x\":600,\"params\":{\"physicsEnabled\":true,\"atlas\":\"factory\",\"name\":\"klankywanky\"},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"auto\",\"width\":64},{\"height\":0,\"scrollX\":true,\"className\":\"oni.entities.lights::AmbientLight\",\"scaleX\":1,\"scaleY\":1,\"x\":0,\"params\":{\"intensity\":1,\"colour\":51},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":0,\"blendMode\":\"add\",\"width\":0},{\"height\":256,\"scrollX\":true,\"className\":\"oni.entities.lights::PointLight\",\"scaleX\":1,\"scaleY\":1,\"x\":300,\"params\":{\"intensity\":0.5,\"radius\":256,\"colour\":16777215},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":200,\"blendMode\":\"add\",\"width\":256},{\"height\":128,\"scrollX\":true,\"className\":\"oni.entities.platformer::Character\",\"scaleX\":1,\"scaleY\":1,\"x\":300,\"params\":{\"bodyHeight\":128,\"physicsEnabled\":true,\"bodyWidth\":64},\"scrollY\":true,\"rotation\":0,\"cull\":true,\"z\":1,\"y\":100,\"blendMode\":\"auto\",\"width\":64}],\"components\":[{\"params\":{\"rain\":{},\"clouds\":[{\"perlinBase\":100,\"z\":-1,\"octaves\":8,\"intensity\":1,\"windDirection\":{\"y\":0,\"x\":-0.025,\"length\":0.025},\"spread\":15},{\"perlinBase\":100,\"z\":-1,\"octaves\":8,\"intensity\":1,\"windDirection\":{\"y\":0,\"x\":0.05,\"length\":0.05},\"spread\":50}],\"haze\":{\"texture\":\"weather_haze\",\"colour\":9795660,\"intensity\":0.5,\"enabled\":false,\"z\":0.86,\"atlas\":null,\"pivot\":false}},\"className\":\"oni.components.weather::WeatherSystem\"}],\"lighting\":true}"), entities, components);
			//scene = Scene.deserialize(JSON.parse("{\"lighting\":false,\"entities\":[{\"scrollX\":true,\"height\":\"stageHeight\",\"cull\":true,\"scaleX\":1,\"blendMode\":\"none\",\"className\":\"oni.entities.environment::StaticTexture\",\"params\":{\"pivot\":false,\"texture\":\"background_sky\",\"atlas\":null},\"x\":0,\"y\":0,\"scrollY\":true,\"z\":-1,\"rotation\":0,\"scaleY\":1,\"width\":\"stageWidth\"},{\"scrollX\":true,\"height\":512,\"cull\":true,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.environment::SmartTexture\",\"params\":{\"physicsEnabled\":true,\"points\":[{\"y\":0,\"x\":0},{\"y\":0,\"x\":336},{\"control\":{\"y\":0,\"x\":400},\"y\":64,\"x\":400},{\"y\":256,\"x\":400},{\"y\":256,\"x\":900},{\"y\":64,\"x\":900},{\"control\":{\"y\":0,\"x\":900},\"y\":0,\"x\":964},{\"y\":0,\"x\":1280},{\"y\":512,\"x\":1280},{\"y\":512,\"x\":0},{\"y\":0,\"x\":0}],\"texture\":\"grass\"},\"x\":-160,\"y\":360,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":1280},{\"scrollX\":true,\"height\":64,\"cull\":true,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.scene::Prop\",\"params\":{\"atlas\":\"factory\",\"physicsEnabled\":true,\"name\":\"wardenjordan\"},\"x\":350,\"y\":-200,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":64},{\"scrollX\":true,\"height\":64,\"cull\":true,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.scene::Prop\",\"params\":{\"atlas\":\"factory\",\"physicsEnabled\":true,\"name\":\"klankywanky\"},\"x\":450,\"y\":-200,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":64},{\"scrollX\":true,\"height\":64,\"cull\":true,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.scene::Prop\",\"params\":{\"atlas\":\"factory\",\"physicsEnabled\":true,\"name\":\"klankywanky\"},\"x\":550,\"y\":-200,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":64},{\"scrollX\":true,\"height\":64,\"cull\":true,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.scene::Prop\",\"params\":{\"atlas\":\"factory\",\"physicsEnabled\":true,\"name\":\"wardenjordan\"},\"x\":650,\"y\":-200,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":64},{\"scrollX\":true,\"height\":128,\"cull\":true,\"scaleX\":1,\"blendMode\":\"auto\",\"className\":\"oni.entities.platformer::Character\",\"params\":{\"bodyHeight\":128,\"physicsEnabled\":true,\"bodyWidth\":64},\"x\":100,\"y\":100,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":64},{\"scrollX\":true,\"height\":448,\"cull\":false,\"scaleX\":1,\"blendMode\":\"multiply\",\"className\":\"oni.entities.environment::FluidBody\",\"params\":{\"waveQuality\":1,\"yOffset\":256,\"height\":192,\"density\":3,\"viscosity\":5,\"splashDampening\":0.5,\"topColor\":7317759,\"physicsEnabled\":true,\"bottomColor\":3880,\"width\":500},\"x\":240,\"y\":420,\"scrollY\":true,\"z\":1,\"rotation\":0,\"scaleY\":1,\"width\":500}],\"physicsEnabled\":true,\"components\":[],\"gravity\":{\"y\":600,\"x\":0,\"length\":600}}"), entities, components);

			/*components.add(new WeatherSystem(scene, {
				haze: { z: 0.97, intensity: 0.7, colour: 0x5E4F35 }
			}));*/
			
			//Create a scene properties window
			_scenePropertiesWindow = new SceneEditorWindow(scene, entities, components);
			_scenePropertiesWindow.visible = false;
			addChild(_scenePropertiesWindow);
			
			//trace(JSON.stringify(scene.serialize(entities, components)));
		}
		
		private function _onGridItemSelected(e:Event):void
		{
			//Check for data
			if (e.data != null)
			{
				//Entity to add
				var entity:Entity;
				
				//Check what to add
				switch(e.currentTarget)
				{
					case _staticWindow:
						entity = new StaticTexture({atlas: "static_" + _staticWindow.selectedLabel, texture: e.data.name});
						break;
						
					case _propWindow:
						entity = new Prop({atlas: _propWindow.selectedLabel, name: e.data.name});
						break;
				}
				
				//Position
				entity.x = stage.stageWidth / 2 - entity.width / 2 + ((camera.x + entity.width / 2) / camera.z);
				entity.y = stage.stageHeight / 2 - entity.height / 2 + ((camera.y + entity.height / 2) / camera.z);
				
				//Add
				entities.add(entity);
				
				//Close window
				(e.currentTarget as Window).visible = false;
			}
		}
		
		private function _onAddedToStage(e:Event):void
		{
			//Remove stage added listener
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			//Listen for stage touch
			stage.addEventListener(TouchEvent.TOUCH, _onStageTouch);
			
			//Listen for keyboard controls
			if (Platform.isDesktop())
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
				Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			}
		}
		
		private function _onStageTouch(e:TouchEvent):void
		{
			//Check if any windows are open
			if (!_windowsVisible)
			{
				//Get movement touches
				var map:DisplayObjectContainer;
				var entity:Entity;
				var delta:Point;
				var testRectangle:Rectangle = new Rectangle();
				var i:uint;
				var touches:Vector.<Touch> = e.getTouches(stage);
				
				//One finger touches
				if (touches.length == 1)
				{
					//Pan the camera
					if (_moveIcon.selected && touches[0].phase == TouchPhase.MOVED)
					{
						delta = touches[0].getMovement(stage);
						camera.x -= delta.x * 4;
						camera.y -= delta.y * 4;
					}
					else if (_pickIcon.selected)
					{
						if (touches[0].phase == TouchPhase.BEGAN) //First click
						{
							//Get touch location
							_dragStartPoint = touches[0].getLocation(this);
							_dragStartPoint.x += camera.x;
							_dragStartPoint.y += camera.y;
							_dragStartPoint.x /= camera.z;
							_dragStartPoint.y /= camera.z;
							if (_dragStartPoint.y > 100)
							{
								//Loop through entities
								map = scene.diffuseMap;
								if (_lightIcon.selected) map = scene.lightMap;
								for (i = map.numChildren-1; i > 0; i--)
								{
									//Get entity
									entity = map.getChildAt(i) as Entity;
									
									//Check if it is even visible
									if (entity != null && entity.visible)
									{
										//Set the test rectangle
										testRectangle.setTo(entity.x, entity.y, entity.cullBounds.width, entity.cullBounds.height);
										
										//Check if we clicked on an entity
										if (entity.bounds.containsPoint(_dragStartPoint))
										{
											if (_selectedEntities.indexOf(entity) == -1)
											{
												//Deselect all
												_deselectAll();
												
												//Select it!
												entity.showBounds = true;
												_selectedEntities.push(entity);
											}
											
											//Set drag start point to null
											_dragStartPoint = null;
											
											//Come out of the loop
											break;
										}
									}
								}
								
								//Start dragging
								if (_dragStartPoint != null)
								{
									//Set rectangle position
									_selectionRect.x = _dragStartPoint.x;
									_selectionRect.y = _dragStartPoint.y;
									
									//Deselect all entities
									_deselectAll();
								}
							}
						}
						else if(_dragStartPoint == null && touches[0].phase == TouchPhase.MOVED) //Not dragging out select rectangle
						{
							//Move every entity selected
							if (e.shiftKey && _canClone) //Clone
							{
								var clonedEntities:Vector.<Entity> = new Vector.<Entity>();
								for (i = 0; i < _selectedEntities.length; i++)
								{
									//Clone it
									var clonedEntity:Entity = Entity.deserialize(entities.get(i).serialize());
									clonedEntity.showBounds = true;
									
									//Add the new entity
									clonedEntities.push(clonedEntity);
									entities.add(clonedEntity);
								}
								
								//Deselect all other entities
								_deselectAll();
								
								//Set selected entities
								_selectedEntities = clonedEntities;
								
								//Set can clone to false
								_canClone = false;
							}
							else if(_vectorEditor.parent == null) //Move
							{
								//Get delta
								delta = touches[0].getMovement(stage);
								delta.x /= camera.z;
								delta.y /= camera.z;
								
								//Loop through entities
								for (i = 0; i < _selectedEntities.length; i++)
								{
									//Set position
									_selectedEntities[i].x += delta.x;
									_selectedEntities[i].y += delta.y;
								}
							}
						}
						else if(_dragStartPoint != null && touches[0].phase == TouchPhase.MOVED) //Dragging out select rectangle
						{
							//Get new drag position
							var dragPoint:Point = touches[0].getLocation(this);
							
							//Set rectangle width and height
							_selectionRect.width = dragPoint.x - _dragStartPoint.x;
							_selectionRect.height = dragPoint.y - _dragStartPoint.y;
							
							//Draw rect
							_selectQuad.graphics.clear();
							_selectQuad.graphics.lineStyle(2, 0x00FF00);
							_selectQuad.graphics.beginFill(0xFFFFFF, 0.25);
							_selectQuad.graphics.drawRect(_selectionRect.x, _selectionRect.y, _selectionRect.width, _selectionRect.height);
							_selectQuad.graphics.endFill();
						}
						else if (touches[0].phase == TouchPhase.ENDED &&
								_dragStartPoint != null &&
								_selectionRect.x == _dragStartPoint.x &&
								_selectionRect.y == _dragStartPoint.y)
						{
							//Clear selection
							_dragStartPoint = null;
							_selectQuad.graphics.clear();
							
							//Resize based on camera zoom
							_selectionRect.x /= camera.z;
							_selectionRect.y /= camera.z;
							_selectionRect.width /= camera.z;
							_selectionRect.height /= camera.z;
							
							//Loop through entities
							map = scene.diffuseMap;
							if (_lightIcon.selected) map = scene.lightMap;
							for (i = map.numChildren-1; i > 0; i--)
							{
								//Get entity
								entity = map.getChildAt(i) as Entity;
								
								//Check if it is even visible
								if (entity.visible && !(entity is SmartTexture))
								{
									//Set the test rectangle
									testRectangle.setTo(entity.x, entity.y, entity.cullBounds.width, entity.cullBounds.height);
									
									//Check if entity is within the selection area
									if (_selectionRect.intersects(testRectangle))
									{
										//Select it!
										entity.showBounds = true;
										_selectedEntities.push(entity);
									}
								}
							}
							
							//Reset selection rectangle
							_selectionRect.setTo(0, 0, 0, 0);
						}
					}
				}            
				else if (touches.length == 2 &&
						 touches[0].phase == TouchPhase.MOVED &&
						 touches[1].phase == TouchPhase.MOVED) //Pinch gesture
				{
					//Get current and previous positions
					var currentPosA:Point  = touches[0].getLocation(stage);
					var previousPosA:Point = touches[0].getPreviousLocation(stage);
					var currentPosB:Point  = touches[1].getLocation(stage);
					var previousPosB:Point = touches[1].getPreviousLocation(stage);
					
					//Calculate vector
					var currentVector:Point  = currentPosA.subtract(currentPosB);
					var previousVector:Point = previousPosA.subtract(previousPosB);

					//Get the size difference
					var sizeDiff:Number = currentVector.length / previousVector.length;
					
					//Zoom the camera
					if (_moveIcon.selected) //Zoom camera
					{
						camera.z *= sizeDiff;
					}
					else if (_pickIcon.selected && _selectedEntities.length > 0) //Rotate and scale entities
					{
						for (i = 0; i < _selectedEntities.length; i++)
						{
							if (!_lockRotationIcon.selected)
							{
								_selectedEntities[i].rotation += Math.atan2(currentVector.y, currentVector.x) - Math.atan2(previousVector.y, previousVector.x);
							}
							if (!_lockScaleIcon.selected)
							{
								_selectedEntities[i].scaleX *= sizeDiff;
								_selectedEntities[i].scaleY *= sizeDiff;
							}
						}
					}
				}
			}
		}
		
		private function _deselectAll():void
		{
			//Remove the vector editor
			if (_vectorEditor.parent != null)
			{
				_vectorEditor.removeFromParent();
			}
				
			//Loop until length == 0
			while (_selectedEntities.length > 0)
			{
				//Pop last entity, don't show bounds
				_selectedEntities.pop().showBounds = false;
			}
			
			//Disable edit
			_editIcon.disabled = true;
		}
		
		private function _onKeyDown(e:KeyboardEvent):void
		{
			//Key controls
			switch(e.keyCode)
			{
				case 32: //Space
					if(_selectedIcon != _moveIcon) _moveIcon.select();
					break;
			}
		}
		
		private function _onKeyUp(e:KeyboardEvent):void
		{
			//Key controls
			switch(e.keyCode)
			{
				case 32: //Space
					if(_previousIcon != null) _previousIcon.select();
					break;
					
				case 46: //Delete
					if (_vectorEditor.parent == null && !_deleteIcon.disabled)
					{
						_deleteIcon.select();
					}
					break;
					
				case 16: //Shift
					_canClone = true;
					break;
					
				case 80: //P
					this.paused = !paused;
					break;
					
				case 86: //V
					if (_vectorEditor.parent != null)
					{
						//Remove the vector editor
						_vectorEditor.removeFromParent();
					}
					else if (_selectedEntities.length == 1 &&
							 _selectedEntities[0] is SmartTexture)
					{
						//Show the vector editor
						_vectorEditor.dispatchEventWith(Oni.UPDATE_DATA, false, { entity: _selectedEntities[0] });
						_selectedEntities[0].addChild(_vectorEditor);
					}
					break;
				
				case 187: //+
					camera.z += 0.1;
					break;
				
				case 189: //-
					camera.z -= 0.1;
					break;
			}
		}
		
		private function _onMouseWheel(e:MouseEvent):void
		{
			if (e.controlKey && _selectedEntities.length > 0) //Change Z
			{
				for (var i:uint = 0; i < _selectedEntities.length; i++)
				{
					_selectedEntities[i].z -= e.delta / 40;
					if (_selectedEntities[i].z < 0) _selectedEntities[i].z = 0;
				}
			}
			else //Zoom
			{
				camera.z += e.delta / 40;
			}
		}
		
		private function _onButtonPressed(e:Event):void
		{
			//Check which button was pressed
			switch(e.currentTarget)
			{
				case _addStaticButton: //Static window
					_staticWindow.visible = true;
					break;
					
				case _addPropButton: //Prop window
					_propWindow.visible = true;
					break;
					
				case _sceneButton: //Scene window
					_scenePropertiesWindow.visible = true;
					break;
					
				case _smartTextureButton: //Smart texture button
					entities.add(new SmartTexture({
						texture: "debug",
						points: [ { x: 0, y: 0 }, { x: 256, y: 0 }, { x: 256, y: 256 }, { x: 0, y: 256 }, { x: 0, y: 0 } ],
						x: (camera.x + 256) / camera.z,
						y: (camera.y + 256) / camera.z,
						physics: false
					}));
					break;
					
				case _testButton:
					trace(JSON.stringify(serialize()));
					break;
			}
		}
		
		private function _onIconSelected(e:Event):void
		{
			//Deselect all other icons
			var i:uint;
			if (e.currentTarget != null && e.currentTarget != _lightIcon && e.currentTarget != _lockIcon && e.currentTarget != _lockRotationIcon && e.currentTarget != _lockScaleIcon)
			{
				var icon:Icon;
				for (i = 0; i < numChildren; i++)
				{
					icon = getChildAt(i) as Icon;
					if (icon != null && icon != e.currentTarget && icon != _lockIcon && icon != _lightIcon && icon != _lockRotationIcon && icon != _lockScaleIcon)
					{
						icon.selected = false;
					}
				}
			}
			
			//Set previous icon
			_previousIcon = _selectedIcon;
			
			//Check icon selection
			if (e.currentTarget == _deleteIcon) //Delete
			{
				//Remove all selected entities
				for (i = 0; i < _selectedEntities.length; i++)
				{
					entities.remove(_selectedEntities[i]);
				}
				
				//Deselect
				_deselectAll();
				_previousIcon.select();
			}
			else if (e.currentTarget == _editIcon && _selectedEntities.length == 1) //Edit entity icon
			{
				//Get entity data
				var entityData:Object = _selectedEntities[0].serialize();
				var properties:Array = [
					{ name: "x", type: "number", value: entityData.x },
					{ name: "y", type: "number", value: entityData.y },
					{ name: "z", type: "number", value: entityData.z },
					{ name: "scaleX", type: "number", value: entityData.scaleX },
					{ name: "scaleY", type: "number", value: entityData.scaleY },
					{ name: "rotation", type: "slider", min: 0, max: 360, value: entityData.rotation * 180 / Math.PI },
					{ name: "blendMode", type: "string", value: entityData.blendMode },
					{ name: "cull", type: "boolean", value: entityData.cull },
					{ name: "scrollX", type: "boolean", value: entityData.scrollX },
					{ name: "scrollY", type: "boolean", value: entityData.scrollY },
				];
				
				//Add custom properties
				for (var key:String in entityData.params)
				{
					properties.push({ name: key, type: typeof(entityData.params[key]), value: entityData.params[key] });
				}
				
				//Show window
				_entityPropertiesWindow.properties = properties;
				_entityPropertiesWindow.visible = true;
				_previousIcon.select();
			}
			else
			{
				//Set selected
				_selectedIcon = e.currentTarget as Icon;
			}
		}
		
		private function _onEntityDataUpdated(e:Event):void
		{
			//Check if we have an entity selected 
			if (_selectedEntities.length == 1)
			{
				//Set data
				if (_selectedEntities[0][e.data.name] != null)
				{
					//Convert rotation into radians
					if (e.data.name == "rotation") e.data.value = e.data.value * Math.PI / 180;
					
					//Set value
					_selectedEntities[0][e.data.name] = e.data.value;
				}
			}
		}
		
		private function get _windowsVisible():Boolean
		{
			return (_entityPropertiesWindow != null && _entityPropertiesWindow.visible) ||
				   (_propWindow != null && _propWindow.visible) ||
				   (_scenePropertiesWindow != null && _scenePropertiesWindow.visible) ||
				   (_smartTexturesWindow != null && _smartTexturesWindow.visible) ||
				   (_staticWindow != null && _staticWindow.visible);
		}
		
	}

}