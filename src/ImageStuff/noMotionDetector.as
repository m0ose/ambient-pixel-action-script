/*
	NO MOTION DETECTOR
			by: cody smith

    THIS FUNCTION TAKES A PICTURE WHEN LITTLE TO NO MOTION IS FOUND IN THE SCENE
		WHEN MOTION FALLS BELOW A CERTAIN THRESHOLD THE FUNCTION SENDS OUT AN EVENT( Event_donePic_ready  and event_ready)


usage:

var noMot:noMotionDetector ;
public function noMotion()
{
noMot = new noMotionDetector(cam);
noMot.addEventListener( noMot.Event_donePic_Ready, displayPic);
noMot.start();
}
public function displayPic(e:Event )
{
_img.source = new Bitmap( noMot.donePic	)
}


*/




package ImageStuff
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;
	
	public class noMotionDetector extends EventDispatcher
	{
		
		
		public var timeout:int = 200;//count between frame checks
		public var threshold_1:uint = 0xff444444  ;
		public var max_timeout:int = 3000; // 3000 ms == 3 seconds 
		public var donePic:BitmapData;
		public var Event_donePic_Ready:String = "pic ready";
		public var Event_ready:Event = new Event( Event_donePic_Ready);
		
		private var t:Timer;
		private var prev:BitmapData ; 
		private var curr:BitmapData ;
		private var cam:Camera;
		private var vidDisp:Video;
		//var e_done:Event = new Event("pic took");
		public function noMotionDetector(cam_:Camera , timeout_:uint = 200, threshold_:uint = 0xff444444 , max_timeout_:uint = 3000)
		{
			cam = cam_;
			vidDisp = new Video( cam.width, cam.height);
			vidDisp.attachCamera( cam);
			timeout = timeout_;
			threshold_1 = threshold_;
			max_timeout = max_timeout_;
		
			
		}
		
		public function start():void
		{
			
			prev = new BitmapData( cam.width, cam.height, false, 0xffffff );	
			
			curr = new BitmapData( cam.width, cam.height, false, 0xffffff );
			
			prev.draw( vidDisp ); //record the first frame from the camera 
			
			t=new Timer( timeout );
			t.addEventListener(TimerEvent.TIMER, takePic);
			//t.addEventListener(TimerEvent.TIMER_COMPLETE , compare);
			
			t.start();
		}
		private  function takePic(e:TimerEvent):void
		{
			curr.draw( vidDisp );
			
			//compare
			//   make differences white
			var difference:BitmapData = prev.clone();
			difference.draw( curr , new Matrix() , new ColorTransform(), BlendMode.DIFFERENCE); 
			//difference.threshold( difference, difference.rect, new Point(0,0), "<=" , threshold_1, 0xff000000);
			difference.threshold( difference, difference.rect, new Point(0,0), ">" , threshold_1, 0xffffffff);
			
			
			var pixCount:Number = countPixels( difference);
			if( t.currentCount > max_timeout / timeout )
			{
				compare();	
			}
			else if( pixCount >= 0 && pixCount < 10 )
			{
				compare();
			}
			else
			{				
				prev = curr.clone();
			}
			
		}
		private function compare(e:TimerEvent = null):void
		{
			t.stop();
			curr.draw( vidDisp );
			donePic = curr.clone();
			this.dispatchEvent( Event_ready);
			//_img.source = new Bitmap( curr) ;
		}
		//
		// COUNT THE WHITE PIXELS
		//		THE DIFERENCING MAKES MOST OF THE CHANGED PIXELS WHITE
		//		THIS COUNTS THEM AND RETURNS THE COUNTED VALUE.
		//		IF THERE WAS ABSOLUTELY NO CHANGE BETWEEN PREV AND CURR IMAGES THAN IT WAS PROBABLY THE SAME FRAM, AND RETURNS -1 .
		private function countPixels(b:BitmapData):Number // count the white pixels
		{
			var total:int = 0;
			var total_with_any_change:int = 0;
			for( var x:int = 0 ; x< b.width ; x = x + 1)
			{
				for( var y:int = 0 ; y < b.height; y = y + 1)
				{
					var pix:uint = b.getPixel( x, y); 
					if( pix == 0xffffff )
					{
						total ++;
					}
					if( pix != 0x000000)
					{
						total_with_any_change ++ ;
					}
				}
			}
			if( total_with_any_change == 0)// NO CHANGE AT ALL, PROBABLY THE SAME FRAME.
			{
				return -1;
			}
			return total;
		}
		
		
	}
}