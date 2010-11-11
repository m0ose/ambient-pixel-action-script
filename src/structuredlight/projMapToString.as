package structuredlight
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.net.FileFilter;
	import flash.net.FileReference;

	public class projMapToString
	{
		public var proj_map:ProjectorMap
		//private var fr:FileReference
		public function projMapToString(pm:ProjectorMap)
		{
			proj_map = pm;
		}

		/*
		This makes a vertex mesh for use with the PbMesh plugin for Quartz composer by Paul Bourke and Christopher Wright
		For detailed information on the quartz patch goto   http://local.wasp.uwa.edu.au/~pbourke/miscellaneous/domemirror/warppatch/
		, and information on the mesh format goto   http://local.wasp.uwa.edu.au/~pbourke/dataformats/meshwarp/	
		
		This function makes a string that represents a rectangular mesh(open GL style regular mesh)
		first line: is the type of mesh .  1=planar, 2=fisheye, 3=cylindrical panorama, 4=spherical panorama( for this, put it at two)
		second line : Dimensions of mesh. I use 64 x 48 usually( 64 48)
		next lines : Represent a node index in the mesh. Go from left to right and up to down. EG. for y in 48 { for x in 64 { ...} }
		For Each Line:
		vertex coordinates (x,y), texture coordinates (u,v) and an intensity mapping (i).
		if there is no coord for that point put u = -1001 v = -1001 and i = -1 
		
		
		here is quick example of what it looks like:
		2 
		65 49
		0.96875 1 1002 1002 -1
		1 1 1002 1002 -1
		-1 0.9583333333333334 1002 1002 -1
		-0.96875 0.9583333333333334 0.7359375 0.55125 1
		-0.9375 0.9583333333333334 0.72890625 0.5525 1
		-0.90625 0.9583333333333334 0.72265625 0.55375 1
		-0.875 0.9583333333333334 0.71640625 0.55375 1
		-0.84375 0.9583333333333334 0.7109375 0.55625 1
		... and so and and so forth ...
		*/ 
		public function MakeUVMap4Quartz( xdivisions:int = 64, ydivisions:int = 48):String
		{
			var result:String = "2 \n";
			// todo figure out resolution automatically
			//var xdivisions:int = 64 ; 
			//var ydivisions:int = 48 ;
			
			result += int(xdivisions + 1) + " " + int(ydivisions + 1) + "\n";
			
			for( var yn:Number = 0 ; yn <= ydivisions; yn++)
			{
				for( var xn:Number = 0; xn <= xdivisions ; xn ++  ) 
				{
					var x:Number = 2 * ( xn / xdivisions ) - 1 ;
					var y:Number = 2 * ( yn / ydivisions ) - 1;
					var xm:int = Math.floor( proj_map.width()  * (x+1)/2 );
					var ym:int = Math.floor( proj_map.height() * (y+1)/2 );
					var u:Number = proj_map.getProjXY( xm, ym ).x;
					var v:Number = proj_map.getProjXY( xm, ym ).y;
					var i:Number = 1 ; 
					if( u >=0 && v >=0 )
					{
						u =  u / proj_map.cam_map._screen_width ;
						v =  v / proj_map.cam_map._screen_height ;
					}
					else
					{
						u = v = -1000;
						i = -1 ;
					}
					//the output for the quartz PBMesh plugin is inverted. 
					//result += x + " " + y + " " + u + " " + v + " " + i + "\n";
					// the repaired version is below
					//result += x + " " + -1 * y + " " + ( u).toString() + " " + (1-v).toString() + " " + i + "\n";
					result += x + " " + -1 * y + " " + ( u).toString() + " " + (1-v).toString() + " " + i + "\n";

					
					
				}
			}
			return result;
		}
		
	
		

	}
}