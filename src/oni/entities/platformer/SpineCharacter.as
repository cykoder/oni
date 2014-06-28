package oni.entities.platformer 
{
	import oni.Oni;
	import spine.Event;
	import spine.SkeletonData;
	import spine.SkeletonJson;
	import spine.animation.AnimationStateData;
	import spine.atlas.Atlas;
	import spine.attachments.AtlasAttachmentLoader;
	import spine.starling.StarlingTextureLoader;
	import spine.starling.SkeletonAnimation;
	import spine.starling.StarlingAtlasAttachmentLoader;
	import oni.assets.AssetManager;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class SpineCharacter extends Character
	{
		protected var _skeleton:SkeletonAnimation;
		
		public function SpineCharacter(params:Object) 
		{
			//Default parameters
			if (params.flipCharacter == null) params.flipCharacter = true;
			
			//Super
			super(params);
			
			//Set skeleton
			skeleton = params.skeleton;
			
			//Listen for data update
			addEventListener(Oni.UPDATE_DATA, _onUpdateData);
		}
		
		public function set skeleton(value:String):void
		{
			//Set
			if (_params.skeleton != value || _skeleton == null)
			{
				//Set params
				_params.skeleton = value;
				
				//Get the texture atlas and the skeleton json for the character
				var atlas:TextureAtlas = AssetManager.getTextureAtlas("character_" + skeleton);
				var json:SkeletonJson = new SkeletonJson(new StarlingAtlasAttachmentLoader(atlas));
				
				//Read the skeleton data
				var skeletonData:SkeletonData = json.readSkeletonData(AssetManager.getAsset("character_" + skeleton + "Skeleton"), skeleton);
		
				//Load the animation state data, set mixes
				var stateData:AnimationStateData = new AnimationStateData(skeletonData);
				_setMixes(stateData);
				
				//Remove current skeleton
				if (_skeleton != null)
				{
					Starling.juggler.remove(_skeleton);
					removeChild(_skeleton, true);
				}
				
				//Finally, create a skeleton with the data we have
				_skeleton = new SkeletonAnimation(skeletonData, stateData);
				_skeleton.scaleX = _skeleton.scaleY = 0.5;
				_skeleton.x = _params.bodyWidth / 2;
				_skeleton.y = _params.bodyHeight + 2;
				addChild(_skeleton);
				
				//Add the skeleton to the juggler
				Starling.juggler.add(_skeleton);
			}
		}
		
		public function get skeleton():String
		{
			return _params.skeleton;
		}
		
		protected function _onUpdateData(e:starling.events.Event):void
		{
			//Update your animations here
		}
		
		protected function _setMixes(stateData:AnimationStateData):void
		{
			//Set your mixes here
		}
		
		override public function move(direction:int):void 
		{
			//Check if different
			if (canMove && direction != _moveDirection)
			{
				//Flip based on direction
				if(_params.flipCharacter) _skeleton.scaleX = 0.5 * direction;
				
				//Super
				super.move(direction);
			}
		}
	}

}