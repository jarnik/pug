package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueString extends Value
{
	public var string:String;
	
	public function new( s:String = "" ) 
	{
		super();
		setValue( s );
	}
	
	override public function setValue( value:Dynamic ) {
		string = value;
	}
	
	override public function getValue():Dynamic {
        return string;
    }

    override public function parse( s:String ):Void {
        setValue( s );
    }
	
	override public function mix( v:Value, ratio:Float ):Dynamic {
		return string;
	}
}
