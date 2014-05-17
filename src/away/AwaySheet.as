package away
{
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.textures.Texture2DBase;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 */
	public class AwaySheet 
	{
		private var broadcaster:Sprite;
		
		public var mesh:Mesh;
		protected var _material:TextureMaterial;
		private var _baseSheet:TextureAtlas;
		private var _frame:int = -1;
		private var animationNames:Vector.<String> = new Vector.<String>();
		private var _fps:int = 30;
		private var updateCount:int = 0;
		private var width:int;
		private var height:int;
		
		public function AwaySheet(atlas:TextureAtlas, width:int=-1, height:int=-1) 
		{
			this.height = height;
			this.width = width;
			_baseSheet = atlas;
			
			broadcaster = new Sprite();
			
			createAwayTexture(_baseSheet.texture);
		}
		
		private function createAwayTexture(tex:Texture2DBase):void 
		{
			_material = new TextureMaterial(tex, true, false, false);
			_material.animateUVs = true; // this has to be on for UV manipulation to work
			_material.alphaBlending = true;
		}
		
		public function get atlas():TextureAtlas { return _baseSheet; }
		public function get texture():Texture2DBase { return _material.texture; }
		public function get material():TextureMaterial { return _material; }
		
		public function setUV(name:String):void 
		{
			if(mesh == null)
				throw new ArgumentError("submesh cannot be null");
			
			var regionRc:Rectangle = _baseSheet.getRegion(name);
			if(regionRc == null)
				throw new ArgumentError("given region does not exist: " + name);
				
			var submesh:SubMesh = mesh.subMeshes[0];

			var w:Number = _baseSheet.texture.width;
			var h:Number = _baseSheet.texture.height;
			
			submesh.offsetU = regionRc.x / w;
			submesh.offsetV = regionRc.y / h;
			submesh.scaleU  = regionRc.width / w;
			submesh.scaleV  = regionRc.height / h;
			
			//var frame:Rectangle = _baseSheet.getFrame(name);
			
			//if (width != -1) {
				//mesh.scaleX = regionRc.width / width;
			//}
			//if (height != -1) {
				//mesh.scaleY = regionRc.height / height;
			//}
			
			
		}
		
		
		public function play(name:String=null):void 
		{
			if (name == null) name = atlas.animationNames[0];
			animationNames = atlas.getNames(name);
			broadcaster.addEventListener(Event.ENTER_FRAME, Update);
			Update();
			if (frame == -1) frame++;
		}
		
		public function stop():void
		{
			broadcaster.removeEventListener(Event.ENTER_FRAME, Update);
		}
		
		public function gotoAndPlay(frame:int):void
		{
			play();
			this.frame = 0;
		}
		
		public function gotoAndStop(frame:int):void
		{
			stop();
			this.frame = 0;
		}
		
		private function Update(e:Event=null):void 
		{
			updateCount++;
			if (Math.floor(updateCount % (60 / _fps)) == 0) frame++;
		}
		
		public function get frame():int 
		{
			return _frame;
		}
		
		public function set frame(value:int):void 
		{
			if (_frame == value) return;
			_frame = value;
			if (_frame >= animationNames.length) {
				_frame = 0;
			}
			if (animationNames.length > 0) setUV(animationNames[frame]);
		}
		
		public function get fps():int 
		{
			return _fps;
		}
		
		public function set fps(value:int):void 
		{
			_fps = value;
		}
		
		public function get totalFrames():int 
		{
			return animationNames.length;
		}
	
	}

}