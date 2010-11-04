package structuredlight
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileReference;
	

	public class BourkeMesh extends EventDispatcher
	{
			public 			var meshString:String ;
			public 	  		var width:int = 0; 
			public 			var height:int = 0;
			
			public var _completeLoadingEvent:String = "Bourke Mesh File Done";
			
			public var _log:String;
			
			public function BourkeMesh()
			{
				meshString = "" ;
				width = height = 0;
			}
			
			
			
			//
			//
			//LOAD FROM FILE
			//
			//
			//  here is an example on its use:
			/*
			
			public function importMesh():void
			{
			var pbm:BourkeMesh = new BourkeMesh();
			pbm.addEventListener( pbm._completeLoadingEvent, importComplete);
			pbm.importMeshFile();
			}
			public function importComplete( e:Event):void
			{
			_img.source = new Bitmap( e.target.displayMesh() );
			_log.text = " map loaded    width" + e.target.width + "  height " + e.target.height; 
			trace( " map loaded    width" + e.target.width + "  height " + e.target.height )
			}
			
			
			
			
			*/
			private var fileRef:FileReference;	
			public function importMeshFile():void
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
				meshString = fileRef.data.toString() ;	
				getDimensions();
				var ev:Event = new Event( _completeLoadingEvent);
				this.dispatchEvent(  ev);
				//displayMesh( meshString);
			}
			
			//
			//
			//  LOAD FROM PROJECTOR MAP
			//
			public function projMapToBourkeMesh( proj_map:ProjectorMap, xdivisions:int = 64, ydivisions:int = 48 ):BourkeMesh
			{
				var pm2s:projMapToString = new projMapToString( proj_map ) ;
				meshString = pm2s.MakeUVMap4Quartz( xdivisions, ydivisions);
				getDimensions();
				return this;
			}
			
			
			//
			//
			// SAVE THE MESH TO A FILE
			//
			public function saveQuartzMesh():void
			{	
				if( meshString)
				{
					var fr:FileReference
					fr = new FileReference();
					//var str:String = MakeUVMap4Quartz(xdivisions, ydivisions );
					fr.save( meshString, "QuartzPBMesh.data");				
				}
			
			}
				
			//
			// helper function 
			//
			
			public function getDimensions():Boolean
			{
				if( meshString)
				{
					var indexs:Array = meshString.split( "\n");					
					var dimensionsString:String = indexs[1]; //PARSE DIMENSIONS FROM SECOND LINE
					var dimensions:Array = splitAtWhiteSpace( dimensionsString); 
					width = int( dimensions[0]) ;
					height = int(dimensions[1]) ;
					return true;
				}
				else
					return false;
			}
			
			//
			//
			//   Mesh to bitmap
			//
			//
			// THIS MAKES AN IMAGE THAT REPRESENTS THE MESH 
			//
			//    good for debugging
			//  
			//    currently only type 2 maps ( normal cartesian coordinates) are supported
			//    polar coordinates are not supported
			//
			
			public function displayMesh():BitmapData
			{
				if( !meshString )
				{
					trace("mesh String undefined");
					return null;
				}
				
				var indexs:Array = meshString.split( "\n");
				
				var type:int = int(indexs[0]);
				
				
				var mesh:Array = indexs.slice(2);//TAKE EVERYTHING AFTER THE FIRST TWO LINES
				
				var dimensionsString:String = indexs[1]; //PARSE DIMENSIONS FROM SECOND LINE
				var dimensions:Array = splitAtWhiteSpace( dimensionsString); 
				width = int( dimensions[0]) ;
				height = int(dimensions[1]) ;
				
				var bmd:BitmapData = new BitmapData( 640,480,false,0x000000);
				var sh1:Shape = new Shape();
				_log = " indexs length:"+ indexs.length + " \n" ;//+ "  " +meshArray.toString();
				_log += " mesh array length : " + mesh.length + "\n";
				_log += " Loaded mesh :  width" + width + "  height "+ height + " \n"; 
				
				for ( var n:int = 0 ; n < mesh.length; n++)
				{
					var tmp:String = mesh[n];
					var m:Array = splitAtWhiteSpace(tmp);//split at white spaces
					
					if( m.length != 5){
						// THIS LINE DOES NOT LOOK RIGHT
						// SKIP IT. it's usually like an extra carrier return at the endof the page. 
						_log += "ERROR m.lengt != 5 " + m + "   at  " + n;
					}
					else
					{
						//
						// get corrected x,y
						var xc:int = n % width;
						var yc:int = Math.floor( n/width);
						
						var drawPoint:Boolean = true;
						// DONT DRAW THE CORNERS. THEY WILL GET DRAWN BY THE NEIGHBORS. 
						if( yc <= 0 || yc == height - 1 || xc <= 0 ||  xc == width - 1)//right
						{		
							drawPoint = false;
							_log += "*";
						}
						
						//
						//   DRAW SOME STUFF
						//
						if( drawPoint )
						{
							//FIND NEIGHBORS
							var up:Array = splitAtWhiteSpace( mesh[n - width]);
							var down:Array = splitAtWhiteSpace( mesh[n + width]);
							var left:Array = splitAtWhiteSpace( mesh[n - 1]);
							var right:Array = splitAtWhiteSpace( mesh[n - 1]);
							_log += " ( " + xc +" ,  " + yc+")";
							//
							// draw xy map
							//
							sh1.graphics.lineStyle(1,0x00ff00);
							//up
							sh1.graphics.moveTo( bmd.width * (Number( m[0] ) + 1)/2 , bmd.height * (Number( m[1] ) + 1)/2); 
							sh1.graphics.lineTo( bmd.width * (Number( up[0] ) + 1)/2 , bmd.height * (Number( up[1] ) + 1)/2);
							//down
							sh1.graphics.moveTo( bmd.width * (Number( m[0] ) + 1)/2 , bmd.height * (Number( m[1] ) + 1)/2); 
							sh1.graphics.lineTo( bmd.width * (Number( down[0] ) + 1)/2 , bmd.height * (Number( down[1] ) + 1)/2);
							//left
							sh1.graphics.moveTo( bmd.width * (Number( m[0] ) + 1)/2 , bmd.height * (Number( m[1] ) + 1)/2); 
							sh1.graphics.lineTo( bmd.width * (Number( left[0] ) + 1)/2 , bmd.height * (Number( left[1] ) + 1)/2);
							//right
							sh1.graphics.moveTo( bmd.width * (Number( m[0] ) + 1)/2 , bmd.height * (Number( m[1] ) + 1)/2); 
							sh1.graphics.lineTo( bmd.width * (Number( right[0] ) + 1)/2 , bmd.height * (Number( right[1] ) + 1)/2);
							
							//
							//draw u,v map
							//
							if( Number(m[2]) >= 0 && Number(m[3]) >= 0 && Number(m[4]) >= 0)
							{
								//up
								sh1.graphics.lineStyle(2,0x0fffff);
								if( Number(up[2]) >= 0   &&   Number(up[3]) >= 0 )
								{
									sh1.graphics.moveTo( Number( m[2] ) * bmd.width , Number( m[3] ) * bmd.height ); 
									sh1.graphics.lineTo( Number( up[2]) * bmd.width , Number( up[3]) * bmd.height );
								}
								//down
								if( Number(down[2]) >= 0   &&   Number(down[3]) >= 0 )
								{
									sh1.graphics.moveTo( Number( m[2] ) * bmd.width , Number( m[3] ) * bmd.height ); 
									sh1.graphics.lineTo( Number( down[2]) * bmd.width , Number( down[3]) * bmd.height );
								}
								if( Number(left[2]) >= 0   &&   Number(left[3]) >= 0 )
								{	//left
									sh1.graphics.moveTo( Number( m[2] ) * bmd.width , Number( m[3] ) * bmd.height ); 
									sh1.graphics.lineTo( Number( left[2]) * bmd.width  , Number( left[3]) * bmd.height );
								}
								if( Number(right[2]) >= 0   &&   Number(right[3]) >= 0 )
								{	//right
									sh1.graphics.moveTo( Number( m[2] ) * bmd.width , Number( m[3] ) * bmd.height ); 
									sh1.graphics.lineTo( Number( right[2]) * bmd.width , Number( right[3]) * bmd.height );
								}
								
								//
								//
								//connect uv and xy
								// this looks cool, but doesn't really serve a purpose, and really clutters the screen.
								/*
								sh1.graphics.lineStyle( 1, 0xff0000 );
								sh1.graphics.moveTo( bmd.width * (Number( m[0] ) + 1)/2 , bmd.height * (Number( m[1] ) + 1)/2); 
								sh1.graphics.lineTo( Number(m[2]) * bmd.width , Number(m[3]) * bmd.height );
								*/
								
							}	
						}
					}	
				}
				
				bmd.draw(sh1);
				
				return bmd;
			}
			//
			// A FUNCTION TO HELP PARSE
			//
			private function splitAtWhiteSpace( s:String):Array
			{
				return s.replace(/^\s+/,"").replace(/\s+$/,"").split(/\s+/);//split at white spaces
			}
			
			
			
		
	}
}