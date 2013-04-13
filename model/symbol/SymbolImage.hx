package pug.model.symbol;

import haxe.io.Bytes;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import nme.utils.ByteArray;

import pug.model.utils.PNGEncoder;
import pug.model.Library;

class SymbolImage extends Symbol
{
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        var id:String = xml.get("id");
		var fw:Int = Std.parseInt( xml.get("frameWidth") );
		var fh:Int = Std.parseInt( xml.get("frameHeight") );
        return new SymbolImage( id, libData.images.get( id ), fw, fh );
    }
	
	private function BAtoBytes( ba:ByteArray ):Bytes {
		var b:Bytes = Bytes.alloc( ba.length );
		ba.position = 0;
		for ( i in 0...ba.length )
			b.set( i, ba.readByte() );
		return b;
	}
	
    public var frames:Array<BitmapData>;
	public var frameHeight:Int;
	public var frameWidth:Int;

	public function new ( id:String, bmd:BitmapData, frameWidth:Int = 0, frameHeight:Int = 0 ) {
		super( id );
		
		if ( frameWidth == 0 || frameHeight == 0 ) {
			frameWidth = bmd.width;
			frameHeight = bmd.height;
		}
		
		frames = [];
		var frameCount:Int = Math.ceil( bmd.width / frameWidth );
		var frame:BitmapData;
		var r:Rectangle = new Rectangle( 0, 0, frameWidth, frameHeight );
		var p:Point = new Point();
		for ( i in 0...frameCount ) {
			r.x = i * frameWidth;
			r.width = Math.min( frameWidth, bmd.width - r.x );
			frame = new BitmapData( frameWidth, frameHeight );
			frame.copyPixels( bmd, r, p );
			frames.push( frame );
		}
		
		this.frameWidth = frameWidth;
		this.frameHeight = frameHeight;
		
		size = new Rectangle( 0, 0, frameWidth, frameHeight );
	}

	private function getPNGBytes():Bytes {
		var bitmapData:BitmapData = new BitmapData( frames.length * frameWidth, frameWidth );
		var r:Rectangle = new Rectangle( 0, 0, frameWidth, frameHeight );
		var p:Point = new Point();
		for ( i in 0...frames.length ) {
			p.x = i * frameWidth;
			bitmapData.copyPixels( frames[i], r, p );
		}
		
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
		xml.set( "frameWidth", Std.string( frameWidth ) );
		xml.set( "frameHeight", Std.string( frameHeight ) );
        export.xml = xml;
        export.files.push( {
            name: filename,
            bytes: getPNGBytes()
        } );
		
		return export;
	}
   
}
