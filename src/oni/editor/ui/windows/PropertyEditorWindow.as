package oni.editor.ui.windows 
{
	import oni.editor.ui.Checkbox;
	import oni.editor.ui.EditableTextfield;
	import oni.editor.ui.PointField;
	import oni.editor.ui.Slider;
	import oni.Oni;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PropertyEditorWindow extends Window
	{
		private var _properties:Array;
		
		private var _fields:DisplayObjectContainer;
		
		public function PropertyEditorWindow(width:int, height:int, title:String, properties:Array = null) 
		{
			//Super
			super(width, height, title);
			
			//Create fields container
			_fields = new Sprite();
			addChild(_fields);
			
			//Set properties
			if(properties != null) this.properties = properties;
		}
		
		public function get properties():Array
		{
			return _properties;
		}
		
		public function set properties(value:Array):void
		{
			//Check if different
			if (_properties != value)
			{
				//Remove all children
				while (_fields.numChildren > 0) _fields.removeChildAt(0, true);
				
				//Set
				_properties = value;
				
				//Set offsets
				var xOffset:uint = 10;
				var yOffset:uint = 26;
				var indent:Boolean=false;
				
				//Loop properties
				for (var i:uint = 0; i < _properties.length; i++)
				{
					if (_properties[i].type != "object")
					{
						//Create a label
						if (_properties[i].name != "")
						{
							var label:TextField;
							if (_properties[i].type == "label")
							{
								label = new TextField(100, 20, _properties[i].name, "Verdana", 10, 0xFFFFFF, true);
							}
							else
							{
								label = new TextField(100, 20, _properties[i].name + ":", "Verdana", 10, 0xFFFFFF);
							}
							label.hAlign = HAlign.LEFT;
							label.x = xOffset;
							label.y = yOffset;
							_fields.addChild(label);
						}
						
						//Create a field
						var field:DisplayObject;
						switch(String(_properties[i].type).toLowerCase())
						{
							case "slider": //Slider
								field = new Slider(_properties[i].min, _properties[i].max, _properties[i].value);
								break;
							
							case "checkbox": //Checkbox
							case "boolean":
								field = new Checkbox(_properties[i].value);
								break;
								
							case "point":
								field = new PointField(_properties[i].value);
								break;
								
							case "label": //Labels and spacers
							case "spacer":
								//Nothing!
								break;
								
							default: //Standard text field
								field = new EditableTextfield(_properties[i].value);
								break;
						}
						
						//Only if not a label/spacer
						if (field != null)
						{
							//Listen for data update
							field.name = _properties[i].name;
							field.addEventListener(Oni.UPDATE_DATA, _onDataUpdated);
							
							//Position the field
							field.x = xOffset;
							field.y = yOffset + 20;
							_fields.addChild(field);
							
							//Check if we're overflowing
							if (yOffset + 40 > height-40)
							{
								yOffset = 26;
								xOffset += 140;
							}
							else
							{
								yOffset += 40;
							}
							
							//Nullify
							field = null;
						}
						else
						{
							yOffset += 20;
						}
					}
				}
			}
		}
		
		private function _onDataUpdated(e:Event):void
		{
			//Relay event
			dispatchEvent(e);
		}
		
	}

}