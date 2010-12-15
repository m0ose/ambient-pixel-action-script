package MultiProjector
{
	import flash.geom.Point;

	public class PointOpaque extends Point
	{
		public var opacity:Number = 1.0;
		public function PointOpaque( x_:Number, y_:Number, opacity_:Number = 1.0)
		{
			this.x = Number(x_);
			this.y = Number(y_);
			this.opacity = Number(opacity_);
		}
		public override function clone():Point
		{
			return (   new PointOpaque( Number( this.x), Number( this.y), Number( this.opacity) )   );
		}
	}
}