package away
{
	import away3d.textures.Texture2DBase;
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import starling.textures.Texture;
	
	/**
	 * ...
	 */
	public class SharedTexture extends Texture2DBase 
	{
		private var refTexture:Texture;
		
		public function SharedTexture(tex:Texture) 
		{
			super();
			refTexture = tex;
		}
		
		override protected function uploadContent(texture:TextureBase):void
		{
			// Leave empty
		}
		
		override protected function createTexture(context:Context3D):TextureBase
		{
			var baseTex:TextureBase = refTexture.base;
			return baseTex;
		}
		
	}

}