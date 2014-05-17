package away 
{
	import away3d.primitives.PlaneGeometry;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Pete Shand
	 */
	public class PlaneGeoUVUpdater 
	{
		
		public function PlaneGeoUVUpdater() 
		{
			
		}
		
		public static function update(geo:PlaneGeometry, placement:Rectangle, textureWidth:int=2048, textureHeight:int=2048):void
		{
			var placementRatio:Number = placement.width / placement.height;
			
			trace(placement.width / placement.height);
			
			geo.width = geo.height * placementRatio;
			
			//geo.width = placement.width;
			//geo.height = placement.height;
			
			var segments:Point = new Point(1, 1);
			var data:Vector.<Number> = geo.subGeometries[0].UVData;
			var uvScale:Point = new Point(placement.width / textureWidth, placement.height / textureHeight);
			var uvOffset:Point = new Point(placement.x / textureWidth, placement.y / textureHeight);
			
			var index:Vector.<int> = new Vector.<int>();
			for (var n:int = 0; n < segments.x + 1; ++n) {
				for (var m:int = 0; m < segments.y + 1; ++m) {
					index.push((n + m) * 1);
					index.push((n + m) * 1);
				}
			}
			
			for (var i:int = 0; i < data.length; i += 13) {
				data[i + 9] *= uvScale.x;
				data[i + 9] += uvOffset.x;
				data[i + 10] *= uvScale.y;
				data[i + 10] += uvOffset.y;
			}
		}
	}
}