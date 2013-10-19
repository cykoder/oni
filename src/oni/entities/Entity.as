package oni.entities 
{
    import flash.utils.getQualifiedClassName;
	import oni.Oni;
	import oni.rendering.SceneRenderer;
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
			addEventListener(Oni.ENTITY_ADD, _onAdded);
		}
		
		private function _onAdded(e:Event):void
		{
			//Remove event listener
			removeEventListener(Oni.ENTITY_ADD, _onAdded);
			
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
			if (parent != null && parent is SceneRenderer) (parent as SceneRenderer).shouldDepthSort = true;
		}
		
		public function get z():Number
		{
			return _z;
		}
		
		/**
		 * Depth sorts two entityies
		 * @param	a
		 * @param	b
		 * @return
		 */
		public static function depthSort(a:DisplayObject, b:DisplayObject):Number
		{
			//Calculate z
			var aZ:Number = 0;
			var bZ:Number = 0;
			
			//Is an entity?
			if (a is Entity) aZ = (a as Entity).z;
			if (b is Entity) bZ = (b as Entity).z;
			
			//Calculate y difference
			var ydif:Number = aZ - bZ;
			if (ydif == 0) ydif = -1;
			return ydif;
		}
	}

}