package structuredlight
{
	import flash.geom.Point;

	public class parseMap2
	{
	
		private var i:int//iterator for parseing
		private var txt:String
		private var width:int;
		private var height:int;
		
		
		
		public function parseMap2()
		{
		}
		
		
		public function camMap2XML( cm:CameraProjecterMap2):String
		{ 
			var xm:XML = <cammap>			</cammap>;
			//xm.appendChild(<scaleX> {cm._scaleX } </scaleX>);
			//xm.appendChild(<scaleY> {cm._scaleY } </scaleY>);
			xm.appendChild(<width> {cm.width() } </width> );
			xm.appendChild(<height> {cm.height() } </height> );
			xm.appendChild(<threshold> {cm._threshold} </threshold> );
			xm.appendChild(<gray_width> {cm._gray_width} </gray_width> );	
			xm.appendChild(<gray_height> {cm._gray_height} </gray_height> );			
			xm.appendChild(<cam_width> {cm._cam_width} </cam_width> );
			xm.appendChild(<cam_height> {cm._cam_height} </cam_height> );
			xm.appendChild(<screen_width> {cm._screen_width} </screen_width> );
			xm.appendChild(<screen_height> {cm._screen_height} </screen_height> );
			
			//var mp:XML = <graymap width={cm.width()} height={cm.height()} > {cm.map}  </graymap> ;
			var mp:XML = <graymap> {cm.map}  </graymap> ;

			xm.appendChild(mp);
			
			return xm.toXMLString();
		}	
		
		/*public function projMap2XML( pm:ProjectorMap):String
		{ 
		//TODO
		}
		*/
		
		
		
		
		public function parse(sometext:String):CameraProjecterMap2
		{
			var xm:XML = XML(sometext);
			
			var cm:CameraProjecterMap2 = new CameraProjecterMap2();
			//if( xm.scaleX)
			//	cm._scaleX = int( xm.scaleX.toString() ); 
			//if( xm.scaleY)
			//	cm._scaleY = int( xm.scaleY.toString() ); 
			if( xm.threshold )
				cm._threshold = int( xm.threshold.toString() );
			if( xm.width)
				width = int(xm.width.toString() );
			if( xm.height)
				height = int( xm.height.toString() );
			if( xm.gray_width )
				cm._gray_width = int( xm.gray_width.toString() );
			if( xm.gray_height )
				cm._gray_height = int( xm.gray_height.toString() );
			if( xm.cam_width)
				cm._cam_width = int( xm.cam_width.toString() );
			if( xm.cam_height)
				cm._cam_height = int( xm.cam_height.toString() );
			if( xm.screen_width)
				cm._screen_width = int( xm.screen_width.toString() );
			if( xm.screen_height)
				cm._screen_height = int( xm.screen_height.toString() );
			
			
			if( xm.graymap )
			{
			}
			else //old style map
			{
				width = xm.@width;
				height = xm.@height;
			}
			
			txt = xm.graymap.toString();
			i=0
				
			cm.map = doArray();
			return cm;
		}
		
		
		public function doArray():Array
		{	
			var xtmp:int;
			var ytmp:int;
			var newMap:Array = new Array( width);
			
			for(var x:int=0;x< width;x++)
			{
				
				newMap[x] = new Array( height)
				for( var y:int=0; y< height;y++)
				{
					//example : (x=341, y=330),(x=341, y=338),(x=333, y=341),(x=341, y=341),(x=342, y=309),(x=423, y=330),(x=150, y=330),(x=42, y=74),
					eatUntill('(')
					eatUntill('x')
					xtmp = int(getWord())
					
					eatUntill('y')
					ytmp= int(getWord())
					//_output.text += " ("+xtmp+","+ytmp+") "+"{"+x+","+y+"}"
					
					newMap[x][y] = new Point(xtmp, ytmp)
				}
			}
			//_output.text+="\n" + newMap.toString() + newMap.length.toString() +',' + newMap[0].length
			
			return newMap
		}
		
		//string thigs
		private function eatUntill( char:String):Boolean
		{
			while( txt.charAt(i) != char &&  i < txt.length)
			{
				i++
			}
			if (txt.charAt(i) == char)
			{
				i++
				return true
			}
			return false
			
		}
		private function eatWhite( ):void
		{	
			while( (txt.charAt(i) == ' ' || txt.charAt(i) == '='  )&&  i < txt.length)
			{
				i++
			}	
		}
		private function getWord():String
		{
			eatWhite()
			var res:String=new String()
			var ch:String = txt.charAt(i)
			while(ch != "=" && ch != "," && ch != ";" && ch !="\n" && ch !=" " && ch !='>' && ch != '<'  && ch != ')' && i < txt.length)
			{
				res += ch
				i++
					ch = txt.charAt(i)
			}
			return res.toLowerCase()
		}
		
		
		
		
		
		
		
	}
}