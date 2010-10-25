/*
   Laser Tracker. ver . 0.2						by: Cody Smith
		The purpose of this is to track the position of a laser. It works OK with very little extra movement going on. 
		It works like this. First it finds an active rectangele. An active rectangle is the rectangle containing everything that has changed 
			between two consecutive frames. Then it searches that rectangle for the brightest spot. That spot is the laser, maybe. then it sends a 
			an Event called "LASER_MOVE".
		
		
		
		constructor:
			Laser_Follow( Camera)
		events:
			"LASER_MOVE"
		public variableS:
			threshold:uint : works well at about 0x44. range is from 0 to 255
			scale:Number   : This is for speed. The image is shrunk by this scale before it is processed
								works well at about 0.5. The range is from 0.0 to 1.0
			position: Point   : This is the current position of the laser. Hopefully.					
			curr:  BitmapData : This is for watching what is going on. It is just a bitmapdata
	usage:
		  var cam:Camera = Camera.getCamera( )
		  laz = new Laser_follower( cam)
	      laz.addEventListener("LASER_MOVE", laserMoved) 
			
			private function laserMoved(e:Event):void
			{
				trace( "laser ( " + laz.position.x + " , "  + laz.position.y + " ) " )
				
			}
		



*/



package laserStuff
{
	import ImageStuff.ImageStuff;
	
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;
	
	public class Laser_follower extends EventDispatcher
	{
		private var cam:Camera
		private var vid:Video
		public var curr:BitmapData
		public var prev:BitmapData

		public var threshold:uint = 0x33 // 0 to 256
		
		public var position:Point = new Point(60,0)

		private var lasertime:Timer
		
		public var moveEvent:String = "LASER_MOVE";
		
	
		

		public function Laser_follower(cam2:Camera)
		{
			cam = cam2
			//some camera stuff should go here
			vid = new Video( cam.width, cam.height)
			vid.attachCamera( cam)
			
			curr = new BitmapData( cam.width, cam.height)
			prev = new BitmapData( cam.width, cam.height)
			
			
			lasertime =  new Timer( 1000/ cam.fps)
			lasertime.addEventListener(TimerEvent.TIMER, laser_loop)
			lasertime.start()
			
			
		}
		public function stop():void
		{
			lasertime.stop()
		}
	
		
		private function laser_loop(e:TimerEvent = null):void
		{

			curr.draw( vid)
			
			//var active_rect:Rectangle = activeRect( curr, prev)
			var tmpposition:Point = findBrightest(curr) //findBrightest( curr_small, active_rect)
			
			if( tmpposition.x != position.x && tmpposition.y != position.y)
			{
				if( tmpposition.x > 0 && tmpposition.y > 0)
				{	
					position.x = tmpposition.x ;
					position.y = tmpposition.y ;
  
					this.dispatchEvent( new Event(moveEvent) );
				}
			}
			prev = curr.clone();
		}

		private function findBrightest( bm:BitmapData, rect:Rectangle = null):Point
		{
			var threshold:uint = 0xff222222;
			var bp:Point = new Point(0,0)
			var bv:uint = 0
			var istuff:ImageStuff = new ImageStuff();
			
			if(rect == null){
				rect = bm.rect }
			prev.draw( curr,null,null,"difference");
			for( var x:int = rect.topLeft.x ; x <= rect.bottomRight.x ; x = x + 2)
			{
				for( var y:int = rect.topLeft.y ; y< rect.bottomRight.y ; y = y + 2)
				{
					var tmpv:uint = bm.getPixel(x, y);
					var diffv:uint = prev.getPixel(x,y);
					if( istuff.AbrighterB( tmpv, bv) && istuff.AbrighterB( diffv, threshold) )
					{
						if( istuff.AbrighterB( tmpv, 0xff909090) )
						{
							bv = tmpv;
							bp.x = x; bp.y = y
						}
					}
				}
			}
			
			return bp				
		}
		

		


	}//class
}//package