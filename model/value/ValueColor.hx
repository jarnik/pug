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
		color = value;
	}
	
	override public function getValue():Dynamic {
        return color;
    }
	
	override public function parse( s:String ):Void {
        color = Std.parseInt( "0x"+s );
    }
}
