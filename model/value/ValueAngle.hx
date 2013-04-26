package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueAngle extends Value
{
	public var degrees:Float;

	public function new( a:Float = 0 ) 
	{
		super();
        setValue( a );
	}

	override public function setValue( value:Dynamic ) {		
		degrees = value;
	}

	override public function getValue():Dynamic {
        return degrees;
    }
	
	override public function mix( v:Value, ratio:Float ):Dynamic {
		return degrees * (1 - ratio) + cast( v, ValueAngle ).degrees * (ratio);
	}
}
