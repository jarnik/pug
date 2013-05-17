package pug.model.symbol;
import nme.geom.Rectangle;

import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class Symbol
{
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        switch ( xml.nodeName ) {
            case "sprite":
                return SymbolImage.parse( xml, l, libData );
            case "symbolLayer":
                return SymbolLayer.parse( xml, l, libData );
			case "symbolShape":
                return SymbolShape.parse( xml, l, libData );
        }
        return null;
    }

	public var id:String;
	public var size:Rectangle;

	public function new( id:String ) 
	{
		this.id = id;
		size = new Rectangle();
	}
	
	public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("symbol");
		xml.set( "id", id );
        export.xml = xml;        
		return export;
	}
	
}
