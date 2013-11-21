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
					//Static
					if (entity.z < 0)
					{
						entity.x = nx;
						entity.y = ny;
					}
					else
					{
						//Parallax
						if (entity.scrollX)
						{
							if(entity.z != 1) entity.x -= xdif * (1 - entity.z);
						}
						else
						{
							entity.x = nx;
						}
						
						if (entity.scrollY) 
						{
							if(entity.z != 1) entity.y -= ydif * (1 - entity.z);
						}
						else
						{
							entity.y = ny;
						}
					}
					
					//Cullcheck entity
					entity.cullCheck(this.x, this.y);
				}
			}
		}
		
	}

}