package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class Value
{
	public function new() 
	{
		
	}
	
	public function setValue( value:Dynamic ):Void {
	}

	public function getValue():Dynamic {
        return null;
    }

    public function parse( s:String ):Void {
        setValue( Std.parseFloat( s ) );
    }
	
	public function mix( v:Value, ratio:Float ):Dynamic {
		return 0;
	}
	
}
