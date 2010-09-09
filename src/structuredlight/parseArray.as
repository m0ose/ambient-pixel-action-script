
package structuredlight
{
	class parseArray
	{
		private var txt:String =""
			private var i:int = 0;
		
		public function parseArray():void{
		}
		public function parse( str:String, wid:int , height:int ):Array
		{
			txt = str;
		}
		
		
		
		
		public function run():Array
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