package 
{
	import away.TextureAtlas;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.tools.commands.Merge;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * ...
	 * @author P.J.Shand
	 */
	[SWF(backgroundColor = "#000000", width = "1080", height = "500", frameRate = "60")]
	
	public class Main extends Sprite 
	{
		private var view:View3D;
		private var meshes:Vector.<Mesh> = new Vector.<Mesh>();
		private var colMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		private var batchMeshes:Vector.<Mesh> = new Vector.<Mesh>();
		private var material:TextureMaterial;
		
		private var demensions:Point = new Point(10, 70);
		
		
		
		[Embed(source="./spritesheet.png", mimeType="image/png")]
		private var SheetPNG:Class;
		[Embed(source="./spritesheet.xml", mimeType="application/octet-stream")]
		private var SheetXML:Class;
		
		[Embed(source="./background.jpg", mimeType="image/jpg")]
		private var Background:Class;
		
		
		private var grassBendAnimationSet:GrassBendAnimationSet;
		private var textureAtlas:TextureAtlas;
		private var geos:Vector.<PlaneGeometry> = new Vector.<PlaneGeometry>();
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			view = new View3D();
			addChild(view);
			view.antiAlias = 4;
			view.backgroundColor = 0x90994a;
			
			createBackground();
			
			var bmd1:BitmapData = Bitmap(new SheetPNG()).bitmapData;
			var texture:BitmapTexture = new BitmapTexture(bmd1)
			textureAtlas = new TextureAtlas(texture, XML(new SheetXML()));
			
			for (var j:int = 0; j < textureAtlas.totalFrames; j++) 
			{
				var geo:PlaneGeometry = new PlaneGeometry(demensions.x, demensions.y, 1, 20, false);
				geos.push(textureAtlas.updateGeoByIndex(geo, j));
				//geos.push(geo);
			}
			
			//var bmd:BitmapData = Bitmap(new MyImage()).bitmapData;
			material = new TextureMaterial(texture);
			material.alphaBlending = true;
			
			material.addMethod(new AlphaFogMethod(1500, 2000));
			
			createRow();
			
			var awayStats:AwayStats = new AwayStats(view);
			//addChild(awayStats);
			
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		private function createBackground():void 
		{
			var geo:PlaneGeometry = new PlaneGeometry(1080, 200, 1, 1, false);
			var bmd:BitmapData = Bitmap(new Background()).bitmapData;
			var texture:BitmapTexture = new BitmapTexture(bmd);
			var material:TextureMaterial = new TextureMaterial(texture);
			var mesh:Mesh = new Mesh(geo, material);
			mesh.z = 2000;
			mesh.y = 1037;
			mesh.scale(6.93);
			view.scene.addChild(mesh);
		}
		
		private function createRow():void 
		{
			var num:int = 50;
			var spacing:int = 4;
			for (var i:int = 0; i < num; i++) 
			{
				var random:int = Math.random() * geos.length;
				var geo:PlaneGeometry = geos[random];
				
				//var geo:PlaneGeometry = new PlaneGeometry(demensions.x, demensions.y, 1, 20, false);
				var mesh:Mesh = new Mesh(geo, material);
				mesh.x = (i * (demensions.x+spacing)) - ((num-1) / 2 * (demensions.x+spacing));
				//view.scene.addChild(mesh);
				meshes.push(mesh);
			}
			
			var mergedRow:Mesh = new Mesh(null, material);
			var merge:Merge = new Merge(true, false, false);
			merge.applyToMeshes(mergedRow, meshes);
			
			//view.scene.addChild(mergedRow);
			
			createBatch(mergedRow);
		}
		
		private function createBatch(mergedRow:Mesh):void 
		{
			var num:int = 6;
			var spacing:int = 50 * (demensions.x + 4);
			for (var i:int = 0; i < num; i++) 
			{
				var mesh:Mesh = Mesh(mergedRow.clone());
				mesh.x = (i * spacing) - (spacing * num / 2);
				//view.scene.addChild(mesh);
				batchMeshes.push(mesh);
			}
			
			var mergedBatches:Mesh = new Mesh(null, material);
			var merge:Merge = new Merge(true, false, false);
			merge.applyToMeshes(mergedBatches, batchMeshes);
			
			createCols(mergedBatches)
		}
		
		private function createCols(mergedBatches:Mesh):void 
		{
			var num:int = 150;
			var depth:int = 10;
			var spacing:int = 4;
			for (var i:int = 0; i < num; i++) 
			{
				//var geo:PlaneGeometry = new PlaneGeometry(demensions.x, 100, 1, 1, false);
				var mesh:Mesh = Mesh(mergedBatches.clone());
				mesh.z = (-i * (depth + spacing)) + ((num - 1) / 2 * (depth + spacing));
				mesh.x = (Math.random() * 200) - 100;
				//view.scene.addChild(mesh);
				colMeshes.push(mesh);
			}
			
			var mergedCols:Mesh = new Mesh(null, material);
			var merge:Merge = new Merge(true, false, false);
			merge.applyToMeshes(mergedCols, colMeshes);
			
			mergedCols.y = 50;
			mergedCols.rotationX = -15;
			view.scene.addChild(mergedCols);
			
			
			grassBendAnimationSet = new GrassBendAnimationSet(demensions.y, 10);
			mergedCols.animator = new GrassBendAnimator(grassBendAnimationSet);
			
		}
		
		
		
		private function Update(e:Event):void 
		{
			view.render();
			
			grassBendAnimationSet.value+=2;
		}
		
	}
	
}