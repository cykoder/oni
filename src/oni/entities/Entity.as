package oni.entities 
{
	import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
	import oni.core.DisplayMap;
	import oni.core.ISerializable;
	import oni.entities.debug.DebugCircle;
	import oni.entities.debug.DebugSquare;
	import oni.entities.environment.FluidBody;
	import oni.entities.environment.StaticTexture;
	import oni.entities.environment.SmartTexture;
	import oni.entities.lights.AmbientLight;
	import oni.entities.lights.PointLight;
	import oni.entities.lights.PolygonLight;
	import oni.entities.lights.TexturedLight;
	import oni.entities.platformer.Character;
	import oni.entities.scene.Prop;
	import oni.Oni;
	import oni.core.Scene;
	import oni.utils.Platform;
	import flash.display.Scene;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.display.Sprite;
	import starling.errors.AbstractClassError;
	/**
	 * A 
	 * @author Sam Hellawell
	 */
	public class Entity extends Sprite implements ISerializable
	{
		/**
		 * Linkage classes so we don't get the "Variable [X] is not defined error"
		 */
		private static var smartTexture:SmartTexture,
						   prop:Prop,
						   character:Character,
						   staticTexture:StaticTexture,
						   debugCircle:DebugCircle,
						   debugSquare:DebugSquare,
						   ambientLight:AmbientLight,
						   polygonLight:PolygonLight,
						   pointLight:PointLight,
						   texturedLight:TexturedLight;
		
		/**
		 * Whether the entity should cull or not
		 */
		public var cull:Boolean = true;
		
		/**
		 * The parameters used when the entity is initialised
		 */
		protected var _params:Object;
		
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
		
		/**
		 * The shape for displaying the entity's bounds
		 */
		private var _boundsShape:Shape;
		
		/**
		 * Initialises an entity instance
		 */
		public function Entity(params:Object)
		{
			//Not allowed to init this class directly fam
            if (getQualifiedClassName(this) == "oni.entities::Entity")
            {
                throw new AbstractClassError();
            }
			
			//Default parameters
			if (params.serializable == null) params.serializable = true;
			
			//Set startup parameters
			_params = params;
			
			//Create base culling rectangle
			_cullBounds = new Rectangle();
			
			//Create a bounds shape
			_boundsShape = new Shape();
			_boundsShape.visible = false;
			_boundsShape.touchable = false;
			addChild(_boundsShape);
			
			//Apply data
			_applyEntityData(params, this);
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
			if (parent != null && parent.parent != null && parent is DisplayMap) (parent.parent as oni.core.Scene).shouldDepthSort = true;
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
		public function cullCheck(nx:int, ny:int, nz:Number):void
		{
			if (cull && cullBounds != null)
			{
				_shouldRender = !(((x + nx + cullBounds.width) < 0) ||
								((y + ny + cullBounds.height) < 0) ||
								((x + nx > Platform.STAGE_WIDTH)) ||
								((y + ny > Platform.STAGE_HEIGHT)));
				//trace(_shouldRender);
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
		
		public function get serializable():Boolean
		{
			return _params.serializable;
		}
		
		public function set serializable(value:Boolean):void
		{
			_params.serializable = value;
		}
		
		/**
		 * Serializes data to an object
		 * @return
		 */
		public function serialize():Object
		{
			//Get base data
			var data:Object = {
				className: getQualifiedClassName(this),
				x: this.x,
				y: this.y,
				z: this.z,
				scaleX: this.scaleX,
				scaleY: this.scaleY,
				rotation: this.rotation,
				blendMode: this.blendMode,
				cull: this.cull,
				scrollX: this.scrollX,
				scrollY: this.scrollY,
				width: this.width,
				height: this.height,
				params: _params
			};
			
			//Check if we should always match stage dimensions
			if (data.width == Starling.current.stage.stageWidth) data.width = "stageWidth";
			if (data.height == Starling.current.stage.stageHeight) data.height = "stageHeight";
			
			//Return data
			return data;
		}
		
		/**
		 * Deserializes an object to an entity
		 * @param	data
		 * @return
		 */
		public static function deserialize(data:Object):Entity
		{
			//Initialise entity based on class name, god I love AS3
			var entity:Entity = new (getDefinitionByName(data.className) as Class)(data.params);
			
			//Set data
			_applyEntityData(data, entity);
			
			//Return
			return entity;
		}
		
		private static function _applyEntityData(data:Object, entity:Entity):void
		{
			//Set basic properties
			if(data.x != null) entity.x = data.x;
			if(data.y != null) entity.y = data.y;
			if(data.z != null) entity.z = data.z;
			if(data.scaleX != null) entity.scaleX = data.scaleX;
			if(data.scaleY != null) entity.scaleY = data.scaleY;
			if(data.rotation != null) entity.rotation = data.rotation;
			if(data.blendMode != null) entity.blendMode = data.blendMode;
			if(data.cull != null) entity.cull = data.cull;
			if(data.scrollX != null) entity.scrollX = data.scrollX;
			if(data.scrollY != null) entity.scrollY = data.scrollY;
			
			if(data.width == "stageWidth") data.width = Starling.current.stage.stageWidth;
			if(data.height == "stageHeight") data.height = Starling.current.stage.stageHeight;
			
			if(data.width != null) entity.width = data.width;
			if (data.height != null) entity.height = data.height;
			
			//Check if startup params contains anything we don't need
			if (data.x != null) delete(data.x);
			if (data.y != null) delete(data.y);
		}
	}

}