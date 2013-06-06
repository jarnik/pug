package pug.model.effect;

import pug.model.symbol.ISymbolSub;
import pug.model.symbol.Symbol;
import pug.model.Library;

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
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
		export.xml.set("source", source );
		export.xml.set("path", path );
        export.xml.nodeName = "effectSub";
		return export;
	}
	
	override public function clone():Effect {
		return new EffectSub( source, path );
	}
}