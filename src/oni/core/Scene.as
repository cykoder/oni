package oni.core 
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import oni.assets.AssetManager;
	import oni.components.Camera;
	import oni.components.ComponentManager;
	import oni.entities.Entity;
	import oni.entities.EntityManager;
	import oni.entities.lights.Light;
	import oni.Oni;
	import oni.utils.Platform;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class Scene extends DisplayObjectContainer
	{		   
		public var shouldDepthSort:Boolean;
		
		protected var _diffuseMap:DisplayMap;
		
		protected var _lightMap:LightMap;
		
		public function Scene(lighting:Boolean=true)
		{
			//Create a diffuse map
			_diffuseMap = new DisplayMap();
			addChild(_diffuseMap);
			
			//Is lighting enabled?
			if (lighting)
			{
				//Create a light map
				_lightMap = new LightMap();
				addChild(_lightMap);
			}
			
			//Listen for events
			addEventListener(Oni.UPDATE_POSITION, _updatePosition);
		}
		
		public function get lighting():LightMap
		{
			return _lightMap;
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			//Depth sort
			if (shouldDepthSort)
			{
				shouldDepthSort = false;
				_diffuseMap.sortChildren(function depthSort(a:DisplayObject, b:DisplayObject):Number
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
				});
			}
			
			//Render
			super.render(support, parentAlpha);
		}
		
		private function _updatePosition(e:Event):void
		{
			//Position maps
			_diffuseMap.reposition(e.data.x, e.data.y, e.data.z);
			if(_lightMap != null) _lightMap.reposition(e.data.x, e.data.y, e.data.z);
		}
		
		public function getContainer(child:DisplayObject):DisplayObjectContainer
		{
			//Check if light
			if (child is Light) return _lightMap;
			return _diffuseMap;
		}
		
		public function addEntity(entity:Entity):void
		{
			var container:DisplayObjectContainer = getContainer(entity);
			if (container != null)
			{
				container.addChild(entity);
				container = null;
			}
			
			shouldDepthSort = true;
		}
		
		public function removeEntity(entity:Entity):void
		{
			var container:DisplayObjectContainer = getContainer(entity);
			if (container != null)
			{
				container.removeChild(entity);
				container = null;
			}
			
			shouldDepthSort = true;
		}
		
		override public function dispose():void 
		{
			//Remove event listeners
			removeEventListener(Oni.UPDATE_POSITION, _updatePosition);
			
			//Super
			super.dispose();
		}
		
		public function serialize(entities:EntityManager, components:ComponentManager):Object
		{
			return { lighting: lighting != null,
					 physicsEnabled: entities.physicsEnabled,
					 gravity: entities.gravity,
					 entities: entities.serialize(),
					 components: components.serialize() };
		}
		
		public static function deserialize(data:Object, entities:EntityManager, components:ComponentManager):Scene
		{
			//Create a scene
			var scene:Scene = new Scene(data.lighting);
			
			//Add the entities
			var i:uint;
			for (i = 0; i < data.entities.length; i++)
			{
				scene.addEntity(entities.add(Entity.deserialize(data.entities[i])));
			}
			
			//Add the components
			for (i = 0; i < data.components.length; i++)
			{
				components.add(new (getDefinitionByName(data.components[i].className) as Class)(scene, data.components[i].params));
			}
			
			//Return
			return scene;
		}
	}

}