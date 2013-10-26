package oni.entities 
{
    import flash.utils.getQualifiedClassName;
	import oni.Oni;
	import oni.core.Scene;
	import oni.utils.Platform;
	import flash.display.Scene;
	import flash.geom.Rectangle;
	import flash.ui.ContextMenuBuiltInItems;
	import starling.display.DisplayObject;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.display.Sprite;
	import starling.errors.AbstractClassError;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Entity extends Sprite
	{
		public var cullBounds:Rectangle;
		
		public var cull:Boolean = true;
		
		private var _z:Number = 1;
		
		public function Entity()
		{
			//Not allowed to init this class directly fam
            if (Platform.debugEnabled && 
                getQualifiedClassName(this) == "oni.entities::Entity")
            {
                throw new AbstractClassError();
            }
			
			//Not touchable by default
			this.touchable = false;
			
			//Create base culling rectangle
			cullBounds = new Rectangle();
			
			//Listen for added
			addEventListener(Oni.ENTITY_ADDED, _onAdded);
		}
		
		private function _onAdded(e:Event):void
		{
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADDED, _onAdded);
			
			//Listen for debug mode
			addEventListener(Oni.ENABLE_DEBUG, _onDebugEnabled);
		}
		
		private function _onDebugEnabled(e:Event):void
		{
			//Remove event listener
			removeEventListener(Oni.ENABLE_DEBUG, _onDebugEnabled);
			
			//Listen for debug disabled
			//addEventListener(Oni.DISABLE_DEBUG, _onDebugDisabled);
		}
		
		public function set z(value:Number):void
		{
			//Set z
			this._z = value;
			
			//Sort parent children by Z
			if (parent != null && parent is oni.core.Scene) (parent as oni.core.Scene).shouldDepthSort = true;
		}
		
		public function get z():Number
		{
			return _z;
		}
	}

}