package pug.model;

import pug.model.symbol.Symbol;
import nme.Assets;
import Xml;
import pug.model.utils.XmlFormatter;
import nme.display.BitmapData;
import nme.utils.ByteArray;

import hsl.haxe.DirectSignaler;
import haxe.io.Bytes;
import haxe.io.Input;

typedef LIB_DATA = {
    xml:Xml,
    images:Hash<BitmapData>
}

typedef EXPORT_PUG_FILE = {
    var name:String;
    var bytes:Bytes;
}

typedef EXPORT_PUG = {
    var xml:Xml;
    var files:Array<EXPORT_PUG_FILE>;
}

/**
 * ...
 * @author Jarnik
 */
class Library
{

	public var symbols:Array<Symbol>;
	private var loaderPug:LoaderPug;
	public var onLibLoaded:DirectSignaler<Void>;
	
	public function new() 
	{
		symbols = [];
		loaderPug = new LoaderPug();
		loaderPug.onLibDataLoaded.bind( importLibData );
		
		onLibLoaded = new DirectSignaler(this);
	}
	
	public function export():EXPORT_PUG {
		var xml:Xml = Xml.createElement("library");
        var export:EXPORT_PUG = {
            xml:xml,
            files:[]
        };
        var export_child:EXPORT_PUG;
		for ( s in symbols ) {
            export_child = s.export( export );
			xml.addChild( export_child.xml );
		}
		
		var str:StringBuf = new StringBuf();
		XmlFormatter.stringify( xml, str, " " );
        export.files.push( {
            name: "pug.xml",
            bytes: Bytes.ofString( str.toString() )
        } );
        export.xml = xml;
		return export;
	}

    public function get( id:String ):Symbol {
        for ( s in symbols )
            if ( s.id == id )
                return s;
        return null;
    }

    public function importLibData( libData:LIB_DATA ):Void {
        symbols = [];

        var xml:Xml = libData.xml.firstElement();
        var s:Symbol;
        var cycle:Int = 0;
        var parse:Array<Xml> = [];
        for ( e in  xml.elements() )
            parse.push( e );

        var e:Xml;
        while ( cycle < 10 && parse.length > 0 ) {
            e = parse.shift();
            s = Symbol.parse( e, this, libData );
            if ( s == null ) {
                trace("could not parse "+e.nodeName);
                parse.push( e );
            } else {
                symbols.push( s );
            }
            cycle++;
        }
        //trace("done cycles "+cycle);
		
		onLibLoaded.dispatch();
    }
	
	public function importLibDataPug( input:Input ):Void {
		loaderPug.importLibDataPug( input );
	}

	public function importByteArrayPUG( ba:ByteArray ):Void {
        var input:haxe.io.BytesInput = new haxe.io.BytesInput( BAtoBytes( ba ) );
        importLibDataPug( input );
    }

    public static function BAtoBytes( ba:ByteArray ):Bytes {
        var b:Bytes = Bytes.alloc( ba.length );
		ba.position = 0;
		for ( i in 0...ba.length )
			b.set( i, ba.readByte() );
        return b;
    }
	
}