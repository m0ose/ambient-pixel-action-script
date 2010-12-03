package ImageStuff
{
	/*
	load an xml file containg the urls of images
	then store them in an array called images.
	
	the xml looks like this : 
	<?xml version="1.0" encoding="utf-8"?>
	<GALLERY>
	<IMAGE > 
	<src>
	images/chacoPanarama3072Xsomething.jpg
	</src>
	</IMAGE>
	<IMAGE > 
	<src>
	images/radialgrid.jpg
	</src>
	</IMAGE>
	<IMAGE > 
	<src>
	images/100520-ALBAMU-360-11.jpg
	</src>
	</IMAGE>
	<IMAGE > 
	<src>
	images/chacoPanarama_small.jpg
	</src>
	</IMAGE>
	
	
	</GALLERY>
	
	
	
	*/
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class loadImagesXML
	{
		public var xload:URLLoader;
		public var xml:XML;
		public var images:Array = [];
		public var image_names:Array = [];
		public var _log:String = "";
		public function loadImagesXML( url:String = "images/images.xml")
		{
			//
			// LOAD THE XML
			//
			xload = new URLLoader( new URLRequest("images/images.xml"));
			xload.addEventListener(Event.COMPLETE, xmlLoaded);
		}
		
		private function xmlLoaded(e:Event):void
		{
			xml = new XML( e.target.data);
			
			for(  var i:int=0; i < xml.IMAGE.length(); i++)
			{
				var x2:XML = xml.IMAGE[i];
				
				_log += "__"+ x2.src;
				image_names.push( String(x2.src) );
				
				var ldr:Loader = new Loader();
				
				ldr.load( new URLRequest(x2.src) );
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, pushImage);	
				ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadingError);
				ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,handle_progress);
			}
			
			_log += xload;
			_log += xml.toXMLString();
		}
		private function pushImage(e:Event):void
		{
			e.target.removeEventListener( e.type, arguments.callee );
			
			var bmt:Bitmap = e.target.content as Bitmap;
			images.push( bmt);
			
			_log += " ,  image loaded " + e.type;
		}
		private function loadingError( e:IOErrorEvent):void
		{
			e.target.removeEventListener( e.type, arguments.callee );
			
		}
		private function handle_progress( e:ProgressEvent):void
		{
			
		}
		
		
	}
}