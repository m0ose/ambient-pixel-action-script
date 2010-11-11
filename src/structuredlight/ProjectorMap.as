package structuredlight
{
	import com.nodename.Delaunay.*;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import structuredlight.*;
	
	public class ProjectorMap extends EventDispatcher
	{
		public var cam_map:CameraProjecterMap2//camera to projector
		public var rev_map:Reversemap//projector to camera, uninterpolated
		public var proj_map:Array//projector to camera after interpolation
		//public var cam_map_interpolated:Array//camera to projector after interpolation. sparse map
		
		public var mypoints:Vector.<Point> ; //= new Vector.<Point>
		public var triad:Voronoi ; //all the triangles
		
		public var DONE_EVENT_STRING:String = "projectorMap interpolation DONE";
		public var DONE_EVENT:Event = new Event( DONE_EVENT_STRING );
		
		public function ProjectorMap(cam_proj_map:CameraProjecterMap2)
		{
			cam_map = cam_proj_map;

		}
		public function width():int
		{
			return proj_map.length
		}
		public function height():int
		{
			if( proj_map.length <= 0 )
				return 0;
			return (proj_map[0].length)
		}
		public function getProjXY( x:int , y:int):Point
		{
			if( proj_map[x] && proj_map[x][y])
			{
				return proj_map[x][y];
			}
			else
				return new Point(-1,-1);
		}
		public function interpolate( autoCleanUp:Boolean = false, percentToKeep:Number = 1.0 ):void
		{
			
			//init varaibles
			DONE_EVENT = new Event( DONE_EVENT_STRING );
			
			//make reverse map
			rev_map =  new Reversemap( cam_map );
			rev_map.addEventListener("reverse map ready", reverseMapDone)
			rev_map.reverse();
			
			//		send made reverse map status event
			
			//interpolate
			pickPointsMedian( percentToKeep);
			//pickPointsAverage( percentToKeep);
			triangulation();
			fillIn();
			
			//	TODO	send interpolate status event
			
		}
		
		//
		//CLEAN UP FUNCTIONS	
		//
		public function cleanUp():void
		{
			cam_map.deleteNoise()
		}

		
		
		//
		// REVERSE MAP FUNCTIONS
		//

		private function reverseMapDone(e:Event):void
		{
			//send the event
		}
		
		
		//
		// INTERPOLATION FUNCTIONS , testing versions
		//
		
		
		//
		// Median
		// get the median seperatly for both x and y,
	
		public function pickPointsMedian( percentToKeep):void
		{
			
			if(!rev_map){
				return
			}
			
			proj_map = new Array( rev_map.width())
			mypoints = new Vector.<Point>
			//GET THE POINTS 
			//  TO BE TRIANGULATED WITH
			//	
			var medX:Number = 0;
			var medY:Number = 0;
			for( var x:int = 0 ; x < rev_map.width(); x++)
			{
				proj_map[x] = new Array( rev_map.height() ) 
				for( var y:int=0; y< rev_map.height(); y++)
				{
					var l:Number = rev_map.rev_map[x][y].length ;
					if( l > 0)
					{ 
						rev_map.rev_map[x][y].sort( sortByX);

						if( l % 2 == 0 )//even
						{
							medX = (rev_map.rev_map[x][y][Math.floor( (l-1)/2)].x + rev_map.rev_map[x][y][ Math.ceil( (l-1) /2 ) ].x )/2 ;
						}
						else//odd
						{
							medX = rev_map.rev_map[x][y][ (l-1)/2].x
						}
						
						// now y
						rev_map.rev_map[x][y].sort( sortByY);
						
						if( l % 2 == 0 )//even
						{
							medY = (rev_map.rev_map[x][y][Math.floor( (l-1)/2)].y + rev_map.rev_map[x][y][ Math.ceil( (l-1) /2 ) ].y )/2 ;
						}
						else//odd
						{
							medY = rev_map.rev_map[x][y][ (l-1)/2].y
						}
						
						//push it onto the stack
						var medPoint = new Point( medX, medY);
						if( medPoint.x >= 0   &&   medPoint.y >= 0 )
						{
							var rnd:Number = Math.random() ;
							if( rnd < percentToKeep)
							{
								mypoints.push( new Point(x,y) )						
								proj_map[x][y] = medPoint.clone()
							}
						}
						
					}
				}
			}
			
		}
		private function sortByY( a:Point, b:Point):Number
		{	
			if( a.y == b.y)
			{
				if( a.x == b.x)
					return 0;
				else if( a.x < b.x)
					return -1 ;
				else //if( a.x > b.x)
					return 1;
			}
			else if( a.y < b.y)
				return -1; // a appears before b in sequence
			else //  if ( a.y > b.y)
				return 1; // a is placed after b
	
		}
		private function sortByX( a:Point, b:Point):Number
		{	
			if( a.x == b.x)
			{
				if( a.y == b.y)
					return 0;
				else if( a.y < b.y)
					return -1 ;
				else //if( a.y > b.y)
					return 1;
			}
			else if( a.x < b.x)
				return -1; // a appears before b in sequence
			else //  if ( a.x > b.x)
				return 1; // a is placed after b
			
		}
		//
		// .. Median
		//
			
		//
		// pick point using average.
		//		almost like a center of mass. 
		//
		
		public function pickPointsAverage( percentToKeep):void
		{
			//
			//  this uses an average center rather than a meen. It works much better
			//
			
			if(!rev_map){
				return
			}
			
			proj_map = new Array( rev_map.width())
			mypoints = new Vector.<Point>
			//GET THE POINTS 
			//  TO BE TRIANGULATED WITH
			//	
			for( var x:int = 0 ; x < rev_map.width(); x++)
			{
				proj_map[x] = new Array( rev_map.height() ) 
				for( var y:int=0; y< rev_map.height(); y++)
				{
					if( rev_map.rev_map[x][y].length)
					{ 
						var center:Point = new Point(0,0 )
						for( var i2:int=0; i2 < rev_map.rev_map[x][y].length; i2++)
						{
							center.x += rev_map.rev_map[x][y][i2].x ;
							center.y += rev_map.rev_map[x][y][i2].y	;
							//find center
						}
						center.x = center.x / rev_map.rev_map[x][y].length ;
						center.y = center.y / rev_map.rev_map[x][y].length ;

						
						if( center.x >= 0   &&   center.y >= 0 )
						{
							var rnd:Number = Math.random() ;
							if( rnd < percentToKeep)
							{
								mypoints.push( new Point(x,y) )						
								proj_map[x][y] = center.clone()
							}
						}
						
					}
				}
			}
		}
		//
		// .. average, center of mass. 
		
		
		public function triangulation():void
		{
			//FIND THE TRIANGLES
			triad = new Voronoi( mypoints, null , new Rectangle(0,0, rev_map.width(), rev_map.height() ) )
		}
		
		//
		// INTERPOLATE THE IN BETWEEN SPOTS 
		//     USING BARYCENTRIC COORDINATES
		//
		//
		public function fillIn():void
		{
			
			//FIND THE POINT IN BETWEEN THE POINTS
			for each( var tr:Triangle in triad._triangles)
			{
				
				var p1:Point = tr.sites[0].coord
				var p2:Point = tr.sites[1].coord
				var p3:Point = tr.sites[2].coord	
				
				
				//get bounding box
				var minX:int = p1.x 
				var minY:int = p1.y
				var maxX:int = p1.x
				var maxY:int = p1.y
				
				if( p2.x > maxX)      maxX = p2.x;
				if( p2.y > maxY)      maxY = p2.y;
				if( p2.x < minX)      minX = p2.x;
				if( p2.y < minY)      minY = p2.y;
				
				if( p3.x > maxX)      maxX = p3.x;
				if( p3.y > maxY)      maxY = p3.y;
				if( p3.x < minX)      minX = p3.x;
				if( p3.y < minY)      minY = p3.y;
				
				var r:Rectangle = new Rectangle( minX  , minY , maxX - minX , maxY - minY) 
				
				var Area:Number = ( p1.y - p3.y) * (p2.x-p3.x) + (p2.y - p3.y) * ( p3.x - p1.x)
				
				//walk through all pixels in the bounding box
				for( var x:int = r.x; x < r.x + r.width ; x++)
				{
					for( var y:int = r.y; y < r.y + r.height; y++)
					{
						//	
						//get barycentric coodinates
						// from 3d math primer by dunn and parberry. page:262
						
						
						var Area1:Number = ( y - p3.y)*(p2.x - p3.x) + ( p2.y - p3.y)*(p3.x - x)
						var Area2:Number = ( y - p1.y)*(p3.x - p1.x) + ( p3.y - p1.y)*(p1.x - x)	
						var Area3:Number = ( y - p2.y)*(p1.x - p2.x) + ( p1.y - p2.y)*(p2.x - x)
						
						var gary1:Number = Area1 / Area 
						var gary2:Number = Area2 / Area
						var gary3:Number = Area3 / Area
						
						//if inside triangle
						if( gary1 <= 1 && gary2 <= 1 && gary3 <= 1  && gary1 >= 0 && gary2 >= 0 && gary3 >= 0)
						{
							var newP:Point = new Point()
							newP.x = proj_map[p1.x][p1.y].x * gary1 + proj_map[p2.x][p2.y].x * gary2 + proj_map[p3.x][p3.y].x * gary3
							newP.y = proj_map[p1.x][p1.y].y * gary1 + proj_map[p2.x][p2.y].y * gary2 + proj_map[p3.x][p3.y].y * gary3
							
							
							newP.x = Math.round( newP.x)
							newP.y = Math.round( newP.y)
							
							proj_map[x][y] = newP.clone()
						}
					}
				}	
			}	
			
			this.dispatchEvent( DONE_EVENT );
		}//fill in
		
		
		
		public function getCameraTriangles():Vector.<Array>
		{ 
			var result:Vector.<Array> = new Vector.<Array>;
			
			if( proj_map && triad && triad._triangles.length > 0)
			{
				
				//var triad = proj_map.triad ;
				
				//var s:Shape = new Shape();
				//s.graphics.lineStyle(1, 0xff0000 );
				for each( var tr:Triangle in triad._triangles)
				{
					var p1:Point = tr.sites[0].coord ;
					var p2:Point = tr.sites[1].coord ;
					var p3:Point = tr.sites[2].coord ;	
					
					
					var q1:Point = proj_map[ p1.x ] [ p1.y];
					var q2:Point = proj_map[ p2.x ] [ p2.y];
					var q3:Point = proj_map[ p3.x ] [ p3.y];
					
					
					
					result.push( [q1, q2, q3] );
				}
			}
			return result;
		}
		
	
		//
		// IMAGE DISPLAY FUNCTIONS
		//		some of these are for debugging, but others may be functional
		//
		//
		public function displayRevMap():BitmapData
		{
			return rev_map.display_rev_map();	
		}
		public function display_graymap():BitmapData
		{	
			return cam_map.makeGrayArrayImage() ;
		}

		
		//
		//  DRAW TRIANGLES
		//
		public function drawTriangles():BitmapData
		{
			var bm:BitmapData = rev_map.display_rev_map() ;
			
			//var triad = proj_map.triad ;		
			var s:Shape = new Shape();
			s.graphics.lineStyle(1, 0xffffff );
			for each( var tr:Triangle in triad._triangles)
			{
				var p1:Point = tr.sites[0].coord ;
				var p2:Point = tr.sites[1].coord ;
				var p3:Point = tr.sites[2].coord ;	
				
				s.graphics.moveTo( p1.x, p1.y ) ;
				s.graphics.lineTo( p2.x, p2.y ) ;
				s.graphics.lineTo( p3.x, p3.y ) ;
				s.graphics.lineTo( p1.x, p1.y ) ;
			}
			
			bm.draw( s) ;
			return bm
		}
		
	}//class
}//package