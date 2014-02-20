package oni.editor.ui 
{
	import flash.geom.Point;
	import oni.Oni;
	import starling.display.Sprite;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class PointField extends Sprite
	{
		private var _xField:EditableTextfield;
		
		private var _yField:EditableTextfield;
		
		public function PointField(value:Point) 
		{
			//Create an x field
			_xField = new EditableTextfield(value.x.toString(), 48);
			_xField.addEventListener(Oni.UPDATE_DATA, _onDataUpdated);
			addChild(_xField);
			
			//Create a y field
			_yField = new EditableTextfield(value.y.toString(), 48);
			_yField.x = 52;
			_yField.addEventListener(Oni.UPDATE_DATA, _onDataUpdated);
			addChild(_yField);
		}
		
		private function _onDataUpdated(e:Event):void
		{
			//Dispatch update event
			dispatchEventWith(Oni.UPDATE_DATA, false, { name: name, value: new Point(Number(_xField.text), Number(_yField.text)) } );
		}
		
	}

}