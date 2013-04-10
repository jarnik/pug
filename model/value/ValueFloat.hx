package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueFloat extends Value
{
	public var float:Float;

	public function new( f:Float = 0 ) 
	{
		super();
		setValue( f );
	}
	
	override public function setValue( value:Dynamic ) {
		float = value;
	}
	
	override public function getValue():Dynamic {
        return float;
    }

	override public function parse( s:String ):Void {
        float = Std.parseFloat( s );
    }
}
