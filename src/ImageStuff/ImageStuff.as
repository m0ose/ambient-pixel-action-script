package ImageStuff
{
	import flash.display.BitmapData;
	import flash.geom.*;
	import flash.utils.ByteArray;
	
	public class ImageStuff
	{
		public function ImageStuff()
		{
			
		}
		public function mergeArray( a_in:Array , rect:Rectangle = null):BitmapData
		{	
			//This takes an Array of bitmapdata's as input
			//and returns one bitmapdata
			
			//if (a_in.length < 1)
				//return null
			var result:BitmapData 
			result = a_in[0].clone()
			
			if(rect == null)
				rect = a_in[0].rect
			for(var i:int=1; i< a_in.length ; i++)
			{
				result.merge( a_in[i] , rect, new Point(0,0), 256/(i+1), 256/(i+1), 256/(i+1), 256)
			}
			
			return result
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
		public function AbiggerB_2(a:uint, b:uint):Boolean
		{
			var pa:Pixel = new Pixel(a)
			var pb:Pixel = new Pixel(b)
			var score:int = 0
			if( pa.r > pb.r)	score += 1
			if( pa.g > pb.g)    score += 1
			if( pa.b > pb.b)	score += 1
			return( score > 1) 
		}
		public function AbrighterB( a:uint, b:uint):Boolean
		{
			var pa:Pixel = new Pixel( a)
			var pb:Pixel = new Pixel( b)
			var brightnessA:uint = pa.r + pa.g + pa.b
			var brightnessB:uint = pb.r + pb.g + pb.b
			return ( brightnessA > brightnessB) 
		}
		
		
		
	//find the active rectangle	

		public function activeRect( old:BitmapData, cur:BitmapData):Rectangle
			{
				var old2:BitmapData = old.clone()
				old2.draw( cur, null, null, "difference")
				old2.threshold( old2, old2.rect, new Point(0,0), ">", 0xff554444, 0xffffffff)
				//old2.threshold( old2, old2.rect, new Point(0,0), "<", 0xff444444, 0x00000000)

				var recta:Rectangle = old2.getColorBoundsRect( 0xffffffff, 0xffffffff, true)
				return recta
			}
		

		

	}//class
}//package