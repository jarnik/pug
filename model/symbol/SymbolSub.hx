package pug.model.symbol;

//import pug.model.symbol.IS;

/**
 * ...
 * @author Jarnik
 */
class SymbolSub extends Symbol, implements ISymbolSub {
	
	public var source:String;
	public var path:String;
	
	public function new( id:String, source:String, path:String ) {
		super( id );
		this.source = source;
		this.path = path;
	}
}