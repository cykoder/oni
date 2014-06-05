package oni.core 
{
	import oni.entities.Entity;
	import oni.components.Camera;
	import oni.entities.environment.StaticTexture;
	import oni.entities.lights.Light;
	import oni.Oni;
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.FragmentFilter;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class DisplayMap extends DisplayObjectContainer
	{
		private var _repositonDifferenceX:int;
		
		private var _repositonDifferenceY:int;
		
		public function DisplayMap()
		{
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
		}
		
		private function _updatePosition(e:Event):void
		{
			//Set difference
			_repositonDifferenceX = -e.data.x-this.x;
			_repositonDifferenceY = -e.data.y-this.y;
			
			//Set scale
			this.scaleX = e.data.z;
			this.scaleY = e.data.z;
			
			//Set position
			this.x = -e.data.x;
			this.y = -e.data.y;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
            var alpha:Number = parentAlpha * this.alpha;
            var entLength:int = numChildren;
            var blendMode:String = support.blendMode;
			
			var nx:int = this.x * -1;
			var ny:int = this.y * -1;
			var nz:int = this.scaleX;
            
            for (var i:int=0; i<entLength; ++i)
            {
				//Get the entity
				var entity:Entity = getChildAt(i) as Entity;
                
				//Check if the child is even visible
                if (entity != null && entity.hasVisibleArea && entity.cullCheck(-nx, -ny, nz))
				{
					//Push default matrix
					support.pushMatrix();
					support.transformMatrix(entity);
					var newX:int, newY:int;
					
					//Parallax
					if (entity.z > 0 && entity.z != 1)
					{
						newX = _repositonDifferenceX * (1 - entity.z);
						newY = _repositonDifferenceY * (1 - entity.z);
						support.translateMatrix(-newX, -newY);
					}
					else if(entity.z == 0) //Static, non-scrolling entities
					{
						support.translateMatrix(-entity.x, -entity.y);
						support.translateMatrix(nx/nz, ny/nz);
					}
					
					support.blendMode = entity.blendMode;
					
					if (entity.filter) entity.filter.render(entity, support, alpha);
					else        entity.render(support, alpha);
							
					support.blendMode = blendMode;
					support.popMatrix();
				}
            }
		}
	}

}