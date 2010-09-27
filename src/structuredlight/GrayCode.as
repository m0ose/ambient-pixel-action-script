/*
Gray Code methods
	Cody Smith 2009. m0ose@yahoo.com
	todo: redo these
*/
package structuredlight
{
	public class GrayCode
	{
		public var value:String
		public function GrayCode( n:int = 0)
		{
				value = int2gray( n );
		}
		
		//note only works for 16 bit integers
		//anything bigger than 65535 or ( 2^16 -1) will throw an error
		public function int2gray( n:int):String
		{  //so much easier, written by Jerry Avins <jya@ieee.org>
		if( n >= 65536) 
			trace( "Graycode:int2gray: error: n is to big. It's biger than 2^16")
        return ((n>>1) ^ n).toString(2);
		}
		public function binary2gray( n:String):String
		{
			return int2gray( binary2int( n) );	
		}
		public function gray2int ( n:String):int
		{
			return binary2int( gray2binary(n) )
		}
		public function gray2binary ( g:String):String
		{
			//this was hard, i tried the iteratiion teqnique.
			// i found this on the internet @ http://www.dspguru.com/comp.dsp/tricks/alg/grayconv.htm
			/*
			From: Jerry Avins <jya@ieee.org>
			Subject: Convering Between Binary and Gray Code
			Date: 28 Sep 2000
			Newsgroups: comp.dsp
			
			he also had
			unsigned short binaryToGray(unsigned short num)
			{
        		return (num>>1) ^ num;
			}
			*/
			var ga:int = binary2int( g )	
			var temp:int = ga ^ ( ga>>8);
        	temp ^= (temp>>4);
        	temp ^= (temp>>2);
        	temp ^= (temp>>1);
        	return int2binary (temp) ;
		}
		public function int2binary ( n:int):String
		{
			return n.toString(2);
		}

		public function int2hex( n:int ):String
		{
			return n.toString(16).toUpperCase();
		}
		public function binary2int ( n:String ):int
		{
			return parseInt(n, 2)	
		}
		public function binary2hex ( n:String):String
		{
			return int2hex( parseInt(n, 16) )
		}
		
	}

	
}