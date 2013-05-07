package pug.model.effect;
import pug.model.symbol.Symbol;
import pug.model.symbol.SymbolLayer;
import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class EffectSymbol extends Effect
{
	public static function create( symbol:Symbol ):EffectSymbol {
		if ( Std.is( symbol, SymbolLayer ) ) {
			return new EffectSymbolLayer( symbol );
		} else
			return new EffectSymbol( symbol );
	}
	
	public var symbol:Symbol;

	public function new( symbol:Symbol ) 
	{
		super( [] );
        id = symbol.id+Math.floor(Math.random()*1000);
		this.symbol = symbol;
	}
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
		export.xml.set("use", symbol.id );
        export.xml.nodeName = "symbol";
		return export;
	}
	
	override public function clone():Effect {
		return new EffectSymbol( symbol );
	}
}
