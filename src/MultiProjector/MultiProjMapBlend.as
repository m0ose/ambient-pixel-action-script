package MultiProjector
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.net.FileReference;
	
	import structuredlight.ProjectorMap;
	import structuredlight.Sandbox3;

	/*
	This takes allreaady interpolated projector maps and turns them into one continuous mesh
	
	*/
	public class MultiProjMapBlend
	{
		public var projMap_list:Array;
		public var _log:String;
		public var mesh:String;
		public var blendOpacs:MultiImageBlend = new MultiImageBlend();
		public var done:Boolean = false;
		public var xdivisions:int = 96;
		public var ydivisions:int = 54;

		
		public function MultiProjMapBlend( projectorMap_list:Array )
		{
			projMap_list = projectorMap_list;
			run();
		}
		
		
		public function makeChangesPermanent():void
		{
			//  make changes to all of the maps 
			//
			for each( var current_pm1:ProjectorMap in projMap_list)
			{
				current_pm1.triangulation();
				current_pm1.fillIn();
			}
			
		}
		
		public function run():void
		{
			_log += "\n run called";
			makeChangesPermanent();	
			getOpacities();
			mesh = stitchUVMeshesWithOpacity();
			done = true;
			_log += "\n done . ready to save";

			//save();
		}
		public function save():void
		{
			_log += "\n save called";
			if( done)
			{
				var fr:FileReference
				fr = new FileReference();
				fr.save( mesh, "QuartzPBMesh.data");
			}
			else
			{
				_log += "\n can't save. Not done yet";
			}
			
		}
		
		public function getOpacities():void
		{
			_log += "\n getOpacities called";

			//
			//
			// initialise opacities
			var blendImages:Array = [];
			
			
			for each( var prm:ProjectorMap in projMap_list)
			{
				//give each proj map image a different color
				var tmpbmp:Bitmap = new Bitmap( prm.drawCamTriangles( 0xff << 24 | (0xff0000 | 0x88 * projMap_list.length) , 0xff0000ff,0x00000000,1.0));
				blendImages.push( tmpbmp );
			}
			
			// run it throught the blending algorithm
			blendOpacs = new MultiImageBlend();
			blendOpacs.blendBitmaps( blendImages );
			
			_log += blendOpacs._log;
		
			//setTimeout( stitchUVMeshesWithOpacity, 50);
		}
		public function stitchUVMeshesWithOpacity():String
		{	
			_log += "\n stitchUVMeshesWithOpacity() called";

		
			var numOfProjs:int = projMap_list.length;

			//get width
			var current_pm1:ProjectorMap = projMap_list[ 0] ;
			var scrWid:int  = current_pm1.width();
			var scrHeight:int = current_pm1.height();

			_log += "\n # of projectors : " + numOfProjs +  "   individual proj map width  : " + scrWid + " \n"

				
			//
			//
			//  Make string
			//			
			var result:String = "2 \n";
			
			// todo figure out x,y divisions automatically
			//
			//  put all nodes into an array 
			//
			result += int(xdivisions + 1) + " " + int(ydivisions + 1) + "\n";
			
			//initialise the array
			var nodes:Array = new Array( ydivisions +1);
			for( var yn:Number = 0 ; yn <= ydivisions; yn++)
			{
				nodes[ yn] = new Array( xdivisions + 1);
			}
			
			// number of x divisions per projector
			var xdPerProjector:Number = xdivisions / projMap_list.length ;
			
			// find x,y,u,v,i
			// put them in 2d array called nodes
			for( yn = 0 ; yn <= ydivisions; yn++)
			{
				for( var xn:Number = 0; xn <= xdivisions ; xn ++  ) 
				{
					var x:Number = 2 * ( xn / xdivisions ) - 1 ;
					var y:Number = 2 * ( yn / ydivisions ) - 1;
					var currProjectorIndex:int = Math.floor( xn * projMap_list.length / xdivisions);
					if(currProjectorIndex >= projMap_list.length)
						currProjectorIndex = projMap_list.length - 1 ;
					var currProjector:ProjectorMap = projMap_list[ currProjectorIndex ];
					// x and y positions in screen dimensions
					var xm:int  = Math.floor( (xn/xdivisions) * scrWid ) ;
					var ym:int = Math.floor( (yn/ydivisions) * scrHeight) ;
					
					if( ! currProjector)
						_log += "  curr projector  null " + currProjectorIndex;
					var u:Number = currProjector.getProjXY(xm,ym).x;
					var v:Number = currProjector.getProjXY(xm,ym).y;
					var i:Number = -1;
					if( u >=0 && v >=0 )
					{
						i = blendOpacs.getOpacities(u,v)[ currProjectorIndex ];	
						u =  u / scrWid ;// ??? todo: should this be u = u / camera_width;???
						v =  v / scrHeight ;/// ??? This too ???
					}
					else
					{
						u = v = -1000;
						i = -1 ;
					}
					//push an object on
					nodes[yn][xn] = { x:x , y:y , u:u , v:v ,i:Number(i)}; 
				}
			}
			
			//
			// convert 2d array nodes to a properly formatted string
			//
			for( yn = 0 ; yn <= ydivisions; yn++)
			{
				for(  xn = 0; xn <= xdivisions ; xn ++  ) 
				{
					var tmpObj:Object = nodes[yn][xn];
					//
					//
					//  handle the border issues 
					//       make all borders translucent
					//       
					//    		
					var i2:Number = Number(tmpObj.i);
					
					if( xn == 0 || yn == 0)
						i2 = -1;
					else if( xn == xdivisions || yn == ydivisions)
						i2 = -1;
					else if( nodes[yn][xn-1].i < 0 )
						i2 = -1;
					else if( nodes[yn][xn+1].i < 0 )
						i2 = -1;
					else if( nodes[yn-1][xn].i < 0 )
						i2 = -1;
					else if( nodes[yn+1][xn].i < 0 )
						i2 = -1;
					
					
					//
					//  finally outputto the final string
					//
					result += tmpObj.x + " " + -1 * tmpObj.y + " " + ( tmpObj.u ).toString() + " " + (1- tmpObj.v ).toString() + " " + i2 + "\n";					
				}
			}
			return result;
		}
		
		
		public function getImage():BitmapData
		{
			return blendOpacs.getImage();
		}
	}
}