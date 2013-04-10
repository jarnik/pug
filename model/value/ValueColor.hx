package pug.model.value;

/**
 * ...
 * @author Jarnik
 */
class ValueColor extends Value
{

	public function new() 
	{
		super();
	}
	
	override public function getValue():Dynamic {
        return "0x000000";
    }
}
