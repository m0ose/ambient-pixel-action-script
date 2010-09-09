/*
This handles opening and exporting of cameraprojectorMap2 maps    by cody smith
	It is nice to be able to save the file instead of re callibrate every time,(for debugging)

	important features
		import()
		export( camerprojectorMap)
		public var cam_map:CameraProjecterMap2 //this is where the file is stored
		public var reversed_map:Reversemap //this is a reverse image

	Usage:
		var m:MapFileOpener = new MapFileOpener()
		m.import   //  a file browsing dialogue will open, hopefully
		
		or m.export( something)
		

NOTE: TODO: REPLACE THIS WITH XML PARSER, AS3 HAS A GOOD ONE.



*/


package structuredlight
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	
	import structuredlight.parseMap2;

	public class MapFileOpener extends EventDispatcher
	{
		//imported files
		public var cam_map:CameraProjecterMap2 //imported file will be stored here
		public var reversed_map:Reversemap
		
		private var fileRef:FileReference//put on top of page when done
		
		private var loadedEvent:Event = new Event( "loaded Map", true)
		
		public function MapFileOpener()
		{
			
		}
		
		public function export(map:CameraProjecterMap2):void
		{
			if( map)
			{
				var par:parseMap2 = new parseMap2()
				var f:FileReference = new FileReference()
				var st:String = par.camMap2XML( map );
				f.save( st, "graymap.xml")
				//f.save( this,"map2.txt")
			}
		}
		
		
		public function importMap():void
		{
			fileRef= new FileReference()
			fileRef.browse( )
			fileRef.addEventListener(Event.SELECT, selectHandler)
			fileRef.addEventListener(Event.COMPLETE, completeHandler)
		}
		private function selectHandler(e:Event):void
		{
			fileRef.load()
		}
		private function completeHandler(e:Event):void
		{
			cam_map = new CameraProjecterMap2()
			var cpm_parse:parseMap2= new parseMap2( );
			cam_map = cpm_parse.parse( fileRef.data.toString() );
		
			this.dispatchEvent( loadedEvent)
		}
		public function getReversed_map():void
		{
			if(cam_map)
			{
				reversed_map=new Reversemap( cam_map)
			}
		}
		
	}
}