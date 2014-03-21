package oni.utils 
{
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class OniMath 
	{
		/**
		 * 任意の範囲から割合に応じた値を返します.
		 * @param	a
		 * @param	b
		 * @param	value	0.0:a, 1.0:b, 0.5:middle value
		 */
		public static function lerp( a:Number, b:Number, amt:Number ):Number
		{
			return a + (b - a) * amt;
		}
		
		/**
		 * 32bit Color (0xAARRGGBB) を Lerp します．
		 * 
		 * @param	c1	from color 0xAARRGGBB
		 * @param	c2	to color 0xAARRGGBB
		 * @param	amt	[0.0,1.0]
		 * @return	0xAARRGGBB
		 */
		public static function lerp32( c1:uint, c2:uint, amt:Number ):uint
		{
			return lerpRGBA( (c1 & 0x00ff0000) >>> 16, (c1 & 0x0000ff00) >>> 8, c1 & 0x000000ff, (c2 & 0x00ff0000) >>> 16, (c2 & 0x0000ff00) >>> 8, c2 & 0x000000ff, (c1 & 0xff000000) >>> 24, (c2 & 0xff000000) >>> 24, amt );	
		}
		
		/**
		 * RGB値を指定して Lerp します．
		 * @return 0xRRGGBB
		 */
		public static function lerpRGB( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, amt:Number ):uint
		{
			return uint(OniMath.lerp( r1, r2, amt )) << 16 | uint(OniMath.lerp( g1, g2, amt )) << 8 | uint(OniMath.lerp( b1, b2, amt ));
		}
		
		/**
		 * RGBA値を指定して Lerp します．
		 * @return 0xAARRGGBB
		 */
		public static function lerpRGBA( r1:uint, g1:uint, b1:uint, r2:uint, g2:uint, b2:uint, a1:uint, a2:uint, amt:Number ):uint
		{
			return uint(OniMath.lerp( a1, a2, amt )) << 24 | uint(OniMath.lerp( r1, r2, amt )) << 16 | uint(OniMath.lerp( g1, g2, amt )) << 8 | uint(OniMath.lerp( b1, b2, amt ));
		}
		
		/**
		 * 2つの色のグラデーションの値を Array で取得します. 
		 * 
		 * @example 次のコードは、<code>0xCC6600</code> から <code>0xCC6600</code> の10段階のグラデーション値を取得し描画します.
		 * <listing>
		 * var g:Array = ColorLerp.gradient( 0xCC6600, 0x006699, 10 );
		 * for( var i:int=0; i&lt;g.length; i++ ){
		 * 	graphics.beginFill( g[i] );
		 * 	graphics.drawRect( i~~20, 0, 20, 20 );
		 * 	graphics.endFill();
		 * }</listing>
		 * 
		 * @param	c1	from color 0xRRGGBB
		 * @param	c2	to color 0xRRGGBB
		 * @param	step	グラデーションのステップ数
		 * @return	0xRRGGBB[]
		 */
		public static function gradient( c1:uint, c2:uint, step:uint ):Array
		{
			var r1:uint = (c1 & 0xff0000) >>> 16;
			var g1:uint = (c1 & 0x00ff00) >>> 8;
			var b1:uint = c1 & 0x0000ff;
			var r2:uint = (c2 & 0xff0000) >>> 16;
			var g2:uint = (c2 & 0x00ff00) >>> 8;
			var b2:uint = c2 & 0x0000ff;
			
			var grad:Array = [];
			var amt:Number = 1.0 / step;
			grad[0] = c1;
			for ( var i:int = 1; i < step; i++ )
				grad[i] = lerpRGB( r1, g1, b1, r2, g2, b2, i * amt );
			grad[step] = c2;
			
			return grad;
		}
	}

}