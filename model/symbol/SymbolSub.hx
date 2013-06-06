package pug.model.symbol;

import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class SymbolSub extends Symbol, implements ISymbolSub {
	
	public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        var id:String = xml.get("id");
		var source:String = xml.get( "source" );
		var path:String = xml.get( "path" );
		return new SymbolSub( id, source, path );
    }
	
	public var source:String;
	public var path:String;
	
	public function new( id:String, source:String, path:String ) {
		super( id );
		this.source = source;
		this.path = path;
	}
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("symbolSub");
		xml.set( "id", id );
		xml.set( "source", source );
		xml.set( "path", path );
		export.xml = xml;
		return export;
	}
}