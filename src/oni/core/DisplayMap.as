package oni.core 
{
	import flash.geom.Matrix;
	import oni.entities.Entity;
	import oni.Oni;
	import starling.core.RenderSupport;
	import starling.display.BlendMode;
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
			addEventListener(Oni.DEBUG_DRAW, _onDebugDraw);
		}
		
		private function _updatePosition(e:Event):void
		{
			if (e.data.previous)
			{
				_repositonDifferenceX = -e.data.previous.x;
				_repositonDifferenceY = -e.data.previous.y;
			}
		}
		
		private function _onDebugDraw(e:Event):void
		{
            var entLength:int = numChildren;
            
			//Set x/y
			var nx:int = this.x * -1;
			var ny:int = this.y * -1;
			
			//Loop through all entities
            for (var i:int=0; i<entLength; ++i)
            {
				//Get the entity
				var entity:Entity = getChildAt(i) as Entity;
                
				//Check if the child is even visible
                if (entity != null && entity.hasVisibleArea && entity.cullCheck(-nx, -ny, 1))
				{
					//Relay event
					entity.dispatchEvent(e);
				}
			}
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
            var alpha:Number = parentAlpha * this.alpha;
            var entLength:int = numChildren;
            var blendMode:String = support.blendMode;
			
			//Set x/y
			var nx:int = this.x * -1;
			var ny:int = this.y * -1;
            
			//Loop through all entities
            for (var i:int=0; i<entLength; ++i)
            {
				//Get the entity
				var entity:Entity = getChildAt(i) as Entity;
                
				//Check if the child is even visible
                if (entity != null && entity.hasVisibleArea && entity.cullCheck(-nx, -ny, 1))
				{
					//Push default matrix
					support.pushMatrix();
					support.transformMatrix(entity);
					var newX:int, newY:int;
					
					//Parallax scrolling
					if (entity.z > 0 && entity.z != 1)
					{
						support.translateMatrix((nx-_repositonDifferenceX) * (1 - entity.z), (ny-_repositonDifferenceY) * (1 - entity.z));
					}
					else if(entity.z == 0) //Static, non-scrolling entities
					{
						support.modelViewMatrix.tx = entity.x;
						support.modelViewMatrix.ty = entity.y;
					}
					
					/*var mtx:Matrix = new Matrix();
					mtx.b = 100 * Math.PI/180;
					mtx.c = 0 * Math.PI/180;
					support.modelViewMatrix.concat(mtx);*/
					
					//Set blend mode
					support.blendMode = entity.blendMode;
					
					//Render
					if (entity.filter) entity.filter.render(entity, support, alpha);
					else        entity.render(support, alpha);
					
					//Reset support
					support.blendMode = blendMode;
					support.popMatrix();
				}
            }
		}
	}

}