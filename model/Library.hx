package pug.model;

//import haxe.Int;
//import haxe.crypto.Crc32;
import pug.model.symbol.Symbol;
import pug.model.symbol.SymbolImage;
import pug.model.symbol.SymbolShape;
import nme.Assets;
import Xml;
import pug.model.utils.XmlFormatter;
import nme.display.BitmapData;
import nme.utils.ByteArray;

import hsl.haxe.DirectSignaler;
import haxe.io.Bytes;
import haxe.io.Input;

typedef FILEDATA = {
	name: String,
	bmd: BitmapData,
	string: String,
	bytes: Bytes,
	crc: Int
}

typedef LIB_DATA = {
    xml:Xml,
    images:Map<String,FILEDATA>,
	svgs:Map<String,FILEDATA>
}

typedef EXPORT_PUG = {
    var xml:Xml;
    var files:Array<FILEDATA>;
}

/**
 * ...
 * @author Jarnik
 */
class Library
{

    public static var lib:Library;

	public var symbols:Array<Symbol>;
	private var loaderPug:LoaderPug;
	public var onLibLoaded:DirectSignaler<Void>;
	
	public function new() 
	{
		symbols = [];
		loaderPug = new LoaderPug();
		loaderPug.onLibDataLoaded.bind( importLibData );
		
		onLibLoaded = new DirectSignaler(this);
        lib = this;
	}
	
	public function export():EXPORT_PUG {
		sortSymbols();
		
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
		var data:Bytes = Bytes.ofString( str.toString() );
        export.files.push( {
            name: "pug.xml",
			bmd: null,
			string: null,
            bytes: data,
			crc: 0// let filehandler do it Crc32.make( data )
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
        while ( cycle < 100 && parse.length > 0 ) {
            e = parse.shift();
            s = Symbol.parse( e, this, libData );
            if ( s == null ) {
                //trace("could not parse "+e.nodeName);
                parse.push( e );
            } else {
                symbols.push( s );
            }
            cycle++;
        }
        //trace("done cycles "+cycle);
		
		sortSymbols();
		
		onLibLoaded.dispatch();
    }
	
	private function cmpSymbols( a:Symbol, b:Symbol ):Int {
		if ( a.id == b.id )
			return 0;
		if ( a.id > b.id )
			return 1;
		return -1;
	}
	
	public function sortSymbols():Void {
		symbols.sort( cmpSymbols );
	}
	
	public function removeSymbol( s:Symbol ):Void {
		symbols.remove( s );
	}
	
	public function importLibDataPug( input:Input ):Void {
		loaderPug.importLibDataPug( input );
	}

	public function importByteArrayPUG( ba:ByteArray ):Void {
        var input:haxe.io.BytesInput = new haxe.io.BytesInput( BAtoBytes( ba ) );
        importLibDataPug( input );
    }
	
	public function importBitmap( id:String, img:FILEDATA ):Void {
		var duplicate:Symbol = get( id );
		if ( duplicate != null ) {
			if ( Std.is( duplicate, SymbolImage ) )
				cast( duplicate, SymbolImage ).updateBitmap( img.bmd, img );
		} else
			symbols.push( new SymbolImage( id, img.bmd, 0, 0, 1, img ) );
	}
	
	public function importSVG( id:String, svg:String ):Void {
		var duplicate:Symbol = get( id );
		if ( duplicate != null ) {
			if ( Std.is( duplicate, SymbolShape ) )
				cast( duplicate, SymbolShape ).updateSVG( svg );
		} else
			symbols.push( new SymbolShape( id, svg, {
				name: id,
				bmd: null,
				string: svg,
				bytes: null,
				crc: 0
			}) );
	}

    public static function BAtoBytes( ba:ByteArray ):Bytes {
        var b:Bytes = Bytes.alloc( ba.length );
		ba.position = 0;
		for ( i in 0...ba.length )
			b.set( i, ba.readByte() );
        return b;
    }
	
}
