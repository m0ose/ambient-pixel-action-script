package structuredlight
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;

	public class Displacement24Files
	{
		public function Displacement24Files()
		{
		}
		
		
		
		//
		//
		//  FILE STUFF
		//
		
		//
		// SAVE IMAGES
		//
		public function SaveX( d24:Displacement24):void
		{
			Disp24 = d24;
			var f2:FileReference = new FileReference();
			
			var encoder:PNGEncoder = new PNGEncoder()
			

				var bytesX:ByteArray = encoder.encode( d24.mapX);
				
				f2.save( bytesX, "ydisplacement.png" );
			
		}
		public function SaveY( d24:Displacement24):void
		{
			Disp24 = d24;
			var f2:FileReference = new FileReference();
			
			var encoder:PNGEncoder = new PNGEncoder()
			
	
			var bytesY:ByteArray = encoder.encode( d24.mapY);
				
			f2.save( bytesY, "ydisplacement.png" );
			
		}
		
		// OPEN IMAGES
		// it takes all of thes functions to load two files in flash. WTF !!
		//

		
		
		public var xImg:BitmapData
		public var yImg:BitmapData
		public var Disp24:Displacement24;
		private var fR:FileReference = new FileReference();
		private var ldr:Loader

		public function loadXmap():void
		{
			fR= new FileReference();
			fR.browse( );
			fR.addEventListener(Event.SELECT, imageSelect);
			fR.addEventListener(Event.COMPLETE, completeX);
		}
		public function loadYmap():void
		{
			fR = new FileReference();
			fR.browse( );
			fR.addEventListener(Event.SELECT, imageSelect);
			fR.addEventListener(Event.COMPLETE, completeY);
		}
		
		private function imageSelect(e:Event):void
		{
			fR.removeEventListener(Event.SELECT, imageSelect);
			fR.load();
		}
		
		private function completeX( e:Event):void
		{
			fR.removeEventListener(Event.COMPLETE, completeX);
			ldr = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, ldrX );
			ldr.loadBytes( fR.data);	
		}
		private function completeY( e:Event):void
		{
			fR.removeEventListener(Event.COMPLETE, completeY);
			
			ldr = new Loader();
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, ldrY);
			ldr.loadBytes( fR.data);			
		}
		private function ldrX( e:Event):void
		{
			ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, ldrX);
			xImg = Bitmap(e.target.content).bitmapData;
			filesReady()
		}
		private function ldrY( e:Event):void
		{
			ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, ldrY);
			yImg = Bitmap(e.target.content).bitmapData;
			filesReady()
		}
		public function filesReady():Boolean
		{
			if( xImg && yImg)
			{
				Disp24 = new Displacement24( xImg,yImg);
				return true;
			}
			return false;
		}
	

		
		
	}
}