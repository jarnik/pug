package pug.model.effect;

/**
 * ...
 * @author Jarnik
 */
class EffectSubElement extends Effect
{
	public var path:Array<Int>;
	public var source:Effect;

	public function new( source:Effect, path:Array<Int> ) {
		super( [] );
		this.source = source;
		this.path = path;
		renderable = false;
		source.addSubElement( this );
	}
	
}