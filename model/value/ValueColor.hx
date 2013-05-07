package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueColor extends Value
{
	public var color:Int;

	public function new( c:Int = 0xffffff ) 
	{
		super();
		setValue( c );
	}
	
	override public function setValue( value:Dynamic ) {
		parse( value );
	}
	
	override public function getValue():Dynamic {
        return "0x"+StringTools.hex( color, 6 );
    }
	
	override public function parse( s:String ):Void {
        color = Std.parseInt( s );
    }
	
	override public function mix( v:Value, ratio:Float ):Dynamic {
		var r1:Int = (color & 0xff0000) >> 16;
		var g1:Int = (color & 0x00ff00) >> 8;
		var b1:Int = (color & 0x0000ff);
		
		var r2:Int = ((cast( v, ValueColor ).color & 0xff0000) >> 16);
		var g2:Int = ((cast( v, ValueColor ).color & 0x00ff00) >> 8);
		var b2:Int = ((cast( v, ValueColor ).color & 0x0000ff));
		
		var r:Int = Math.round( r1*(1 - ratio) + r2*ratio );
		var g:Int = Math.round( g1*(1 - ratio) + g2*ratio );
		var b:Int = Math.round( b1*(1 - ratio) + b2*ratio );
		return "0x"+StringTools.hex( r << 16 | g << 8 | b, 6 );
	}
	
	override public function clone():Value {
		return new ValueColor( color );
	}
}
