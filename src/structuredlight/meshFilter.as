package structuredlight
{
	import com.nodename.Delaunay.Voronoi;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/*
		this package preforms mesh alterations to a projector map.
	
	*/
	
	public class meshFilter
	{
		public var proj_map:ProjectorMap ;
	
		public function meshFilter( proj_map_:ProjectorMap )
		{
			proj_map = proj_map_ ;
		}
				
		
		////GET RID OF BAD COORDINATES BY SIDE LENGTH
		// 		 This function throws away point with lines connecting longer than 2 standard deviations from the average.
		//		changed: it now removes a coord if 3 connected lines are longer than 1 standard deviation from the average	
		//  note: I think remove by angle works better.
		public function goodCamTriangles():Vector.<Point>
		{
			//remove 2 sigmas standard deviation  from the median distance from points in the cam map.
			// note: this may not work with all maps.
			
			
			var avgCamMapDist:Number = 0;
			var n:Number = 0;
			
			//GET AVERAGE
			
			for each( var p:Point in proj_map.mypoints)
			{
				var neighbors:Vector.<Point> = proj_map.triad.neighborSitesForSite(p);
				var cmP:Point = proj_map.proj_map[ p.x][p.y];
				for each( var nb:Point in neighbors)
				{
					var cmNB:Point = proj_map.proj_map[ nb.x ][ nb.y ];
					var cmDist:Number = Math.sqrt(   Math.pow( cmNB.x - cmP.x , 2)   +   Math.pow( cmNB.y - cmP.y , 2)       );
					n++;
					avgCamMapDist += cmDist;
					
				}
			}
			
			
			avgCamMapDist /= n;
			
			
			//
			//
			// STANDARD DEVIATION
			//get sigma
			var sd:Number = 0;
			for each( p in proj_map.mypoints)
			{
				neighbors= proj_map.triad.neighborSitesForSite(p);
				cmP = proj_map.proj_map[ p.x][p.y];
				for each( nb in neighbors)
				{
					cmNB = proj_map.proj_map[ nb.x ][ nb.y ];
					cmDist = Math.sqrt(   Math.pow( cmNB.x - cmP.x , 2)   +   Math.pow( cmNB.y - cmP.y , 2)       );
					sd += Math.pow(cmDist - avgCamMapDist, 2)/n; 
				}
			}
			sd = Math.sqrt( sd );
			
			//	
			//	ONLY KEEP THE GOOD COORDS
			//
			var goodCoords:Vector.<Point> = new Vector.<Point>;
			for each( p in proj_map.mypoints)
			{
				neighbors= proj_map.triad.neighborSitesForSite(p);
				cmP = proj_map.proj_map[ p.x][p.y];
				
				var badCount:int = 0 ;
				for each( nb in neighbors)
				{
					cmNB = proj_map.proj_map[ nb.x ][ nb.y ];
					cmDist = Math.sqrt(   Math.pow( cmNB.x - cmP.x , 2)   +   Math.pow( cmNB.y - cmP.y , 2)       );
					// if more than three distances are 
					// i cmDist > meen + 2* standradDeviation /
					if( cmDist > avgCamMapDist + sd  )
						badCount += 1;
				}
				if( badCount < 3)
				{
					goodCoords.push( p)
				}
				
				
			}
			
			
			return goodCoords;
		}
		//
		//  inputs:
		//
		//     lowAngle:Number = Lower Limit Angle.  is an angle in radians. points with angles below this are thrown away
		//
		public function goodTrianglesbyAngle( lowAngle:Number = 0.12 ):Vector.<Point>
		{
			var good:Vector.<Point> = new Vector.<Point>;
			
			for each( var p:Point in proj_map.mypoints)
			{
				var neighbors:Vector.<Point> = proj_map.triad.neighborSitesForSite(p);
				var cmP:Point = proj_map.proj_map[ p.x][p.y];
				
				var angles:Array = [];
				
				
				for each( var nb:Point in neighbors)
				{
					var cmNB:Point = proj_map.proj_map[ nb.x ][ nb.y ];
					var a:Number = Math.atan2( cmP.y - cmNB.y , cmNB.x - cmP.x);
					a = ( a + 2 * Math.PI ) % (2*Math.PI);
					angles.push( a);
				}
				
				
				if( angles.length > 2)
				{
					angles.sort( Array.NUMERIC );
					
					var anglesNeighbor:Array = [];
					
					for( var na:int = 1 ; na < angles.length; na++)
					{
						anglesNeighbor.push( angles[na] - angles[na -1] );
					}
					anglesNeighbor.push( (angles[0] + 2*Math.PI ) - angles[ angles.length - 1] );
					
					var biggestAngle:Number = 0;
					var smallestAngle:Number = 2 * Math.PI;
					for each( var a3:Number in anglesNeighbor)
					{
						if( a3 > biggestAngle)
							biggestAngle = a3;
						if( a3 < smallestAngle )
							smallestAngle = a3;
					}
					if( smallestAngle > lowAngle  )//&& biggestAngle < (7/8)*Math.PI )
					{
						good.push( p);
					}
				}	
				else
				{
					good.push( p);	
				}
			}
		
			return good; 
		}
		public function removeBadBySideLength():void
		{
			if( proj_map.proj_map)
			{
				var good:Vector.<Point> = goodCamTriangles();
				proj_map.triad = new Voronoi( good, null , new Rectangle(0,0, proj_map.rev_map.width(), proj_map.rev_map.height() ) )			;
				proj_map.mypoints = good;
			}
				//proj_map.interpolate( _denoise.selected , _percentPoints.value );
		}
		public function removeBadByAngle(lowAngle:Number = 0.12):void
		{
			if( proj_map.proj_map)
			{
				var good:Vector.<Point> = goodTrianglesbyAngle( lowAngle);
				proj_map.triad = new Voronoi( good, null , new Rectangle(0,0, proj_map.rev_map.width(), proj_map.rev_map.height() ) )	;
				proj_map.mypoints = good;
			}
		}
		
		

		
		

	}
}