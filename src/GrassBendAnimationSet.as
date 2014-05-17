package 
{
	import away3d.animators.AnimationSetBase;
	import away3d.animators.data.VertexAnimationMode;
	import away3d.animators.IAnimationSet;
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.Debug;
	import away3d.materials.passes.MaterialPassBase;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	
	import flash.display3D.Context3D;
	
	import flash.utils.Dictionary;
	
	use namespace arcane;
	
	/**
	 * The animation data set used by vertex-based animators, containing vertex animation state data.
	 *
	 * @see away3d.animators.VertexAnimator
	 */
	public class GrassBendAnimationSet extends AnimationSetBase implements IAnimationSet
	{
		private var _numPoses:uint;
		private var _blendMode:String;
		private var _streamIndices:Dictionary = new Dictionary(true);
		private var _useNormals:Dictionary = new Dictionary(true);
		private var _useTangents:Dictionary = new Dictionary(true);
		private var _uploadNormals:Boolean;
		private var _uploadTangents:Boolean;
		
		private var _vertexData : Vector.<Number>;
		private var _amplitudeX:Number = 10;
		private var _frequencyX:Number = 1;
		private var _offsetX:Number = 0;
		
		private var _amplitudeY:Number = 10;
		private var _frequencyY:Number = 1;
		private var _offsetY:Number = 0;
		
		private var _offsetZ:Number = 0;
		
		private var _geoOffsetY:Number = 0;
		private var _width:int;
		private var height:int;
		
		/**
		 * Returns the number of poses made available at once to the GPU animation code.
		 */
		public function get numPoses():uint
		{
			return _numPoses;
		}
		
		/**
		 * Returns the active blend mode of the vertex animator object.
		 */
		public function get blendMode():String
		{
			return _blendMode;
		}
		
		/**
		 * Returns whether or not normal data is used in last set GPU pass of the vertex shader.
		 */
		public function get useNormals():Boolean
		{
			return _uploadNormals;
		}
		
		public function get value():Number
		{
			return _vertexData[4] * 180 / Math.PI;
		}
		
		public function set value(value:Number):void 
		{
			_vertexData[4] = value / 180 * Math.PI;
		}
		
		/**
		 * Creates a new <code>GrassBendAnimationSet</code> object.
		 *
		 * @param numPoses The number of poses made available at once to the GPU animation code.
		 * @param blendMode Optional value for setting the animation mode of the vertex animator object.
		 *
		 * @see away3d.animators.data.VertexAnimationMode
		 */
		public function GrassBendAnimationSet(height:int, sway:int, numPoses:uint = 2, blendMode:String = "absolute")
		{
			super();
			this.height = height;
			_numPoses = numPoses;
			_blendMode = blendMode;
			
			_vertexData = new Vector.<Number>(8);
			_vertexData[0] = sway;
			_vertexData[1] = height;
			_vertexData[2] = height/2;
			_vertexData[3] = 0;
			
			_vertexData[4] = 0;
			_vertexData[5] = 0;
			_vertexData[6] = 0;
			_vertexData[7] = 0;
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALVertexCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>, profile:String):String
		{
			if (_blendMode == VertexAnimationMode.ABSOLUTE)
				return getAbsoluteAGALCode(pass, sourceRegisters, targetRegisters);
			else
				return getAdditiveAGALCode(pass, sourceRegisters, targetRegisters);
		}
		
		/**
		 * @inheritDoc
		 */
		public function activate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void
		{
			_uploadNormals = Boolean(_useNormals[pass]);
			_uploadTangents = Boolean(_useTangents[pass]);
			
			var context : Context3D = stage3DProxy._context3D;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 24, _vertexData, 2);
		}
		
		/**
		 * @inheritDoc
		 */
		public function deactivate(stage3DProxy:Stage3DProxy, pass:MaterialPassBase):void
		{
			var index:int = _streamIndices[pass];
			var context:Context3D = stage3DProxy._context3D;
			context.setVertexBufferAt(index, null);
			if (_uploadNormals)
				context.setVertexBufferAt(index + 1, null);
			if (_uploadTangents)
				context.setVertexBufferAt(index + 2, null);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALFragmentCode(pass:MaterialPassBase, shadedTarget:String, profile:String):String
		{
			return "";
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAGALUVCode(pass:MaterialPassBase, UVSource:String, UVTarget:String):String
		{
			return "mov " + UVTarget + "," + UVSource + "\n";
		}
		
		/**
		 * @inheritDoc
		 */
		public function doneAGALCode(pass:MaterialPassBase):void
		{
		
		}
		
		/**
		 * Generates the vertex AGAL code for absolute blending.
		 */
		private function getAbsoluteAGALCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>):String
		{
			Debug.active = true;
			
			var code:String = "";
			var len:uint = sourceRegisters.length;
			var useNormals:Boolean = Boolean(_useNormals[pass] = len > 1);
			
			
			code += "mov " + targetRegisters[0] + ", " + sourceRegisters[0] + "\n";
			
			if (useNormals) code += "mov " + targetRegisters[1] + ", " + sourceRegisters[1] + "\n";
			
			
			
			
			if (targetRegisters.length > 2) {
				code += "mov " + targetRegisters[2] + ", " + sourceRegisters[2] + "\n";
			}
			
			
			code += "// test \n";
			
			
			code += "mov vt6.x, vc25.x \n"; 
			
			code += "mov vt5.y, vt0.y \n"; 
			code += "div vt5.y, vt5.y, vc24.z \n"; 
			
			code += "mov vt5.x, vt0.x \n"; 
			code += "div vt5.x, vt5.x, vc24.y \n"; 
			
			code += "mov vt5.z, vt0.z \n"; 
			code += "div vt5.z, vt5.z, vc24.y \n"; 
			
			code += "add vt5.w, vt5.x, vt5.y \n"; 
			code += "add vt5.w, vt5.w, vt5.z \n"; 
			
			code += "add vt6.x, vt6.x, vt5.w \n"; 
			
			code += "sin vt6.x, vt6.x \n"; 
			
			//code += "mul vt6.x, vt6.x, vc24.x \n"; 
			//code += "add vt0.x, vt0.x, vt6.x \n"; 
			//return code;
			
			
			
			code += "// test \n";
			
			code += "mov vt7.w, vt0.y \n";
			code += "add vt7.w, vt7.w, vc24.z \n";
			code += "div vt7.x, vt7.w, vc24.y \n";
			code += "mul vt7.x, vt7.x, vc24.x \n";
			
			code += "mul vt7.x, vt7.x, vt6.x \n";
			
			code += "add vt0.x, vt0.x, vt7.x \n";
			return code;
			
			
			
			
			code += "mov vt7.x, va0.x \n"; // mov x into vt7.x
			code += "add vt7.x, vt7.x, vc24.x \n"; // Add x position offset
			
			code += "mul vt7.x, vt7.x, vc24.z \n"; // Mul frequency by x position offset
			
			code += "div vt7.x, vt7.x, vc26.z \n"; // div by geo width
			code += "mul vt7.x, vt7.x, vc26.w \n"; // mul by Pie
			code += "cos vt7.x, vt7.x \n"; // cos value
			code += "mul vt7.x, vt7.x, vc24.y \n"; // Mul by amplitude
			
			/*///////////////////*/
			code += "sub vt6.z, vt0.z, vc28.x \n"; // sub min from z
			code += "div vt6.z, vt0.z, vc28.y \n"; // div z by (max-min)
			code += "sat vt6.z, vt6.z \n"; // Clamp a between 1 and 0
			code += "mul vt6.z, vt6.z, vc27.z \n"; // mul by -1
			code += "add vt6.z, vt6.z, vc27.y \n"; // add 1
			code += "mul vt7.x, vt7.x, vt6.z \n"; // mul offset by 0|1
			/*///////////////////*/
			
			code += "add vt0.y, vt0.y, vt7.x \n"; // Add offset to base vertex
			
			code += "add vt0.y, vt0.y, vc25.w \n"; // add geoOffsetY to y vertex
			
			return code;
		}
		
		/**
		 * Generates the vertex AGAL code for additive blending.
		 */
		private function getAdditiveAGALCode(pass:MaterialPassBase, sourceRegisters:Vector.<String>, targetRegisters:Vector.<String>):String
		{
			var code:String = "";
			var len:uint = sourceRegisters.length;
			var regs:Array = ["x", "y", "z", "w"];
			var temp1:String = findTempReg(targetRegisters);
			var k:uint;
			var useTangents:Boolean = Boolean(_useTangents[pass] = len > 2);
			var useNormals:Boolean = Boolean(_useNormals[pass] = len > 1);
			var streamIndex:uint = _streamIndices[pass] = pass.numUsedStreams;
			
			if (len > 2)
				len = 2;
			
			code += "mov  " + targetRegisters[0] + ", " + sourceRegisters[0] + "\n";
			if (useNormals)
				code += "mov " + targetRegisters[1] + ", " + sourceRegisters[1] + "\n";
			
			for (var i:uint = 0; i < len; ++i) {
				for (var j:uint = 0; j < _numPoses; ++j) {
					code += "mul " + temp1 + ", va" + (streamIndex + k) + ", vc" + pass.numUsedVertexConstants + "." + regs[j] + "\n" +
						"add " + targetRegisters[i] + ", " + targetRegisters[i] + ", " + temp1 + "\n";
					k++;
				}
			}
			
			if (useTangents) {
				code += "dp3 " + temp1 + ".x, " + sourceRegisters[uint(2)] + ", " + targetRegisters[uint(1)] + "\n" +
					"mul " + temp1 + ", " + targetRegisters[uint(1)] + ", " + temp1 + ".x			 \n" +
					"sub " + targetRegisters[uint(2)] + ", " + sourceRegisters[uint(2)] + ", " + temp1 + "\n";
			}
			
			return code;
		}
	}
}
