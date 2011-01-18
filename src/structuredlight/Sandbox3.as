/*
	SANDBOX. Structured light library  version: 0.1 
		by: Cody Smith
		with lots of help from : Santa fe complex, and Steven Guerin.

		A sandbox object uses a Projector( or monitor) and a web cam to make a map of the projected space. 
		It tries to accuratly map the coordinates of projected pixels to those of the camera. It uses a bunch of gray code lines
		 to represent every pixel coming out of the projector. Then, the camera takes photos of those lines. Next, a library called CameraProjectorMap
		 tries to interperate those photographs and make a map. 
		 
		 important functions:
		 	SandBox3( stage, Camera) : The constructor. This takes a reference to the stage( allways the same. just stage)  and a camera
	
		 	callibrate() : makes the callibration loop run. This is neccessary. 
		 		It works by taking some pictures of a black screen and a white screen. Then it merges them all together, thus forming an average( median)
		 		pixel at every point. 
		 		Then, it displays the gray code lines. It uses the average( median) pixel as a reference. If the pixel from the gray code picture 
		 		is brighter, then that digit is a 1. Otherwise, it is a zero for that digit.
		 		It does that for every pixel of every image and makes a map.
		 			 The map is a 2d array the same size as the camera image. every pixel on the map holds a point representing the gray coded position displayed on the screen
	 
		 	
		 properties:
		 	graymap: A CameraProjectoerMap. The variable map in gray map holds mapped out points.
		 		It is a 2d array of Points(). It also has some usefull functions like Gaussion() blur. and countours(), and clone()
		 		
		 	makeimage() : returns a BitmapData of the image representing the map. x goes from black to green, and y goes from black to blue
		 	
		 	
		 
		 variables:
			TPTimout: Take Picture Timeout. This is how many milliseconds it waits to take a picture after the line image was told to be displayed.

			state_rate: The number of milliseconds between states. for exampleif this is 200 it will take 200 milliseconds for fourth line image 
				to switch to the fifth line image 	

		 	current_state: a string showing the current state
		 	
		 Events:
		 		"CALLIBRATE_DONE" : this is sent out when the callibration is done.
		 			 	
		 		example:
		 				cam= Camera.getCamera( cam_name )
						cam.setMode( 320 , 240 , 39)
						
						var sb = new sandbox3( stage, cam)
						sb.callibrate()
						sb.addEventListener("CALLIBRATE_DONE", showimage)
			
						function showimage(e:event):void
						(
							stage.addChild( new Bitmap( sb.makeImage() ) )
						}
						

*/
package structuredlight
{
	import ImageStuff.ImageStuff;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import structuredlight.MapFileOpener;
	
	public class Sandbox3 extends EventDispatcher
	{
		import structuredlight.GrayCode
		import flash.display.Sprite
		import flash.display.BitmapData
		import flash.display.Graphics
		import flash.media.Camera
		import flash.utils.Timer
		import flash.events.*
		import flash.display.Stage
		import flash.utils.setTimeout
	
		
		public var cam:Camera //the camera
		public var vid:Video
		public var silverscreen:BitmapData //the screen the lines will be displayed on 
		private var stagecopy:Stage //a reference to the stage. You can not access stage directly from a class.
		
	//timing stuff	
		public var state_rate:int = 200 //how long it takes to switch states in callibration. 1000 would be one second between displaying the lines image.
		public var TPTimeout:int = 200//take picture timeout

		//
		//State machine stuff
		//
		private var state_array:Array = ["init"
				,"blacklight","blacklight","whitelight","whitelight"
				,"hlines"
				,"whitelight","blacklight"
				,"vlines"
				,"pause","makemap","done"]//maybe more to come
		
		public var current_state:String = "init"
		private var state_index:int = 0
		
		private var callibtimer:Timer
		private var currentimg:BitmapData
		private var max_digits:int // number of digits in the biggest gray code displayed
		private var curdigit:int = 0//current graycode digit being displayed
		
	//images
		public var mask:BitmapData
		public var BFrames:Array = new Array()
		public var WFrames:Array = new Array()
		public var VLines:Array =  new Array()
		public var HLines:Array = new Array()
		public var frames_store:Array = new Array()// all of the pictures can be referenced through here. mostly for debugging now.
		
		//A very important variable
		public var graymap:CameraProjecterMap2
		
		//developement
		public var fileO:MapFileOpener = new MapFileOpener()
		public var _width:int
		public var _height:int
	    public var thresh_hold:int = 40;
		public var white_tone:uint = 0xff7f7f7f;
		public var _DONE_EVENT_STRING:String = "CALLIBRATE_DONE";
		public var _DONE_EVENT:Event =  new Event(_DONE_EVENT_STRING, true)

		
		public function destroy():void
		{
			for each(var b:BitmapData in frames_store)
			{
				b.dispose();
			}
			frames_store  = HLines = VLines = WFrames = BFrames = null;
			mask = null;
		}
		
		public function Sandbox3(stagetmp:Stage, camb:Camera = null, width:int = 0 , height:int = 0)
		{
			//
			//		This takes:
			//			A reference to  the stage. and
			//			A reference to a camera
			//		It makes a map of camera to screen coordinates
			//			that map is stored in the variable graymap:CameraProjecterMap
			//
				
			_width = camb.width;
			_height = camb.height;
			if(width){
				_width = width;
			}
			if(height){
				_height = height;
			}

			
			stagecopy = stagetmp
			var md:GrayCode = new GrayCode()

			cam = camb
			vid = new Video(cam.width  , cam.height )
			vid.attachCamera( cam)

			currentimg = new BitmapData(cam.width  , cam.height   )
			silverscreen = new BitmapData( _width, _height, false, 0xff444444)

			
			max_digits = md.int2gray(_width).length

				//GO FULL SCREEN
			stagecopy.scaleMode = "noScale" ; //stagecopy.scaleMode = "showAll" ; //stagecopy.scaleMode = "noScale"
            stagecopy.align = "topLeft"
            stagecopy.frameRate = 60  
				
				//INITIALIZE VARIABLES
			BFrames = new Array()
			WFrames = new Array()
			VLines = new Array()
			HLines = new Array()
			graymap = new CameraProjecterMap2()
			mask = null
			//frames_store_contents= new Array()
			curdigit = 0
			current_state="init"

		}

		
		public function changeState( v:int = 1):void
		{
			//var stateIndex:int = state_array.indexOf( current_state )
			state_index += 1
			if(state_index >= state_array.length || state_index < 0){
				state_index = 0
			}
			current_state = state_array[ state_index]
		}
		
		//
		// Callibration lines
		//
		public function callibrate():void
		{
			BFrames = new Array()
			WFrames = new Array()
			VLines = new Array()
			HLines = new Array()
			graymap = null
			mask = null
			//frames_store_contents= new Array()
			curdigit = 0
			current_state="init"
				
			if(cam)
			{
				if (cam.muted)
				{
					cam.addEventListener( StatusEvent.STATUS, callibrateInit);//call it when its ready
				}
				else 
				{
					callibrateInit()
				}
			}
			
		}
		private function callibrateInit(e:StatusEvent = null):void
		{			
			
			    vid = new Video(cam.width  , cam.height )
				vid.attachCamera( cam)
				
				var nbmp:Bitmap = new Bitmap( silverscreen )
				nbmp.scaleX = stagecopy.width / _width;
				nbmp.scaleY = stagecopy.height/ _height;  //nbmp.scaleY = stagecopy.width / _width;
				stagecopy.addChild( nbmp ).name = "screen"
			
			//start timer to call callibrate loop
			//
				callibtimer = new Timer( state_rate)
				callibtimer.addEventListener(TimerEvent.TIMER, callibrateloop)
				callibtimer.start()
			
		}
		private function callibrateloop(e:TimerEvent = null):void
		{
			//trace("callibrate called. state: " + current_state + " . current digit index: " + curdigit)
			switch(current_state)
			{
				case "init":
					//stagecopy.displayState = "fullScreen"//this is not allowed for some reason
					//  pre-make images
					changeState()
					break;
				case "whitelight":
					//diplay white bg
					var whitebg3:BitmapData = new BitmapData( silverscreen.width, silverscreen.height, false, white_tone)
					//draw some checker board, so as not to effect the gain as much
					whitebg3.fillRect( new Rectangle( 0,0, whitebg3.width / 2, whitebg3.height / 2) , 0x000000 );
					whitebg3.fillRect( new Rectangle( whitebg3.width / 2, whitebg3.height / 2 , whitebg3.width / 2, whitebg3.height / 2) , 0x000000 );

					
					silverscreen.draw( whitebg3 )//draw white page
					
					setTimeout( takePic2, TPTimeout, new String(current_state), new int(curdigit) )	//take picture	
					changeState()
					break;
				case "blacklight":
					var blackbg:BitmapData = new BitmapData( silverscreen.width, silverscreen.height, false, 0xff000000)
					//checkerboard
					blackbg.fillRect( new Rectangle( 0,0 , blackbg.width/2 , blackbg.height / 2) , white_tone);
					blackbg.fillRect( new Rectangle( blackbg.width/2 , blackbg.height / 2 , blackbg.width/2 , blackbg.height / 2) , white_tone);
					silverscreen.draw( blackbg )
					
					setTimeout( takePic2, TPTimeout, new String(current_state), new int(curdigit) )	//take picture	
					changeState()
					break;
				case "hlines":
				//draw horizontal lines
					var whitebg:BitmapData = new BitmapData( silverscreen.width, silverscreen.height, false, white_tone)
					var g:GrayCode =  new GrayCode()
					var res:Shape = new Shape()
			
					res.graphics.lineStyle(0, 0xff000000)
			
					for (var y2:int = 0; y2 < silverscreen.height; y2++)
					{
						var gray:String = g.int2gray(y2)
						var indx:String
				 
						if ( curdigit < gray.length && curdigit >= 0)
						{
							indx = gray.charAt( gray.length - curdigit - 1)
						}
						else
						{
							indx = "0"
						}
				
						if ( indx == "1" )
						{
							res.graphics.moveTo( 0, y2)
							res.graphics.lineTo( silverscreen.width , y2) 
						} 
					}	
					whitebg.draw( res)
					silverscreen.draw( whitebg)	
					//
					//read camera goes here
					setTimeout( takePic2, TPTimeout, new String(current_state), new int(curdigit) )		
					//
					curdigit += 1
					if(curdigit >= max_digits)
					{
						changeState()
						curdigit = 0
					}

					break;
					
				case "vlines":
					//draw vertical lines
					var whitebg2:BitmapData = new BitmapData( silverscreen.width, silverscreen.height, false, white_tone)
					var g2:GrayCode =  new GrayCode()
					var res2:Shape = new Shape()
					res2.graphics.lineStyle(0, 0xff000000)
			
					for (var x2:int = 0; x2 < silverscreen.width; x2++)
					{
						var gray2:String = g2.int2gray(x2)
						var indx2:String
				 
						if ( curdigit < gray2.length && curdigit >= 0)
						{
							indx2 = gray2.charAt( gray2.length - curdigit - 1)
						}
						else
						{
							indx2 = "0"
						}
				
						if ( indx2 == "1" )
						{
							res2.graphics.moveTo( x2, 0)
							res2.graphics.lineTo( x2 , silverscreen.height) 
						} 
					}	
					whitebg2.draw( res2)
					silverscreen.draw( whitebg2)	
					
					//Take a picture
					//
					setTimeout( takePic2, TPTimeout, new String(current_state), new int(curdigit) )		
					//
					curdigit += 1
					if( curdigit >= max_digits)
					{
						curdigit=0
						changeState()
					}
					break;
					
				case "makemap":
					changeState()
					stagecopy.removeChild( stagecopy.getChildByName( "screen" ) )
					stagecopy.scaleMode = "noScale"
				
					prepareImages() ;
					
					graymap = new CameraProjecterMap2()
					graymap._threshold = thresh_hold;
					graymap._gray_width = _width;
					graymap._gray_height = _height;
					graymap._cam_width = cam.width;
					graymap._cam_height = cam.height;
					graymap._screen_width = stagecopy.width;
					graymap._screen_height = stagecopy.height;
					
					graymap.makeMap( mask, VLines, HLines , stagecopy.width, stagecopy.height)
					
					break;
				case "done":
				//clean up bit
					callibtimer.stop()
				    this.dispatchEvent( _DONE_EVENT)
					
					//vid = null  //attempt to detach camera
					break;

				default:
					changeState()
					break;
			}	
		}
		

		private function takePic2(curstate2:String, digit2:int):void
		{
			currentimg.draw( vid)
			if( vid)
			{	
				if( curstate2 == "whitelight" )
				{
					WFrames.push( currentimg.clone() )
				}
				else if( curstate2 == "blacklight")
				{
					BFrames.push( currentimg.clone() )
				}
				else if(curstate2 == "vlines" )
				{
					VLines[ digit2] = currentimg.clone()
				}
				else if(curstate2 == "hlines")
				{
					HLines[ digit2] = currentimg.clone()	
				}
				else
				{
					trace( "ERROR in takepic2")
				}
			}
		}



		//
		// Here is the hard part.
		//
		
		private function prepareImages():void
		{	
			trace("prepareImages called")

			
			var tmp:ImageStuff = new ImageStuff()
			var mergedB:BitmapData = tmp.mergeArray( BFrames)//merge 2 pictures. This helps remove noise
			var mergedW:BitmapData = tmp.mergeArray( WFrames)
			
			//merge black and white pictures. This finds the median for every pixel
			mask = mergedB.clone()//make it black
			mask.merge( mergedW, mergedW.rect , new Point(0,0), 256/2, 256/2, 256/2, 256)//blend with white
			// find active rectangle could go here
			frames_store = []
			frames_store = WFrames.concat( BFrames, VLines, HLines, mergedB, mergedW)
		

		}
		public function makeImage():BitmapData
		{
			if( !graymap){
				graymap = new CameraProjecterMap2()
				graymap.makeMap( mask, VLines, HLines, stagecopy.width , stagecopy.height)
			}
			return graymap.makeGrayArrayImage()
		}
		
		//import a local file
		public function importMap():void
		{
			graymap = new CameraProjecterMap2()
			
			fileO.importMap()
			fileO.addEventListener( "loaded Map", loaded)
		}
		private function loaded(e:Event = null):void
		{
			graymap = fileO.cam_map
		}
	

		
		

	
	
		
	

		

	}//end class 
}//end package
