//
/*
	Remove gradients that don't fit the global gradient. 
	//bug : will remove some area around the edge of interpolated image.  


*/



package CamMapfilters
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import structuredlight.CameraProjecterMap2;

	
	public class gradientRemove
	{
		public function gradientRemove()
		{
				
		}
		public var _log:String = "";
		
		public function removeBadGradient(cam_map:CameraProjecterMap2):CameraProjecterMap2
		{
			//gradDetect();
			var mask:BitmapData = gradientDetect(cam_map);
			
			var result:CameraProjecterMap2 = cam_map.clone();
			
			for(  var x:int=0; x < cam_map.width();x++)
			{
				for( var y:int = 0 ; y < cam_map.height(); y++ )
				{
					if(mask.getPixel(x,y) != 0xffffff){
						result.map[x][y] = new Point(-1,-1);
					}
				}
			}
			return result;
		}
	
		public function gradientDetect(cam_map:CameraProjecterMap2):BitmapData
		{
			var result1:BitmapData =  new BitmapData( cam_map._screen_width, cam_map._screen_height, false, 0xffffff)
			
			var prev:Point; 
			var curr:Point ;
			var global_dx:Number = 0 ;
			var global_dy:Number = 0 ;
			var n:uint = 0;
			
			//get global gradient
			//  X
			for( var y:int= 0; y< cam_map.height() ; y = y + 5)
			{
				curr = prev = null
				for ( var x:int= 0; x< cam_map.width() ; x++)
				{
					if( cam_map.getMapXY( x,y).x >= 0)//good point
					{
						if( curr && curr.x > 0 )
							prev = curr.clone();
						curr = cam_map.getMapXY( x,y).clone();
						if( prev && curr && prev.x > 0 && curr.x > 0)
						{
							var dx:Number = curr.x - prev.x;
							if(dx > 0)
							{
								global_dx += +1;
								n++
							}
							else if( dx < 1)
							{
								global_dx += -1;
								n++;
							}
						}
					}
				}
			}
			// Y
			for ( var x:int= 0; x < cam_map.width() ; x = x + 5)
			{
				curr = prev = null;
				for( var y:int= 0; y < cam_map.height() ; y++)
				{
					if( cam_map.getMapXY( x, y).y >= 0)// -1 if bad point
					{
						if( curr && curr.x > 0)
							prev = curr.clone();
						curr = cam_map.getMapXY( x,y).clone();
						if( prev && curr && curr.x > 0 && prev.x > 0)
						{
							var dy:Number = curr.y - prev.y;
							if( dy > 0)
							{
								global_dy += 1;
								n++
							}
							else if( dy < 1)
							{
								global_dy += -1;
								n++;
							}
						}
					}
				}
			}
			//
			// Mark these points
			//
			var prev:Point
			var curr:Point
			
			for ( var x:int= 0; x < cam_map.width() ; x++)
			{
				prev = curr = null;
				for( var y:int= 0; y < cam_map.height() ; y++)
				{
					
					if( !prev || cam_map.getMapXY(prev.x , prev.y).x < 0)
					{
						prev = new Point(x,y)
						curr = null;
					}
					else
					{
						curr = new Point(x,y);
						if(  cam_map.getMapXY(curr.x , curr.y).x >= 0)
						{
							//result1.setPixel(x,y, 0xff0000);
							var dy:Number = cam_map.getMapXY(curr.x , curr.y).y - cam_map.getMapXY(prev.x , prev.y).y;
							var good:Boolean = true;
							if( dy < 0 && global_dy > 0)
								good = false;
							if( dy > 0 && global_dy < 0)
								good = false;
							if( !good)
							{
								result1.setPixel( curr.x, curr.y, 0xff0000);
								result1.setPixel( prev.x, prev.y, 0x00ff00);
								prev = curr = null;
							}
							else
							{
								prev = curr.clone()
							}
						}
					}
				}
			}
			for( var y:int= 0; y < cam_map.height() ; y++)
			{
				prev = curr = null;
				for ( var x:int= 0; x < cam_map.width() ; x++)
				{
					
					if( !prev || cam_map.getMapXY(prev.x , prev.y).x < 0)
					{
						prev = new Point(x,y)
						curr = null;
					}
					else
					{
						curr = new Point(x,y);
						if(  cam_map.getMapXY(curr.x , curr.y).x >= 0)
						{
							//result1.setPixel(x,y, 0xff0000);
							var dx:Number = cam_map.getMapXY(curr.x , curr.y).x - cam_map.getMapXY(prev.x , prev.y).x;
							var good:Boolean = true;
							if( dx < 0 && global_dx > 0)
								good = false;
							if( dx > 0 && global_dx < 0)
								good = false;
							if( !good)
							{
								result1.setPixel( curr.x, curr.y, 0x0000ff);
								result1.setPixel( prev.x, prev.y, 0x00ffff);
								prev = curr = null;
							}
							else{
								prev = curr.clone();
							}
						}
					}
				}
			}
			
			
			_log += " global dx " + global_dx + " dy " + global_dy;
			return result1;
		}
		
		
		
	
		
		
		
		
		
	}
}