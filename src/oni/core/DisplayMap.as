package oni.core 
{
	import oni.entities.Entity;
	import oni.components.Camera;
	import oni.entities.environment.StaticTexture;
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
			//Set scale
			this.scaleX = nz;
			this.scaleY = nz;
			
			//Loop through entities
			var entity:Entity, l:uint = numChildren;
			for (var i:uint = 0; i < l; i++)
			{
				entity = getChildAt(i) as Entity;
				if (entity != null)
				{
					if (!entity.scrollX && !entity.scrollY)
					{
						entity.x = nx / nz;
						entity.y = ny / nz;
						entity.scaleX = 1 / nz;
						entity.scaleY = 1 / nz;
					}
					else
					{
						//Static
						if (entity.z < 0)
						{
							entity.x = nx / nz;
							entity.y = ny / nz;
						}
						else
						{
							//Parallax
							if (entity.scrollX)
							{
								if(entity.z != 1) entity.x -= (-nx - this.x) * (1 - entity.z);
							}
							else
							{
								entity.x = nx;
							}
							
							if (entity.scrollY) 
							{
								if(entity.z != 1) entity.y -= (-ny - this.y) * (1 - entity.z);
							}
							else
							{
								entity.y = ny;
							}
						}
					}
					
					//Cullcheck entity
					//entity.cullCheck(this.x, this.y);
				}
				else
				{
					
						getChildAt(i).x = nx / nz;
						getChildAt(i).y = ny / nz;
						getChildAt(i).scaleX = 1 / nz;
						getChildAt(i).scaleY = 1 / nz;
				}
			}
			
			//Set position
			this.x = -nx;
			this.y = -ny;
		}
		
	}

}