package oni.entities 
{
    import flash.utils.getQualifiedClassName;
	import oni.core.DisplayMap;
	import oni.Oni;
	import oni.core.Scene;
	import oni.utils.Platform;
	import flash.display.Scene;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
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
		 * The culling bounds of the entity
		 */
		private var _cullBounds:Rectangle;
		
		private var _boundsShape:Shape;
		
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
			
			//Create base culling rectangle
			_cullBounds = new Rectangle();
			
			//Create a bounds shape
			_boundsShape = new Shape();
			_boundsShape.visible = false;
			addChild(_boundsShape);
		}
		
		/**
		 * Whether to show the bounds or not
		 */
		public function get showBounds():Boolean
		{
			return _boundsShape.visible;
		}
		
		/**
		 * Whether to show the bounds or not
		 */
		public function set showBounds(value:Boolean):void
		{
			cullBounds = _cullBounds;
			_boundsShape.visible = value;
		}
		
		/**
		 * The culling bounds of the entity
		 */
		public function get cullBounds():Rectangle
		{
			return _cullBounds;
		}
		
		/**
		 * The culling bounds of the entity
		 */
		public function set cullBounds(value:Rectangle):void
		{
			if (_cullBounds != value)
			{
				//Set cull bounds
				_cullBounds = value;
			}
			
			//Redraw
			if (_cullBounds != null)
			{
				//Draw rect
				_boundsShape.graphics.clear();
				_boundsShape.graphics.lineStyle(1, 0x00FF00, 0.5);
				_boundsShape.graphics.beginFill(0xFFFFFF, 0.1);
				_boundsShape.graphics.drawRect(0, 0, _cullBounds.width, _cullBounds.height);
				_boundsShape.graphics.endFill();
				
				//Position
				_boundsShape.x = _cullBounds.x;
				_boundsShape.y = _cullBounds.y;
			}
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
			if (parent != null && parent is DisplayMap) (parent.parent as oni.core.Scene).shouldDepthSort = true;
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
		
		override public function get x():Number 
		{
			return super.x;
		}
		
		override public function get y():Number 
		{
			return super.y;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{
			//Super
			super.addChildAt(child, index);
			
			//Make sure bounds are on top
			setChildIndex(_boundsShape, numChildren - 1);
			
			//Return child
			return child;
		}
	}

}