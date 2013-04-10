package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueScale extends Value
{
	public var scale:Float;
	
	public function new( s:Float = 1 ) 
	{
		super();
		setValue( s );
	}
	
	override public function setValue( value:Dynamic ) {
		scale = value;
	}
	
	override public function getValue():Dynamic {
        return scale;
    }
}