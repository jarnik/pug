package pug.model.symbol;

import haxe.io.Bytes;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import nme.utils.ByteArray;

import pug.model.utils.PNGEncoder;
import pug.model.Library;

class SymbolImage extends Symbol
{
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        var id:String = xml.get("id");
        return new SymbolImage( id, libData.images.get( id ) );
    }
	
	private function BAtoBytes( ba:ByteArray ):Bytes {
		var b:Bytes = Bytes.alloc( ba.length );
		ba.position = 0;
		for ( i in 0...ba.length )
			b.set( i, ba.readByte() );
		return b;
	}
	
    public var bitmapData:BitmapData;

	public function new ( id:String, bmd:BitmapData ) 
	{
		super( id );
		
        bitmapData = bmd;
		size = new Rectangle( 0, 0, bitmapData.width, bitmapData.height );
	}

	private function getPNGBytes():Bytes {
        #if flash
			var data:ByteArray = PNGEncoder.encode( bitmapData );
			return BAtoBytes( data );
		#else
			var data:ByteArray = bitmapData.encode("png", 1);
			return data;
		#end
    }
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("sprite");
        var filename:String = id+".png";
		xml.set( "id", id );
		xml.set( "data", filename );
        export.xml = xml;
        export.files.push( {
            name: filename,
            bytes: getPNGBytes()
        } );
		
		return export;
	}
   
}
