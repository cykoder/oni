package oni.core 
{
	import flash.display3D.Context3D;
	import flash.display3D.Program3D;
    import flash.display3D.Context3DProgramType;
	import starling.filters.FragmentFilter;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class CompositeFilter extends FragmentFilter
	{
		private var _fragmentProgramCode:String;
        private var _quantifiers:Vector.<Number>;
        private var _shaderProgram:Program3D;
		
		public var diffuseMap:Texture;
		public var lightMap:Texture;
		public var ambientMap:Texture;
		
		public function CompositeFilter():void
		{
			/*
			 * ft0 = lightmap
			 * ft1 = diffuse map
			 * ft2 = ambient map
			 * ft3 = composite
			 */
            _fragmentProgramCode =
                "tex ft0, v0, fs1 <2d,repeat,linear,nomip>		\n" +
				"tex ft1, v0, fs0 <2d,repeat,linear,nomip>		\n" +
				"tex ft2, v0, fs2 <2d,repeat,linear,nomip>		\n" +
				
				//Apply ambient lighting
				"add ft0 ft0.xyz ft2.xyz						\n" +
				
				//Multiply diffuse by lightmap
                "mul ft3, ft0.r, ft1.r							\n" +
                "mul ft3, ft0.g, ft1.g							\n" +
                "mul ft3, ft0.b, ft1.b							\n" +
				
				//Output
                "mov oc, ft3									\n";
			
			//Set quantifiers
			_quantifiers = new <Number>[0.01, 1, 1, 1, 100];
		}
		
        override public function dispose():void
        {
			//Dispose the shader
            if (_shaderProgram)
			{
				_shaderProgram.dispose();
			}
			
			//Super dispose
            super.dispose();
        }
 
        override protected function createPrograms():void
        {
			//Assemble the AGAL
            _shaderProgram = assembleAgal(_fragmentProgramCode);
        }
		
        override protected function activate(pass:int, context:Context3D, texture:Texture):void
        {
			if (diffuseMap != null && lightMap != null && ambientMap != null)
			{
				//Set the textures
				context.setTextureAt(0, diffuseMap.base);
				context.setTextureAt(1, lightMap.base);
				context.setTextureAt(2, ambientMap.base);
				
				//Upload quantifiers
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _quantifiers, 1);
				
				//Set the program
				context.setProgram(_shaderProgram);
			}
        }
		
		override protected function deactivate(pass:int, context:Context3D, texture:Texture):void 
		{
			//Reset the textures
			context.setTextureAt(0, null);
			context.setTextureAt(1, null);
			context.setTextureAt(2, null);
			
			//Deactivate
			super.deactivate(pass, context, texture);
		}
	}

}