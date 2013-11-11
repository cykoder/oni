package oni.entities 
{
    import flash.utils.getQualifiedClassName;
	import oni.Oni;
	import oni.core.Scene;
	import oni.utils.Platform;
	import flash.display.Scene;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.display.Sprite;
	import starling.errors.AbstractClassError;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Entity extends Sprite
	{
		/**
		 * The culling bounds of the entity
		 */
		public var cullBounds:Rectangle;
		
		/**
		 * Whether the entity should cull or not
		 */
		public var cull:Boolean = true;
		
		/**
		 * The entity's Z co-ordinate
		 */
		private var _z:Number = 1;
		
		/**
		 * Whether the entity should render or not
		 */
		private var _shouldRender:Boolean = true;
		
		/**
		 * Whether the entity should parallax scroll along the X axis
		 */
		private var _scrollX:Boolean = true;
		
		/**
		 * Whether the entity should parallax scroll along the X axis
		 */
		private var _scrollY:Boolean = true;
		
		/**
		 * Initialises an entity instance
		 */
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
		}
		
		/**
		 * The entity's Z co-ordinate
		 */
		public function get z():Number
		{
			return _z;
		}
		
		/**
		 * The entity's Z co-ordinate
		 */
		public function set z(value:Number):void
		{
			//Set z
			this._z = value;
			
			//Sort parent children by Z
			if (parent != null && parent is oni.core.Scene) (parent as oni.core.Scene).shouldDepthSort = true;
		}
		
		/**
		 * Whether the entity should parallax scroll along the X axis
		 */
		public function get scrollX():Boolean
		{
			return (_z < 0 || _scrollX);
		}
		
		/**
		 * Whether the entity should parallax scroll along the X axis
		 */
		public function set scrollX(value:Boolean):void
		{
			_scrollX = value;
		}
		
		/**
		 * Whether the entity should parallax scroll along the Y axis
		 */
		public function get scrollY():Boolean
		{
			return (_z < 0 || _scrollY);
		}
		
		/**
		 * Whether the entity should parallax scroll along the Y axis
		 */
		public function set scrollY(value:Boolean):void
		{
			_scrollY = value;
		}
		
		/**
		 * Checks if an entity should be culled or not
		 * @param	nx
		 * @param	ny
		 */
		public function cullCheck(nx:int, ny:int):void
		{
			if (cull && cullBounds != null)
			{
				_shouldRender = !(((x + nx + cullBounds.width) < 0) ||
								((y + ny + cullBounds.height) < 0) ||
								((x + nx > Platform.STAGE_WIDTH)) ||
								((y + ny > Platform.STAGE_HEIGHT)));
			}
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			if (_shouldRender) super.render(support, parentAlpha);
		}
	}

}