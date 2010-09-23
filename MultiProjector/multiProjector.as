package MultiProjector
{
	import ImageStuff.ImageStuff;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Camera;
	
	import structuredlight.CameraProjecterMap2;
	import structuredlight.Sandbox3;

	public class multiProjector
	{
		
		
		public var sbList:Array = new Array();
		public var projector_count:int ;
		public var graycode_divider:int = 8;
		
		//STATES
		private var state:Array = ["INIT", "CALLIBRATE" , "COMBINE" ,"DONE"];
		private var current_state:int = 0;
		private var currentProj:int = 0;
		private var _timeout:int = 0 ;
		public var _threshold:int =  20 ; 
		public var _tone:uint = 0x7f7f7f;
		
		private var cam:Camera ;
		private var stage:Stage ;
		
		public function multiProjector( camera:Camera, stage_copy:Stage )
		{
			cam = camera;
			stage = stage_copy;
		}

		public function callib_3( threshold:int = 20 , projectors:int = 3, timeout:int = 300):void
		{
			switch( state[current_state] )
			{
				case "INIT":
					_threshold = threshold;
					_timeout = timeout ;
					projector_count = projectors;
					currentProj = 0;
					sbList = new Array();
					current_state ++;
					callib_3();
					
					break;
				case "CALLIBRATE":
					if( currentProj < projector_count)
					{
						//make mask image here
						//make left rectangle
						var s:Shape = new Shape();
						s.graphics.beginFill( 0xff000000, 1.0);
						s.graphics.drawRect( 0 ,0, (currentProj / projector_count )* ( stage.width ) , stage.height);
						//make right rectangle
						var w:Shape = new Shape();
						w.graphics.beginFill( 0xff000000, 1.0);
						w.graphics.drawRect( ((currentProj + 1) / projector_count) * stage.width , 0, stage.width, stage.height);
						//make image for mask
						var bmd:BitmapData = new BitmapData( stage.width, stage.height, true, 0x00000000 );
						bmd.draw( s );
						bmd.draw( w);
						var mascara:Bitmap = new Bitmap( bmd);
						
						
						// start callibration and add it to sblist
						var sb1:Sandbox3 = new Sandbox3( stage, cam, stage.width / graycode_divider , stage.height / graycode_divider );
						sb1.thresh_hold = _threshold;
						sb1.TPTimeout = _timeout ;
						sb1.state_rate = _timeout ;
						sb1.white_tone = _tone;
						sbList.push(sb1);
						sb1.callibrate();
						sb1.addEventListener( "CALLIBRATE_DONE", callib_3 );
						
						
						//display mask image here
						if( stage.getChildByName( "mascara") )
						{
							stage.removeChild( stage.getChildByName( "mascara") );
							stage.addChild( mascara ).name = "mascara";		
						}
						else
						{
							stage.addChild( mascara ).name = "mascara";	
						}
						
						
						currentProj++ ;
					}
					else
					{
						//remove mask image
						stage.removeChild( stage.getChildByName( "mascara") );
						
						current_state++ ;
						callib_3();
					}
					
					
					break;
				case "COMBINE":
					// stitcher could go here, but the threshhold might need to change.
					current_state++ ;
					callib_3();
					break;
				case "DONE":
					current_state = 0;
					currentProj = 0;
					break;
			}			
		}
		
		
		
	/*	public function stitch( threshold:uint = 0xff777777):CameraProjecterMap2
		{
			//_log.text += " stitcher2 called";
			
			// FIND THE ACTIVE AREAS
			// find the differences between the black and whit frames
			//
			var diffList:Array = new Array()
			for( var n2:int = 0 ; n2 < sbList.length ; n2++)
			{
				//_log.text += " \n sb 1 differenceing";
				var sb:Sandbox3 = sbList[n2];
				
				diffList.push( differences( sb, threshold ) );
			}
			
			
			
			
			//
			// initaialize a new map
			//	
			var result:CameraProjecterMap2 = new CameraProjecterMap2();
			result = sbList[0].graymap.clone() ;
			
			
			
			
			//
			// go through all of the sandbox3's and put a point in the result if the area is active.
			//		if two active spots overlap, take the brightest.
			for( var x:int = 0 ; x < result.width() ; x++ )
			{
				for( var y:int = 0 ; y < result.height() ; y++ )
				{
					var found:int = -1;
					var brightest:uint = 0;
					for( var n:int = 0 ; n < diffList.length ; n++)
					{
						var b:BitmapData = diffList[n];	
						var pixel:uint = b.getPixel( x, y);
						if( pixel > 0x000000 )
						{
							if( pixel > brightest )
							{
								result.map[x][y] = sbList[n].graymap.getMapXY(x,y); 
								found = n ;
								brightest = uint( pixel); 
							}
						}
						if( found < 0)
						{
							result.map[x][y] = new Point(-1,-1);
						}
					}
				}
			}
						
			//_log.text += "\n stitcher2 done";
			return result;
		}
		*/
		//
		//  Difference black frames and white frames.
		//		then, turn everything below a certain threshold black .
		//
		public function differences( sb:Sandbox3 , threshold:uint = 0xff444444):BitmapData
		{
			
			var tmp:ImageStuff = new ImageStuff();

			var mergedB:BitmapData = tmp.mergeArray( sb.BFrames );
			var mergedW:BitmapData = tmp.mergeArray( sb.WFrames );

			var difference:BitmapData = mergedB.clone();
			
			difference.draw( mergedW, new Matrix() , new ColorTransform(), BlendMode.DIFFERENCE); 
			difference.threshold( difference, difference.rect, new Point(0,0), "<=" , threshold, 0xff000000);
			
			return difference;	
		}
	}
}