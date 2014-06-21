package pug.model.symbol;
import nme.geom.Rectangle;

import pug.model.Library;
import pug.model.symbol.ISymbolSub;

/**
 * ...
 * @author Jarnik
 */
class Symbol
{
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
		var s:Symbol = null;
        switch ( xml.nodeName ) {
            case "sprite":
                s = SymbolImage.parse( xml, l, libData );
            case "symbolLayer":
                s = SymbolLayer.parse( xml, l, libData );
            #if pug_svg
			case "symbolShape":
				// backwards compatibility
				if ( xml.get("source") != null )
					s = SymbolSub.parse( xml, l, libData );
				else
					s = SymbolShape.parse( xml, l, libData );
			#end
			case "symbolSub":
                s = SymbolSub.parse( xml, l, libData );
        }
		if ( s != null ) {
			if ( xml.get("width") != null ) {
				s.size.width = Std.parseFloat( xml.get("width") );
				s.size.height = Std.parseFloat( xml.get("height") );
			}
		}
        return s;
    }

	public var id:String;	
	public var size:Rectangle;

	public function new( id:String ) 
	{
		this.id = id;
		size = new Rectangle();
	}
	
	public function fetchSymbolSub( path:String ):SUBASSET {
		return null; 
	}
	
	public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("symbol");
		xml.set( "id", id );
		xml.set( "width", Std.string( size.width ) );
		xml.set( "height", Std.string( size.height ) );
        export.xml = xml;        
		return export;
	}
	
}
