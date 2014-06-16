package oni.sound
{
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	public interface IPlayable
	{
		function play(customPosition:Number = NaN):SoundChannel;

		function fadeIn():void;
		function fadeOut():void;
		
		function stop():Number;
	}
}