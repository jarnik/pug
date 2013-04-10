package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueFrame extends Value
{
	public var frame:Int;

	public function new( f:Int = 0 ) 
	{
		super();
		setValue( f );
	}
	
	override public function setValue( value:Dynamic ) {
		frame = value;
	}
	
	override public function getValue():Dynamic {
        return frame;
    }

	override public function parse( s:String ):Void {
        frame = Std.parseInt( s );
    }
}
