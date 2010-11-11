/*
DISPLACEMENT 24. 
a 16 bit displacement filter using pixel bender. currently capable of displacements as big as 32768 .( soon to be 24, when the need arises for 8388608 pixel displacements.)
		by Cody Smith

This is basically a wrapper for a pixel bender filter. It works almost same as a normal displacement map filter, except it takes two input maps in order to store bigger values.

It either takes 2 input map images( X and Y displacents) and displaces the image according to those pixel values. 
	or it takes a ProjectorMap
	or it takes a cameraprojectorMap2

input:
	the easiest way to use this is to pass it a cameraprojectorMap2 or a projectormap that was made using sanbox3. 
		using fromCamProjMap(  ) or fromProjectorMap(   )
	it is possible to just send the images into the contructor. 

SHADER
	inputs
		src			:  source image to be dislpaced
		mapX		: X displacement map
		mapY		: Y displacement map
		scale		: scale of the displacement. displacement.x = displacement.x * scale
		offsetX		: offset in x direstion   displacement.x = displacement.x + offsetX
		offsetY  	: same as above but for Y


*/


package structuredlight
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import structuredlight.CameraProjecterMap2;
	import structuredlight.ProjectorMap;

	public class Displacement24 extends EventDispatcher
	{
		private var ldr:URLLoader;
	
		public var shader:Shader;
		public var filter:ShaderFilter;
		public var src:BitmapData;
		public var mapX:BitmapData;
		public var mapY:BitmapData;
		
		public var scale:Number = 1.0;
		public var offsetX:Number = 0.0;
		public var offsetY:Number = 0.0;
		public var zoom:Number = 1.0;
		
		public var READY_EVENT:String = "D24 READY";
		//load the pixel bender kernel
		//[Embed(source="displ24goodzoom.pbj", mimeType="application/octet-stream")]
		[Embed(source="displ24test.pbj" , mimeType="application/octet-stream")]
		protected var displacer:Class;
		
		
		public function Displacement24( map_X:BitmapData = null, map_Y:BitmapData = null, sourceImage:BitmapData = null)
		{	
			if( sourceImage){
				src = sourceImage;
			}
			else
			{
				src = quickBMP();
			}
			
			
			mapX = map_X;
			mapY = map_Y;
			
			if( !mapX)
				mapX = quickBMP();
			if( !mapY)
				mapY = quickBMP();
			
			scale = 1.0;
			offsetX = offsetY = 0.0;
			zoom = 1.0;
			//load the pixel bender shader
			shader = new Shader( new displacer() );
			
			init();
		}

		public function init():void
		{	
			shader.data.src.input = src;
			shader.data.mapX.input = mapX;
			shader.data.mapY.input = mapY;
			shader.data.scale.value = [ scale ];
			shader.data.offsetX.value = [ offsetX ];
			shader.data.offsetY.value = [ offsetY ];
			shader.data.zoom.value = [ zoom];
			
			filter = new ShaderFilter( shader);
			this.dispatchEvent( new Event( READY_EVENT) );
		}
		
		public function fromCamProjMap( cam_map:CameraProjecterMap2 ):ShaderFilter
		{
			// MAKE THE TWO DISPLACEMENT MAPS
			//     	this could be written much shorter, i am shure
			mapX = new BitmapData( cam_map.width(), cam_map.height(), false,  0xffffff)
			mapY = new BitmapData( cam_map.width(), cam_map.height(), false, 0xffffff)
			
			for( var xr:int=0; xr < cam_map.width(); xr++)
			{					
				for( var yr:int = 0; yr < cam_map.height() ; yr++)
				{
					if( cam_map.getMapXY( xr, yr).x >= 0 && cam_map.getMapXY( xr, yr).y >=0)
					{ 
						var distX:int =  cam_map.getMapXY( xr, yr).x - xr;
						var distY:int =  cam_map.getMapXY( xr, yr).y - yr ;
						
						//green x and blue x
						var gx:int = distX / 128;
						gx = gx + 128;
						var bx:int = distX % 128;
						bx = bx + 128;
						
						//gy = green Y , by = blue y; 
						var gy:int = distY / 128;
						gy = gy + 128;
						var by:int = distY % 128;
						by = by + 128;
						
						var pixvalX:uint = ( gx << 8 | bx );//green and blue
						var pixvalY:uint = ( gy << 8 | by );
						
						
						mapX.setPixel32( xr, yr,  pixvalX);
						mapY.setPixel32( xr,yr,  pixvalY);
					}
				}
			}
			
			// reload the pixelbender
			init();
			
			return filter;
		}
		
		public function fromProjectorMap( projec_map:ProjectorMap ):ShaderFilter
		{
			// MAKE THE TWO DISPLACEMENT MAPS
			//     	this could be written much shorter, i am shure
			mapX = new BitmapData( projec_map.width(), projec_map.height(), false,  0xffffff)
			mapY = new BitmapData( projec_map.width(), projec_map.height(), false, 0xffffff)
			
			if ( !projec_map.proj_map){
				trace( " displacement24 encountered null projector map.proj_map.  you may need to interpolate it first");
				//return null;
			}
			// make displacement images
			for( var x:int=0 ; x < projec_map.width(); x++)
			{
				for( var y:int = 0 ; y < projec_map.height() ; y++ )
				{
					var distX:int = projec_map.getProjXY( x, y ).x - x;
					var distY:int = projec_map.getProjXY( x, y ).y - y;
					
					
					
					var gx:int = distX / 128;
					gx = gx + 128;
					var bx:int = distX % 128;
					bx = bx + 128;
					
					var gy:int = distY / 128;
					gy = gy + 128;
					var by:int = distY % 128;
					by = by + 128;
					
					var pixvalX:uint = ( gx << 8 | bx );//green and blue
					var pixvalY:uint = ( gy << 8 | by );
					
					
					
					//var pixvalX:uint = Math.pow( 2, 23) + distX;
					//var pixvalY:uint = Math.pow( 2, 23) + distY;
					
					mapX.setPixel32( x, y,  pixvalX);
					mapY.setPixel32( x, y,  pixvalY);
					
				}
			}
			
			
			// reload the pixelbender
			init();
			
			return filter;
		}
		

		
		
		
		
		
		public function quickBMP(wid:int = 640, hei:int = 480):BitmapData
		{
			var res:BitmapData = new BitmapData( wid, hei, false, 0x00ff00)
			
			var s:Shape = new Shape()
			s.graphics.lineStyle( 12, 0xff0000)
			
			for( var x:int = 0;  x < wid ; x = x + 45)
			{
				s.graphics.moveTo( x,0);
				s.graphics.lineTo( x, res.height);
			}
			s.graphics.lineStyle( 12, 0x0000ff)
			for( var y:int=0; y < hei; y = y + 45)
			{
				s.graphics.moveTo(0, y);
				s.graphics.lineTo( res.width, y);
			}
			res.draw( s);
			return res;
		}
	}
}