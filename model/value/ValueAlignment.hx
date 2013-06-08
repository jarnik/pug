package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueAlignment extends Value
{

	public var a:String;

	public function new( a:String = "none" ) 
	{
		super();
		setValue( a );
	}
	
	override public function setValue( value:Dynamic ) {
		a = value;
	}
	
	override public function getValue():Dynamic {
        return a;
    }

    override public function parse( a:String ):Void {
        setValue( a );
    }
	
	override public function mix( v:Value, ratio:Float ):Dynamic {
		return a;
	}
	
	override public function clone():Value {
		return new ValueAlignment( a );
	}
	
}
