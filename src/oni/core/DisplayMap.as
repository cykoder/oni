package oni.core 
{
	import oni.entities.Entity;
	import oni.components.Camera;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class DisplayMap extends Sprite
	{
		public var flat:Boolean;
		
		public function DisplayMap(flat:Boolean) 
		{
			//Set flat
			this.flat = flat;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			//Unflatten
			if(this.flat && this.isFlattened) unflatten();
			
			//Add the child
			super.addChild(child);
			
			//Flatten
			if(this.flat) flatten();
			
			//Return
			return child;
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject 
		{
			//Unflatten
			if(this.flat && this.isFlattened) unflatten();
			
			//Add the child
			super.addChildAt(child, index);
			
			//Flatten
			if(this.flat) flatten();
			
			//Return
			return child;
		}
		
		override public function removeChild(child:DisplayObject, dispose:Boolean = true):DisplayObject 
		{
			//Unflatten
			if(this.flat && this.isFlattened) unflatten();
			
			//Remove child
			super.removeChild(child, dispose);
			
			//Flatten
			if(this.flat) flatten();
			
			//Return
			return child;
		}
		
		override public function removeChildAt(index:int, dispose:Boolean = false):DisplayObject 
		{
			//Unflatten
			if(this.flat && this.isFlattened) unflatten();
			
			//Get child
			var child:DisplayObject = super.getChildAt(index);

			//Remove child
			return super.removeChildAt(index, dispose);
			
			//Flatten
			if(this.flat) flatten();
			
			//Return
			return child;
		}
		
		override public function removeChildren(beginIndex:int = 0, endIndex:int = -1, dispose:Boolean = false):void 
		{
			//Unflatten
			if(this.flat && this.isFlattened) unflatten();
			
			//Remove children
			super.removeChildren(beginIndex, endIndex, dispose);
			
			//Flatten
			if(this.flat) flatten();
		}
		
		public function reposition(nx:int, ny:int, nz:Number):void
		{
			//Get difference
			var xdif:Number = -nx - this.x;
			var ydif:Number = -ny - this.y;
			
			//Set position
			this.x = -nx;
			this.y = -ny;
			
			//Loop through entities
			var entity:Entity, l:uint = numChildren;
			for (var i:uint = 0; i < l; i++)
			{
				entity = getChildAt(i) as Entity;
				if (entity != null)
				{
					//Parallax
					entity.x -= xdif * (1 - entity.z);
					entity.y -= ydif * (1 - entity.z);
					
					//Check if entity is offscreen (culling)
					/*if (entity.cull && entity.cullBounds != null && stage != null)
					{
						if (entity.x + entity.cullBounds.width - nx < 0 ||
							entity.y + entity.cullBounds.height - ny < 0 ||
							entity.x - nx >= stage.stageWidth ||
							entity.y-ny >= stage.stageHeight)
						{
							entity.noRender = true;
						}
						else
						{
							entity.noRender = false;
						}
					}*/
				}
			}
		}
		
	}

}