package MultiProjector
{
	/*
	MultiImageBlend:
		this library is made to calculate the opcaities of possibly overlapping projected images. 
		It is made to work wih the Multi projector Callibration technique.
		It assumes that all of the images are of the same dimensions, and may throw strange errors if they are not. 
		It also assumes that black is outside of the image and all other colors are inside the image. 	
	
		Important functions:
			blendBitmaps( Array_of_bitmaps)   .  This should allwatys be the first function called. 
			getOpacities( x , y )   . This returns a list of opacities( 0.0 to 1.0 ). The list index's match those of the Array_of_bitmaps. 
		

	
	
		algorithm
			it first finds all of the overlaps, It treats black as clear.
			then all of the edges inside of the overlaps. Each edge has an edge type classified by which image it is at the side of.
			then it measures a distance from every edge to every pixel
			then it uses the distances to calculate an opacity/ 
	
	*/
	import ImageStuff.Pixel;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	public class MultiImageBlend extends EventDispatcher
	{
		public var overlapArray:Array;
		public var edges:Array = [];
		public var overlaps:Array = [];
		public var _log:String = "";
		private var imagesReference:Array = [];
		public var ready:Boolean = false;
		public var width:int = 0;
		public var height:int = 0;
		public var DONE_EVENT:String = "MULTI IMAGE BLEND DONE";
		
		public function MultiImageBlend()
		{
			
			
		}
		
		// todo function blend bitmapdatas
		
		
		public function blendBitmaps( images:Array ):void//takes an array of bitmaps
		{
			imagesReference = images;
			var bmtmp:Bitmap = images[0];
			width = images[0].width;
			height = images[0].height;
			//initialise overlap array
			//
			overlapArray = new Array( bmtmp.width);
			for( var w:int=0; w < bmtmp.width; w++)
			{
				overlapArray[w] = new Array( bmtmp.height);
				for( var h:int=0; h < bmtmp.height; h++)
				{
					overlapArray[w][h] = { overlaps:[], distances:[]  };
				}
			}
			
			// fill overlap array
			//
			for(var n:int = 0 ; n < images.length ; n++)
			{
				var bm:Bitmap = images[n];
				for( var x:int = 0 ; x < bm.width ; x++)
				{
					for( var y:int = 0; y < bm.height ; y++)
					{
						var pix_in:uint = bm.bitmapData.getPixel(x,y);	
						overlapArray[x][y].distances[n] = -1;
						if( pix_in > 0 )//isBlack( pix_in ))
						{
							overlapArray[x][y].overlaps.push(n);
							
						}		
					}						
				}
			}
			
			for( x = 1 ; x < bm.width - 1 ; x++)
			{
				for( y = 1; y < bm.height - 1 ; y++)
				{
					
					// overlaps
					//
					var center:Array = overlapArray[x][y].overlaps;
					var up:Array = overlapArray[x][y-1].overlaps;
					var down:Array = overlapArray[x][y+1].overlaps;
					var left:Array = overlapArray[x-1][y].overlaps;
					var right:Array = overlapArray[x+1][y].overlaps;
					
					//var edge:Object;

					//
					//
					if( center.length == 1)// not overlapping
					{
						var tmpbmp1:Bitmap = images[center[0]];
					}
					else if( center.length == 0)// nothing there
					{
					}
					else if( center.length > up.length)//edges, might not need all of these.
					{//an imporvement in speed could come from only using every other edge found
						edges.push({ loc:new Point(x,y), type:setAminusB(overlapArray[x][y].overlaps, overlapArray[x][y-1].overlaps )  } );
						overlaps.push( { loc:new Point(x,y), set:overlapArray[x][y].overlaps} );
						
					}
					else if( center.length > down.length)
					{
						edges.push({ loc:new Point(x,y) , type:setAminusB(overlapArray[x][y].overlaps, overlapArray[x][y+1].overlaps ) });
						overlaps.push( { loc:new Point(x,y), set:overlapArray[x][y].overlaps} );
						
					}
					else if( center.length > left.length)
					{
						edges.push({ loc:new Point(x,y), type:setAminusB(overlapArray[x][y].overlaps, overlapArray[x-1][y].overlaps ) });
						overlaps.push( { loc:new Point(x,y), set:overlapArray[x][y].overlaps } );
						
					}
					else if( center.length > right.length)
					{
						edges.push({ loc:new Point(x,y) , type:setAminusB(overlapArray[x][y].overlaps, overlapArray[x+1][y].overlaps ) });
						overlaps.push( { loc:new Point(x,y), set:overlapArray[x][y].overlaps} );
						
					}
					else
					{
						overlaps.push( { loc:new Point(x,y), set:overlapArray[x][y].overlaps} );
					}			
				}
			}
					
			_log += " number of edges = " + edges.length;
			_log += " number of overlaps " + overlaps.length;
			blendAgentBased();
			
		}
		
		
		
		//
		//
		//  Agent based approach, hopefully faster
		//
		//
		public function blendAgentBased():void
		{
			// at first all the agents are edges
			//
			var agents:Array = [];
			for each( var ed:Object in edges)
			{
				agents.push({ loc:ed.loc, type:ed.type, distance:0  })	
			}
			var agents_next:Array = [];
			
			// initialise the 3d array that is the map
			//
			//var bmtmp:Bitmap = imagesReference[0];

			
			while( agents.length > 0 )
			{
				agents_next = [];
				for each( var ag:Object in agents )
				{
					if( overlapArray[ ag.loc.x][ ag.loc.y].overlaps.length == 0 )
					{}
					else if( ag.loc.x > 0 && ag.loc.x < width - 1 && ag.loc.y > 0 && ag.loc.y < height -1 )
					{
						var agentType:Number = ag.type[0];
						// look at cardinal directions, up , down, left , right.
						if( overlapArray[ ag.loc.x ][ ag.loc.y - 1].distances[ agentType] < 0 )
						{
							agents_next.push( { loc:new Point(ag.loc.x, ag.loc.y-1)  , type:ag.type , distance:ag.distance+1} );
							overlapArray[ ag.loc.x][ag.loc.y-1].distances[agentType] = ag.distance + 1;
						}
						if( overlapArray[ ag.loc.x ][ ag.loc.y + 1].distances[ agentType] < 0 )
						{
							agents_next.push( { loc:new Point(ag.loc.x, ag.loc.y+1)  , type:ag.type, distance:ag.distance+1} );
							overlapArray[ ag.loc.x][ag.loc.y+1].distances[agentType] = ag.distance + 1;
						}
						if( overlapArray[ ag.loc.x - 1][ ag.loc.y ].distances[ agentType] < 0 )
						{
							agents_next.push( { loc:new Point(ag.loc.x-1, ag.loc.y)  , type:ag.type, distance:ag.distance+1} );
							overlapArray[ ag.loc.x-1][ag.loc.y].distances[agentType] = ag.distance + 1;
						}
						if( overlapArray[ ag.loc.x + 1][ ag.loc.y ].distances[ agentType] < 0 )
						{
							agents_next.push( { loc:new Point(ag.loc.x+1, ag.loc.y)  , type:ag.type, distance:ag.distance+1} );
							overlapArray[ ag.loc.x+1][ag.loc.y].distances[agentType] = ag.distance + 1;
						}					
					}// ..fi
				}// .. for agents
				
				// copy next agentlist to the agent list
				//
				agents = [];
				for each( var ag2:Object in agents_next)
				{
					agents.push( ag2 );	
				}
				
			}//...while agents exist
			
			_log += " \n agent based distances DONE ";
			this.dispatchEvent( new Event( DONE_EVENT));
			ready = true;
		}
		
		public function getDistances( x:int , y:int):Array
		{
			var result:Array=[];
			if( ready &&  x < width && y < height)
			{
				result = overlapArray[x][y].distances;
			}
			return result;
		}
		public function getOpacities( x:int , y:int):Array
		{
			var distances:Array = getDistances(x,y);
			var opacities:Array = new Array( distances.length );
			for( var i2:int=0; i2 < distances.length; i2++)
			{
				opacities[i2] = 0;
			}
			var sum:Number = 0 ; 
			var set:Array = overlapArray[x][y].overlaps;
		
			for each ( var s2:Number in set)
			{
				sum += distances[s2];
			}
			for each( var s3:Number in set)
			{
				opacities[ s3] = distances[ s3] / sum;
			}

			return opacities;
		}
		
		public function getImage():BitmapData
		{
			
			var result:BitmapData = new BitmapData( width, height, true, 0); 
			//copy images
			var img_copies:Array = []
			for each( var ig:Bitmap in imagesReference )
			{
				var bm2:Bitmap = new Bitmap( ig.bitmapData.clone() );
				img_copies.push( bm2);
			}
			if( ready)
			{
				for( var x:int = 0 ; x < width ; x++)
				{
					for( var y:int = 0 ; y < height; y++)
					{
						var opacTs:Array = getOpacities(x,y);
						for( var ni:int = 0 ; ni < img_copies.length; ni++)
						{
							var bm:Bitmap = img_copies[ni];
							var pixIn:uint = bm.bitmapData.getPixel(x,y);
							var pixOut:uint = 0;//clear black
							if( !isBlack( pixIn) )
							{
								var opacity:Number = opacTs[ni];
								pixOut = (Math.floor(opacity * 255)<< 24) | pixIn 	;
							}
							bm.bitmapData.setPixel32( x,y,pixOut);
						}
					}
				}
			}
			
			for each( var img:Bitmap in img_copies )
			{
				result.draw( img);
			}
			_log += "\n image made " +  result.width + ", " + result.height;
			return result;
		}
		
		
		//
		//   accessory functions
		//			these could probably be put in another place
		//
		//
		//
		//
		//
		//
		public function isBlack( pix:uint):Boolean
		{
			var pix2:Pixel = new Pixel(pix);
			if( pix2.b < 5 && pix2.g < 5 && pix2.r < 5)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function setAminusB(a:Array , b:Array):Array
			{
				//     
				//    This takes two arrays of Numbers, A and B.
				//	  It returns all of the elements that are not in both A and B. 		    
				//
				//   important it only works on arrays of numbers, and won't return any errors. 
				//    
				//
				
				a.sort();
				b.sort();
				
				var result:Array = [];
				
				var bindx:int = 0 ;
				for( var aindx:int = 0 ; aindx < a.length ; aindx++)
				{
					//_log.text += " . ";
					if( a[ aindx] == b[bindx] && bindx < b.length)
					{
						bindx++;
					}
					else
					{
						result.push(a[ aindx]);
					}
				}
				return result;
			}
			
			
		public 	function aIsSubsetOfB( a:Array, b:Array):Boolean
			{
				// 
				//  this takes two arrays of integers. It returns true if a is a subset of b
				//     note identical sets are considered subsets 
				//			examples [1,2,3] is a subset of [1,2,3]
				//					[1,3] is a subset of [1,2,3]
				//					[1,2,3] is not a subset of [1,2]
				//					[1,3] is NOT a subset of [3,5,6]
				//					
				//
				if( a && b)
				{
					if( b.length < a.length)
						return false;
					a.sort();//i assume this makes the find function faster
					b.sort();
					for each( var ax:Number in a)
					{
						//_log.text += " " + ax + " " ;
						if( b.indexOf( ax) < 0 ){
							//_log.text += " b.indexOf( ax) = "+b.indexOf( ax)+ "  , " ;
							return false;
						}
					}
					return true;
				}
				return false;
			}
			
		}
	
}