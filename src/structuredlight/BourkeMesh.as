package structuredlight
{
	/*
		Load, parses, and exports Paul Bourke's Warp-Mesh  http://local.wasp.uwa.edu.au/~pbourke/dataformats/meshwarp/
		
	
	
	
	
	*/
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	

	public class BourkeMesh extends EventDispatcher
	{
			public 			var meshString:String ;
			public 	  		var width:int = 0; 
			public 			var height:int = 0;
			public 			var type:int = 0;//note: only type 2 rectangular meshes currently supported
			//
			//   This is a 2d array that holds the values as an object like this {  x: x2, y: y2, u: u2 , v : v2 , i: type, index: int(index) };
			public 			var mesh2dArray:Array; 
			
			//these are used with the flashes drawTriangles function   
			//   http://www.flashandmath.com/advanced/p10triangles/index.html 
			// note: xy vertices go from -1 to 1 , but the drawtriangles function takes xy from 0 to image.width
			//   	 	and uvVertices go from 0 to 1
			public          var indices:Vector.<int>;
			public 			var xyVertices:Vector.<Number>;
			public 			var uvVertices:Vector.<Number>;
			// inverted is for different styles of players. Warplayer95 uses un-inverted, quartz composer uses inverted
			public 			var _inverted:Boolean = true;

			
			
			public var _completeLoadingEvent:String = "Bourke Mesh File Done";
			public	var _verbose:Boolean = false;
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
				var fileFilt:FileFilter = new FileFilter("mesh filter"," *.data; *.dat");
				fileRef= new FileReference();
				fileRef.browse( [ fileFilt ] );
				fileRef.addEventListener(Event.SELECT, selectHandler);
				fileRef.addEventListener(Event.COMPLETE, completeHandler);
			}
			
			private function selectHandler(e:Event):void
			{
				fileRef.load()
			}
			private function completeHandler(e:Event):void
			{
				meshString = fileRef.data.toString() ;	
				getDimensions();
				
				parse( _inverted);
				
				var ev:Event = new Event( _completeLoadingEvent);
				this.dispatchEvent(  ev);
				//displayMesh( meshString);
			}
			
			public function importDefault():void
			{
				var urldr:URLLoader = new URLLoader();
				urldr.addEventListener(Event.COMPLETE, defaultImportComplete);
				urldr.dataFormat = URLLoaderDataFormat.TEXT;
				urldr.load( new URLRequest("maps/warpfish.data"));
			}
			private function defaultImportComplete(e:Event):void
			{
				e.target.removeEventListener( e.type, arguments.callee );
				meshString = e.target.data;
				getDimensions();
				parse(_inverted);
				
				var ev:Event = new Event( _completeLoadingEvent);
				this.dispatchEvent(  ev);
			}
			private function parse( inverted:Boolean = true):void
			{
															
					var indexs:Array = meshString.split( "\n");
					type =  int(indexs[0]);
					
					var mesh:Array = indexs.slice(2);//TAKE EVERYTHING AFTER THE FIRST TWO LINES
					var dimensionsString:String = indexs[1]; //PARSE DIMENSIONS FROM SECOND LINE
					var dimensions:Array = splitAtWhiteSpace( dimensionsString); 
					
					width = int( dimensions[0]) ;
					height = int(dimensions[1]) ;
					mesh2dArray = new Array( width );
				
					var index:int = 0 ;
					
					indices = new Vector.<int>;
					xyVertices = new Vector.<Number>;
					uvVertices = new Vector.<Number>;
					
					
					//
					//
					////
					////  parse the String into usable numbers
					//  
					//

					
					for( var x1:int = 0; x1 < width; x1++)
					{
						mesh2dArray[x1] = new Array( height);
					}
					
					
					
					//var sh1:Shape = new Shape();
					_log += " indexs length:"+ indexs.length + " \n" ;//+ "  " +meshArray.toString();
					_log += " mesh array length : " + mesh.length + "\n";
					_log += " Loaded mesh :  width" + width + "  height "+ height + " \n"; 
					
					//
					//  Do the uv mapping with the triangles
					//
					//
					
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
							
							var cent:Array =  splitAtWhiteSpace( mesh[n]);
							
							if( _verbose)
								_log += " ( " + xc +" ,  " + yc+")";
							
							
							var x2:Number = Number(cent[0]) ;
							var y2:Number = Number(cent[1]) ;
							var u2:Number = Number(cent[2])  ;
							var v2:Number = Number(cent[3])   ;
							
							if( inverted ){
								y2 =  - Number(cent[1]) 	
								v2 = 1 - Number(cent[3]) ;
							}
							
							var vert:Object = {  x: x2, y: y2, u: u2 , v : v2 , i: cent[4] , index: int(index) };
							
							//if( _verbose)
							//	_log += "\n x: " + vert.x + " y:"+ vert.y + " u:"+ vert.u +" v:"+ vert.v +" i:"+ vert.i +   " indx:"+ vert.index ; 
							
							mesh2dArray[xc][yc] = vert ;
							
							xyVertices.push( vert.x);
							xyVertices.push( vert.y);
							uvVertices.push( vert.u);
							uvVertices.push( vert.v);
							
							index++;
						}			
					}
					
					for( var x:int = 0; x < mesh2dArray.length - 1 ; x++)
					{
						for( var y:int = 0 ; y < mesh2dArray[0].length - 1; y++)
						{
							var center:Object = mesh2dArray[ x ][ y ];
							var right:Object = mesh2dArray[x + 1][ y ];
							var down:Object = mesh2dArray[ x ][ y + 1 ];
							var diag:Object = mesh2dArray[x + 1][ y + 1];
							if( center.i > 0 && right.i > 0 && down.i > 0 && diag.i > 0)
							{
								//push triangles
								//  ____
								// |\ T|    T = top triangle
								// |B\ |	B = bottom triangle
								// |__\|
								//
								//first: top triange
								indices.push( center.index );
								indices.push( right.index );
								indices.push( diag.index );
								//
								//  second: bottom triangle 
								indices.push( center.index );
								indices.push( down.index );
								indices.push( diag.index );
								
							}
						}
					}
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
						// DONT DRAW THE CORNERS or EDGES. THEY WILL GET DRAWN BY THE NEIGHBORS. 
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
							if( Number(m[2]) < 0 && Number(m[3]) < 0 && Number(m[4]) < 0)
								sh1.graphics.lineStyle(3,0xaaffaa);
							else if( Number(left[2]) < 0 && Number(left[3]) < 0 && Number(left[4]) < 0 )
								sh1.graphics.lineStyle(2,0xaaff00);
							else if( Number(right[2]) < 0 && Number(right[3]) < 0 && Number(right[4]) < 0 )
								sh1.graphics.lineStyle(2,0xaaff11);
							else if( Number(up[2]) < 0 && Number(up[3]) < 0 && Number(up[4]) < 0 )
								sh1.graphics.lineStyle(2,0xaaff22);
							else if( Number(down[2]) < 0 && Number(down[3]) < 0 && Number(down[4]) < 0 )
								sh1.graphics.lineStyle(2,0xaaff33);
							else
								sh1.graphics.lineStyle(1,0x00fd00);

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