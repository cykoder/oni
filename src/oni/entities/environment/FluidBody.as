package oni.entities.environment 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import nape.callbacks.InteractionType;
	import oni.entities.PhysicsEntity;
	import oni.Oni;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	import oni.utils.Platform;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.graphics.Fill;
	import starling.display.graphics.TriangleStrip;
	import starling.display.Image;
	import starling.display.Shape;
	import starling.events.Event;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	/**
	 * ...
	 * @author Sam Hellawell
	 */
	public class FluidBody extends PhysicsEntity
	{
		private const _splashDampening:Number = 0.5;
		
		private const _spread:Number = 0.25;
		
		private const _waveQuality:Number = 1;
		
		/**
		 * The triangle strip to draw the columns to
		 */
		private var _triangleStrip:TriangleStrip;
		
		private var _displayObject:DisplayObject;
		
		private var _renderTexture:RenderTexture;
		
		private var _fluidColumns:Vector.<Object>;
		
		private var _fluidShape:Polygon;
		
		private var lDeltas:Vector.<Number>;
		
		private var rDeltas:Vector.<Number>;
		
		private var _renderMatrix:Matrix;
		
		private var _columnAmount:int;
		
		/**
		 * Creates a debug circle with the given width/height
		 * @param	wh
		 */
		public function FluidBody(params:Object) 
		{
			//Default parameters
			if (params.density == null) params.density = 3;
			if (params.viscosity == null) params.viscosity = 5;
			if (params.topColor == null) params.topColor = 0x6FA8FF;
			if (params.bottomColor == null) params.bottomColor = 0x000F28;
			
			//Super
			super(params);
			_params = params;
			
			//No culling
			this.cull = false;
			
			//Calculate the amount of columns
			_columnAmount = _params.width / _waveQuality;
			
			//Check if the platform supports advanced features
			if (Platform.supportsAdvancedFeatures())
			{
				//Create a columns vector
				_fluidColumns = new Vector.<Object>();
				for (var i:uint = 0; i < _columnAmount+1; i++)
				{
					_fluidColumns.push({ height: 0, targetHeight: 0, speed: 0 });
				}
				
				//Create a triangle strip to draw to
				_triangleStrip = new TriangleStrip();
				
				//Create a render texture to draw to
				_renderTexture = new RenderTexture(_params.width, _params.height + 256, false);
				
				//Create a render matrix
				_renderMatrix = new Matrix();
				MatrixUtil.prependTranslation(_renderMatrix, 0, 256);
				
				//Create an image to render the water
				_displayObject = new Image(_renderTexture);
				_displayObject.y = -256;
				_displayObject.scaleX = _params.width / _columnAmount;
				addChild(_displayObject);
				
				//Listen for update
				addEventListener(Oni.UPDATE, _onUpdate);
				
				//Listen for physics interaction
				addEventListener(Oni.PHYSICS_INTERACTION, _onPhysicsInteraction);
				
				//Reset the column vector and repopulate
				/*if (_fluidColumns != null)
				{
					_fluidColumns.length = 0;
					for (var i:uint = 0; i < _columnAmount+1; i++)
					{
						_fluidColumns.push({ height: 0, targetHeight: 0, speed: 0 });
					}
				}*/
			}
			else
			{
				//Create a gradient filled quad on lower end devices
				_displayObject = new Fill();
				(_displayObject as Fill).addVertex(0, 0, _params.topColor);
				(_displayObject as Fill).addVertex(_params.width, 0, _params.topColor);
				(_displayObject as Fill).addVertex(_params.width, _params.height,  _params.bottomColor);
				(_displayObject as Fill).addVertex(0, _params.height,  _params.bottomColor);
				addChild(_displayObject);
			}
			
			//Set blendmode
			this.blendMode = BlendMode.MULTIPLY;
			
			//Set cull bounds
			cullBounds.setTo(0, 0, _params.width, _params.height);
		}
		
		override public function render(support:RenderSupport, parentAlpha:Number):void 
		{
			//Check if we're using a triangle strip
			if (_triangleStrip != null)
			{
				//Clear the triangle strip
				_triangleStrip.clear();
				
				//Get the RGB values for the top colour
				var topR:Number = ((_params.topColor & 0xFF0000) >> 16) / 255;
				var topG:Number = ((_params.topColor & 0x00FF00) >> 8) / 255;
				var topB:Number = ((_params.topColor & 0x0000FF) / 255);
				
				//Get the RGB values for the bottom colour
				var bottomR:Number = ((_params.bottomColor & 0xFF0000) >> 16) / 255;
				var bottomG:Number = ((_params.bottomColor & 0x00FF00) >> 8) / 255;
				var bottomB:Number = ((_params.bottomColor & 0x0000FF) / 255);
				
				//Calculate the scale
				var scale:Number = 1; // _params.width / _columnAmount;
				
				//Draw each column
				var p1:Point = new Point();
				var p2:Point = new Point();
				var p3:Point = new Point();
				var p4:Point = new Point();
				for (var i:uint = 1; i < _fluidColumns.length; i++)
				{
					//Calculate each column point
					p1.setTo((i - 1) * scale, _fluidColumns[i - 1].height);
					p2.setTo(i * scale, _fluidColumns[i].height);
					p3.setTo(p2.x, _params.height);
					p4.setTo(p1.x, _params.height);
					
					//Create the first triangle
					_triangleStrip.addVertex(p1.x, p1.y, p1.x * 0.01, p1.y * 0.01, topR, topG, topB, 1);
					_triangleStrip.addVertex(p2.x, p2.y, p2.x * 0.01, p2.y * 0.01, topR, topG, topB, 1);
					_triangleStrip.addVertex(p3.x, p3.y, p3.x * 0.01, p3.y * 0.01, bottomR, bottomG, bottomB, 1);
					
					//Create the second triangle, to make a quad
					_triangleStrip.addVertex(p1.x, p1.y, p1.x * 0.01, p1.y * 0.01, topR, topG, topB, 1);
					_triangleStrip.addVertex(p3.x, p3.y, p3.x * 0.01, p3.y * 0.01, bottomR, bottomG, bottomB, 1);
					_triangleStrip.addVertex(p4.x, p4.y, p4.x * 0.01, p4.y * 0.01, bottomR, bottomG, bottomB, 1);
				}
				
				//Render the triangle strip
				_renderTexture.draw(_triangleStrip, _renderMatrix);
			}
			
			//Render this
			super.render(support, parentAlpha);
		}
		
		private function _onPhysicsInteraction(e:Event):void
		{
			//Only allow fluid interactions!
			if (e.data.type == InteractionType.FLUID && _fluidColumns != null)
			{
				//Check which body is ours
				var collider:PhysicsEntity = e.data.a;
				if (e.data.a == this) collider = e.data.b;
				
				//Get nearest column to the start and the end of the collider
				var minIndex:int = int(Math.max(0, Math.min(_fluidColumns.length - 1, (collider.x - collider.pivotX - this.x) / _displayObject.scaleX)));
				var maxIndex:int = int(Math.max(0, Math.min(_fluidColumns.length - 1, ((collider.x + (collider.width-collider.pivotX)) - this.x) / _displayObject.scaleX)));
				
				//Calculate the speed
				var speed:Number = (collider.body.velocity.y * _splashDampening) * (maxIndex - minIndex) / 1000;
					
				//Gotta go fast, make a splash!
				for (var i:uint = minIndex; i < maxIndex; i++)
				{
					_fluidColumns[i].speed = speed;
				}
			}
		}
		
		private function _onUpdate(e:Event):void
		{
			//Create detlas vectors
			if (lDeltas == null || rDeltas == null)
			{
				lDeltas = new Vector.<Number>();
				rDeltas = new Vector.<Number>();
				
				for (i = 0; i < _fluidColumns.length; i++)
				{
					lDeltas.push(0);
					rDeltas.push(0);
				}
			}
			
			var i:uint, j:uint;
			for (i = 0; i < _fluidColumns.length; i++)
			{
				if (_fluidColumns[i].speed != 0)
				{
					var hx:Number = _fluidColumns[i].targetHeight - _fluidColumns[i].height;
					_fluidColumns[i].speed += (hx - _fluidColumns[i].speed) * Math.max(0, Math.min(1, (_params.density * _params.viscosity) /  200));
					_fluidColumns[i].height += _fluidColumns[i].speed;
				}
			}
			
			// do some passes where columns pull on their neighbours
			for (j = 0; j < 8; j++)
			{
				for (i = 0; i < _fluidColumns.length; i++)
				{
					if (i > 0)
					{
						lDeltas[i] = _spread * (_fluidColumns[i].height - _fluidColumns[i - 1].height);
						_fluidColumns[i - 1].speed += lDeltas[i];
					}
					if (i < _fluidColumns.length - 1)
					{
						rDeltas[i] = _spread * (_fluidColumns[i].height - _fluidColumns[i + 1].height);
						_fluidColumns[i + 1].speed += rDeltas[i];
					}
				}

				for (i = 0; i < _fluidColumns.length; i++)
				{
					if (i > 0)
					{
						_fluidColumns[i - 1].height += lDeltas[i];
					}
					if (i < _fluidColumns.length - 1)
					{
						_fluidColumns[i + 1].height += rDeltas[i];
					}
				}
			}
		}
		
		/**
		 * Creates a physics body
		 */
		override protected function _createBody():void
		{
			//Create a physics body
			_physicsBody = new Body(BodyType.STATIC, new Vec2(x, y));
			
			//Create a fluid shape
			_fluidShape = new Polygon(Polygon.rect(0, 0, _params.width, _params.height));
			_fluidShape.fluidEnabled = true;
            _fluidShape.fluidProperties.density = _params.density;
            _fluidShape.fluidProperties.viscosity = _params.viscosity;
			_fluidShape.body = _physicsBody;
			
			//Set the physics space
			_physicsBody.space = _space;
		}
		
		public function get density():Number
		{
			return _fluidShape.fluidProperties.density;
		}
		
		public function set density(value:Number):void
		{
			_fluidShape.fluidProperties.density = value;
		}
		
		public function get viscosity():Number
		{
			return _fluidShape.fluidProperties.viscosity;
		}
		
		public function set viscosity(value:Number):void
		{
			_fluidShape.fluidProperties.viscosity = value;
		}
	}

}