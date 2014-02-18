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
        private var _shaderProgram:Program3D;
		
		public var diffuseMap:Texture;
		public var lightMap:Texture;
		
		
		
        private var _thresholdVector:Vector.<Number> = new <Number>[0.5, 0.5, 0.5, 0];
		
        private var _bloomIntensityVector:Vector.<Number> = new <Number>[1.3, 1.3, 1.3, 1];
		
        private var _oneConstantVector:Vector.<Number> = new <Number>[1, 1, 1, 1];
		
        private var _oneMinusVector:Vector.<Number> = new <Number>[0.5, 0.5, 0.5, 0];
		
        private var _ambientColourVector:Vector.<Number> = new <Number>[0, 0, 0, 0];
		
		public function CompositeFilter():void
		{
			intensity = 0.6;
			
			/*
			 * fs0 = lightmap
			 * fs1 = diffuse map
			 * ft3 = composite
			 */
            _fragmentProgramCode =
				//Set textures
                "tex ft0, v0, fs0 <2d,repeat,linear,nomip>		\n" +
				"tex ft1, v0, fs1 <2d,repeat,linear,nomip>		\n" +
				
				//Apply ambient lighting
				"add ft0 ft0, fc4						\n" +
				
				//Multiply diffuse by lightmap
                "mul ft3, ft0, ft1								\n" +
				
				//Extract light colours, put into ft0
                "sub ft0, ft3, fc0								\n" + 
                "div ft0, ft0, fc3								\n" + 
                "sat ft0, ft0									\n" +
				
				//Intensity intensifies
				"mul ft0, ft0, fc1								\n" +
				
				//Darken composite in light areas, this isn't terminator 2: judgement day
				"sat ft0, ft0									\n" +
				"sub ft1, fc2, ft0								\n" +
				"mul ft3, ft3, ft1								\n" +
				
				//Add light colours to composite
				"add ft3, ft3, ft0								\n" +
				
				//Output
				"mov oc, ft3									\n";
		}
		
		public function set ambientColor(value:uint):void
		{
			//Covert uint to rgb and divide by 255 (GPU requires decimals)
			_ambientColourVector[0] = ((value >> 16) & 0xFF) / 255;
			_ambientColourVector[1] = ((value >> 8) & 0xFF) / 255;
			_ambientColourVector[2] = (value & 0xFF) / 255;
		}
		
		public function get intensity():Number
		{
			return _thresholdVector[0];
		}
		
		public function set intensity(value:Number):void
		{
			//Set threshhold for rgb
			_thresholdVector[0] = _thresholdVector[1] = _thresholdVector[2] = value;
			
			//Pre-compute so we don't have to do this on the GPU
			_oneMinusVector[0] = _oneMinusVector[1] = _oneMinusVector[2] = 1 - value;
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
			if (diffuseMap != null && lightMap != null)
			{
				//Set the textures
				context.setTextureAt(0, lightMap.base);
				context.setTextureAt(1, diffuseMap.base);
				
				//Set the constants
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _thresholdVector, 1 );
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _bloomIntensityVector, 1 );
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _oneConstantVector, 1 );
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, _oneMinusVector, 1 );
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, _ambientColourVector, 1 );
				
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