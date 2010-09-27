package ImageStuff
{
	public class Pixel
	{
		public var r:uint =0
		public var g:uint =0
		public var b:uint =0
		public var a:uint = 0xff
		public function Pixel(pix:uint)
		{
			//a = pix >> 24 & 0xff
			r = pix >> 16 & 0xff //red
			g = pix >> 8 & 0xff//green
			b = pix & 0xff//blue
		}
		public function to_uint():uint
		{
			var pix:uint = r << 16 | g << 8 | b 
			return pix
		}
		public function multiply(x:Number):Pixel
		{
			r = uint(Math.round(r * x))
			g = uint( Math.round(g* x))
			b = uint( Math.round(b* x))
				
			return this
		}
		public function add(  x:Pixel):Pixel
		{
			r = r + x.r
			g = g + x.g
			b = b + x.b
				
			return this	
		}

	}
}