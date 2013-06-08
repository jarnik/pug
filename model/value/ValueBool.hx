package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueBool extends Value
{
	public var b:Bool;
	public var caption:String;

	public function new( b:Bool = false, caption:String = "" ) 
	{
		super();
		this.caption = caption;
		setValue( b );
	}
	
	override public function setValue( value:Dynamic ) {
		b = value;
	}
	
	override public function getValue():Dynamic {
        return b;
    }

    override public function parse( s:String ):Void {
        setValue( s == "true" );
    }
	
	override public function mix( v:Value, ratio:Float ):Dynamic {
		return b;
	}
	
	override public function clone():Value {
		return new ValueBool( b );
	}
	
}