/*

//
//
//  this package is used to hold a map.
//		It makes the map using the makeMap function, which takes a median map and two arrays of gray coded lines 
//		 It is used by sandbox3
//		
//		variables:
//			map: 2d array of Points
//		functions:
//			makeMap:		
			makGrayArrayImage:BitmapData = returns an image of the map 	
//			GaussianBlur() : CameraProjecterMap: returns a blurred map. Note: does not change the original
			clone() : void:  independent copy
			contour() : BitmapData: makes a contour map 
			edges(threshhold = 8) : bitmapdta: attempts to find the edges of objects.			

		usage: 
			used by Sandbox.
			... more to come later
*/

package structuredlight
{
	import ImageStuff.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.osmf.layout.AbsoluteLayoutFacet;

	
	public class CameraProjecterMap2
	{
		public var map:Array

		private var grayImage:BitmapData
		private var edgeImage:BitmapData 
		

		public var _threshold:Number = 94 ;

	
		public var _cam_width:int = 640;
		public var _cam_height:int = 480;
		
		public var _gray_width:int = 640;
		public var _gray_height:int = 480;
		
		public var _screen_width:int = 640;
		public var _screen_height:int = 480;
		
		public function dumpParameters():String
		{
			var s1:String = new String();
			s1 = " _threshold : " + _threshold + " \n";
			s1 += "  _cam_width: " + _cam_width + " \n";
			s1 += "  _cam_height: " + _cam_height + " \n";
			s1 += "  _gray_width: " +  _gray_width+ " \n";
			s1 += "  _gray_height: " + _gray_height + " \n";
			s1 += "  _screen_width: " + _screen_width + " \n";
			s1 += "  _screen_height: " + _screen_height + " \n";
			return s1;
			
		}
		
		public function CameraProjecterMap():void
		{			
		}
		
		public function width():int
		{
			if (map)
				return map.length
			else return -1 
		}
		public function height():int
		{
			if(map)
				return map[0].length
			else return -1 

		}
		public function getMapXY(x:int, y:int):Point
		{
			if(map && x < width() && y< height() && map){
				if( map[x][y] ){
					if( map[x][y].x >= 0 && map[x][y].y >= 0)
					{
						var p:Point = map[x][y];

						return p;
					}
				}
			}
			return new Point(-1,-1) 
		}	
		public function getScaledMapXY(x:int, y:int):Point
		{
			var scale_X:int = _screen_width / _gray_width ;
			var scale_Y:int = _screen_height / _gray_height ;
			if(map && x < width() && y< height() && map){
				if( map[x][y] ){
					if( map[x][y].x >= 0 && map[x][y].y >= 0)
					{
						var p:Point = map[x][y];
						var pscaled:Point = new Point( Math.round(p.x * scale_X) , Math.round(p.y * scale_Y) );
						return pscaled;
					}
				}
			}
			return new Point(-1,-1) 
		}	
		
		public function makeMap( median:BitmapData, vlines:Array, hlines:Array, screen_width:int  , screen_height:int ):void
		{
			_cam_width = median.width ;
			_cam_height = median.height;
			
			_screen_width = screen_width; 
			_screen_height = screen_height


			map = getGrayArray( median,vlines,hlines)	
		}
		private function getGrayArray( mask:BitmapData, vlines:Array, hlines:Array):Array
		{
			var vl_array:Array = mask4GrayArray( mask , vlines)
			var hl_array:Array = mask4GrayArray( mask, hlines)
			var res:Array = new Array( vl_array.length)//result
			
			var gC:GrayCode = new GrayCode()
			
			for( var n:int = 0 ; n < vl_array.length ; n++)
			{
				res[n] = new Array( vl_array[n].length)
			}
			for ( var x:int=0 ; x < vl_array.length; x++)
			{
				for( var y:int = 0; y < vl_array[x].length; y++)
				{
					var p:Point = new Point(gC.gray2int(vl_array[x][y]), gC.gray2int(hl_array[x][y]) );
					if( p.x <= _gray_width && p.y <= _gray_height)// THIS ACTUALLY REMOVES A LOT OF NOISE
					{
						res[x][y] = p;
					}
					else
					{
						res[x][y] = new Point( -1, -1);
					}
				
				}
			}
			return res
		}
		private function mask4GrayArray( mask:BitmapData, pics:Array):Array
		{
			//this takes an array of black and white bitmapdatas
			//  it returns an array of strings
			//var imageS:ImageStuff = new ImageStuff()
			
			var result:Array = new Array( mask.width)
			for( var xr:int; xr < mask.width; xr++)
				{					
					result[xr] = new Array(mask.height)
					for( var yr:int = 0; yr < mask.height; yr++)
					{
						result[xr][yr] = ""
					}	
				}	
			
			var tmpnum:String = ""
			for( var x:int = 0; x < mask.width; x++)
			{					
				for( var y:int = 0; y < mask.height; y++)
				{
					tmpnum=""
					for( var n:int = 0; n < pics.length; n++)
					{
						var pixelM:uint = mask.getPixel( x,y)
						var pixelPic:uint = pics[n].getPixel( x, y)
						
						if(AbiggerthanB2( pixelPic , pixelM , _threshold) )
						{
							 	tmpnum = "0" +  tmpnum ;	
						}	
						else
						{
							tmpnum = "1" + tmpnum	
						}
						
						result[x][y] = new String(tmpnum)

				
					}//y	
				}//x
				
			}//n	
			
			return result
		}
		public function AbiggerthanB3( a:uint , b:uint , thresh:Number):Boolean // or instead of and//sucks unless there is rainbowing
		{
			//this takes two pixels as input
			var threshold:Number = thresh;
			
			var ar:uint = a >> 16 & 0xff //red
			var ag:uint = a >> 8 & 0xff//green
			var ab:uint = a & 0xff//blue
			
			var br:uint = b >> 16 & 0xff
			var bg:uint = b >> 8 & 0xff
			var bb:uint = b & 0xff
			
			if(ar > br + threshold || ag > bg + threshold || ab > bb + threshold)
				return true;
			else
				return false;	
		}
		public function AbiggerthanB2( a:uint , b:uint , thresh:Number):Boolean //added threshold
		{
			//this takes two pixels as input
			var threshold:Number = thresh;
			
			var ar:uint = a >> 16 & 0xff //red
			var ag:uint = a >> 8 & 0xff//green
			var ab:uint = a & 0xff//blue
			
			var br:uint = b >> 16 & 0xff
			var bg:uint = b >> 8 & 0xff
			var bb:uint = b & 0xff
			
			if(ar > br + threshold && ag > bg + threshold && ab > bb + threshold)
				return true;
			else
				return false;	
		}
		public function AbiggerthanB( a:uint , b:uint):Boolean
		{
			//this takes two pixels as input
			
			var ar:uint = a >> 16 & 0xff //red
			var ag:uint = a >> 8 & 0xff//green
			var ab:uint = a & 0xff//blue
			
			var br:uint = b >> 16 & 0xff
			var bg:uint = b >> 8 & 0xff
			var bb:uint = b & 0xff
			
			if(ar > br && ag > bg && ab > bb)
				return true;
			else
				return false;	
		}
		
		

		
		
		//
		//
		//this does a gaussian blur filter on the 2d array of points
		//bug: i think this increases the total value  by a bit.
		//	it probably has to do with the way it calculates standard deviation
		public function gaussianBlur( r:int = 2):CameraProjecterMap2
		{
			//gaussian blur
			//		this does not effect the map. It returns a new changed one instead.
			//		this is seperated into a horizontal and vertical filter
			//		added together they make a 2 dimensional filter
			r=2//TODO need to put a variable radius on this. 
			var convolution:Array = new Array(5)
			convolution = [5.0,12.0,15.0,12.0,5.0]	
			var sum_conv:Number = 49.0
			
			//normalise
			for( var i:int=0; i < convolution.length; i++)
			{
				convolution[i] = convolution[i] / sum_conv
			}
			
			//vertical pass
			var blurredmap:Array = copyArray( map)
			var averagedX:Number = 0.0
			var averagedY:Number = 0.0
		
			//vertical filter pass
			for( var x:int = 0; x < width(); x++)
			{
				for( var y:int = r ; y < height() - r; y++)
				{
					averagedX = 0.0
					averagedY = 0.0
					for( var i:int = 0 ; i <= 2*r ;i++)
					{
						averagedX +=  map[x][y - r + i ].x * convolution[i]
						averagedY +=  map[x][y - r + i ].y * convolution[i]
					}
			
					blurredmap[x][y]=new Point( Math.round( averagedX) , Math.round(averagedY) )
				}
			}
			//horizontal filter pass
			//	same a vertical but rotated 90 degrees
			for( var x:int = r; x < width() - r; x++)
			{
				for( var y:int = 0; y < height() ; y++)
				{
					averagedX = 0.0
					averagedY = 0.0
					for( var i:int = 0 ; i <= 2*r ;i++)
					{
						averagedX +=  map[x - r + i ][y].x * convolution[i]
						averagedY +=  map[x - r + i ][y].y * convolution[i]
					}
					blurredmap[x][y]=new Point( Math.round( averagedX) , Math.round(averagedY) )
				}
			}

			//return a value
			var result:CameraProjecterMap2 = new CameraProjecterMap2()
			result.map = blurredmap
			return result
		}
		
	

		public function makeGrayArrayImage( ):BitmapData
		{
			//if(grayImage)
				//return grayImage
			
			var scale:Number =  128 / width(); //scale so the the max distance is 128. It sucks but it has to be done.
			if( height() > width())
				scale = 128 / height()
			
			//var scale:int = 1;
			
			var result:BitmapData = new BitmapData( this.width(), this.height(), false, 0x808080 )
			for( var xr:int; xr < result.width; xr++)
				{					
					for( var yr:int = 0; yr < result.height ; yr++)
					{
						var p:Point = getMapXY( xr, yr);
						if( p.x >= 0 && p.y >=0)
						{
							var pixval:uint = uint( (((p.x - xr) * scale + 128) << 16)  |   (((p.y - yr) * scale + 128) << 8))
							result.setPixel(xr, yr,  pixval  )
						}
					
					}
				}
			grayImage = result	
			return result
		}

		
		//make an independent copy of an array
		private function copyArray(a:Array):Array
		{
			
			var result:Array = new Array( a.length)
			for(var ix:int = 0 ; ix < a.length; ix++)
			{
				result[ix] = new Array( a[ix].length) 
				for(var  iy:int = 0; iy < a[0].length; iy++)
				{
					result[ix][iy] = a[ix][iy].clone()
				}
			}
			return result
		}
		
		public function clone():CameraProjecterMap2
		{
			var res:CameraProjecterMap2 = new CameraProjecterMap2();
			res.map = this.copyArray( this.map)
				
			
			res._threshold = this._threshold ;
			
			
			res._cam_width = this._cam_width;
			res._cam_height = this._cam_height;
			
			res._gray_width = this._gray_width;
			res._gray_height = this._gray_height;
			
			res._screen_width = this._screen_width;
			res._screen_height = this._screen_height;	
				
				
			//res.max_height = int( this.max_height)
			//res.max_width = int ( this.max_width)
			return res
		}
		
		public function contours( mesh:int = 20):BitmapData
		{
			var bmd:BitmapData = new BitmapData(width(), height(), false, 0x000000)
						
			
			for( var x:int=0; x < width(); x++)
			{
				var hood:Array = [new Point(0,0), new Point(0,0), new Point(0,0)]

				for( var y:int=0; y < height() -2 ;y++)
				{
					hood.shift()
					hood.push( map[x][y + 1])
					
					if( hood[1].y % mesh == 0){
						bmd.setPixel(x, y, 0xffffff)
					}
					else if( Math.floor(hood[0].y / mesh) < Math.floor( hood[2].y / mesh) ) {
						bmd.setPixel(x, y, 0x0000ff)
					}
					else if( Math.floor(hood[0].y / mesh) > Math.floor( hood[2].y / mesh) ) {
						bmd.setPixel(x, y, 0xff0000)
					}
					
					if( hood[1].x % mesh == 0){
						bmd.setPixel( x,y, 0x00ff00)
					}
				}	
			} 
			return bmd
		}//contour

		
		public function denoise2( threshhold:Number = 2):BitmapData
		{
			var _radius:int=2
			var result1:BitmapData =  new BitmapData( width(), height(), false, 0xffffff)
			
			//var tmp_map:Array = copyArray( map)
				
				
			var average:Point= new Point()	
			var n:int=0
			for ( var x:int= _radius; x< width() - _radius; x++)
			{
				for( var y:int= _radius; y< height() - _radius; y++)
				{
					for( var x2:int= -(_radius); x2 <= _radius; x2++)
					{
						for( var y2:int= -(_radius); y2<= _radius; y2++)
						{
							average.x += getMapXY( x + x2, y + y2).x
							average.y += getMapXY( x + x2, y + y2).y	
							n++
						}
					}
					average.x = average.x / n
					average.y = average.y / n
					if( Math.abs(getMapXY(x,y).x - average.x) > threshhold)
					{
						result1.setPixel( x,y, 0xff0000)	
					}
					if( Math.abs(getMapXY(x,y).y - average.y) > threshhold)
					{
						result1.setPixel( x,y, 0x00ff00)	
					}
					average.x = 0.0
					average.y = 0.0
					n=0
				}
			}
				
			return result1
		}

		public function deleteNoise(threshhold:Number = 12):void
		{
			grayImage =  null //refresh the image
				
			var edges:BitmapData = denoise2( threshhold)
			for ( var x:int=0 ; x < edges.width; x++)
			{
				for( var y:int=0; y< edges.height; y++)
				{
					if( edges.getPixel( x,y) != 0xffffff)
						map[x][y] = new Point( -1,-1)
				}
			}
		}


		//
		// file stuff
		//
		//

		public function export():void//TODO: put this in parseMap
		{
			var mpfo:MapFileOpener = new MapFileOpener() ;
			mpfo.export( this );
	
		}
		
	
	}//class
}//package