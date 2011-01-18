package structuredlight
{
	// reverses the map
	// todo : change this to a binary tree rather than a 2d array.
	//
	// BUG:
	//  Note : there is definatly an issue with line 68 & 69. The scale should not be needed. when it is 1 it causes mis-alignment of multiple projectors. 
	// however it doesn't mess up the quartz composer with multiple projectors , wierd.
	//  it may be making an allready small dis-alignment a little bigger, but i do not know. 
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import structuredlight.CameraProjecterMap2;
	
	public class Reversemap extends EventDispatcher
	{
		public var cam_map:CameraProjecterMap2
		public var rev_map:Array
		
		public var event_ready:Event = new Event("reverse map ready", true)
		
		public function Reversemap(cam_projector_map:CameraProjecterMap2 )
		{
			if( cam_projector_map)
			{
				cam_map = cam_projector_map;

				//reverse
				reverse( );
			}
		}
		
		
		
		public function reverse(new_width:int = NaN, new_height:int = NaN):void//bitmapdata
		{
			if(!cam_map){
				return 
			}
			
			//
			// FIND NEW DIMENSIONS
			if( !new_width || ! new_height )
			{
				new_width = cam_map._screen_width;
				new_height = cam_map._screen_height;
			}
			

			//
			//initialize arrays
			rev_map = new Array(new_width)
			for( var x:int = 0; x< new_width;x++)
			{
				rev_map[x] = new Array(new_height)
				for(var y:int = 0; y < new_height; y++)
				{
					rev_map[x][y]= new Array()
				}
			}

			//
			//do a reverse lookup for every point on the map
			//
			//var maximum:int=0;
			
			var screenScaleX:Number = 1.0//cam_map._screen_width / cam_map._cam_width;/// cam_map.width();
			var screenScaleY:Number = 1.0//cam_map._screen_height / cam_map._cam_height; /// cam_map.height() ;
				
				
			for(var  x:int=0; x < cam_map.width(); x++)
			{
				for(var  y:int =0 ; y < cam_map.height();y++)
				{
					var p:Point =  cam_map.getScaledShiftedMapXY( x, y);
							
					if( p.x >= 0 && p.y >= 0 && p.x < rev_map.length && p.y < rev_map[0].length)
					{
						rev_map[p.x][p.y].push( new Point(x * screenScaleX , y * screenScaleY) );
					}
				}
			}
			//
			//it's done
			//	so dispach an event saying "reverse map done"
			this.dispatchEvent( event_ready)

		}//end reverse

		public function display_rev_map():BitmapData
		{
		
			if( !rev_map){
				return null
			}
			
			var k:Number=0x004040
			var bmd:BitmapData = new BitmapData( rev_map.length, rev_map[0].length,false,0x000000)
			var total_points:int = 0
			for(var x:int=0; x < rev_map.length;x++)
			{
				for( var y:int=0 ; y < rev_map[x].length; y++)
				{
					//var p:Point = cam_map.getMapXY(x,y)
					bmd.setPixel(x, y, rev_map[x][y].length * k)
					if( rev_map[x][y].length == 1)
						total_points += 1
				}
			}
			//_dbug.text += "total points = " + total_points
			return bmd
		}
		public function width():int
		{
			if( !rev_map) 
				{ return -1}
			return rev_map.length
		}
		public function height():int
		{
			if( !rev_map[0]) 
				{ return -1}
			return rev_map[0].length
		}
		
		public function attachImage( img:BitmapData):BitmapData
		{
			var result:BitmapData = new BitmapData( width(), height(), false, 0x00ff00)
			
		//scaled image
			var scaled:BitmapData = new BitmapData( 640,480)//width()/ img.width, height()/img.height)
			var mtrx:Matrix = new Matrix( width() / img.width, 0,0, height() / img.height )
			scaled.draw( img,mtrx)
			//return scaled
				
			for( var x:int=0; x<width();x++) 
			{
				for( var y:int=0; y<height(); y++)
				{
					if( rev_map[x][y])
					{
						for( var z:int=0; z < rev_map[x][y].length;z++)
						{
							var p:Point = rev_map[x][y][z]
							var pixel:uint = scaled.getPixel( x,y)
							result.setPixel( p.x,p.y, pixel)
						}
					}
				}
			}
			return result
		}
		
		
		
		
		
	}//end class
}//end package