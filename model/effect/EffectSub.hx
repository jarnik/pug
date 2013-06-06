package pug.model.effect;

import pug.model.symbol.ISymbolSub;
import pug.model.symbol.Symbol;

/**
 * ...
 * @author Jarnik
 */
class EffectSub extends Effect, implements ISymbolSub
{
	public var source:String;
	public var path:String;

	public function new( source:String, path:String ) {
		this.source = source;
		this.path = path;
		super( [] );
	}
}