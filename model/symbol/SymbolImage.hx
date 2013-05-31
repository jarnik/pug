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
		var fc:Int = 0;
		if ( xml.get("frames") != null )
			fc = Std.parseInt( xml.get("frames") );
        return new SymbolImage( id, libData.images.get( id ), fw, fh, fc );
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

	public function new ( id:String, bmd:BitmapData, frameWidth:Int = 0, frameHeight:Int = 0, frameCount:Int = 0 ) {
		super( id );
		
		if ( frameWidth == 0 || frameHeight == 0 ) {
			frameWidth = bmd.width;
			frameHeight = bmd.height;
		}
		
		this.frameWidth = frameWidth;
		this.frameHeight = frameHeight;
		parseFrames( bmd, frameCount );
		
		size = new Rectangle( 0, 0, frameWidth, frameHeight );
	}

	private function getPNGBytes():Bytes {
		var bitmapData:BitmapData = getFullCanvas();
		
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
		xml.set( "frames", Std.string( frames.length ) );
        export.xml = xml;
        export.files.push( {
            name: filename,
            bytes: getPNGBytes()
        } );
		
		return export;
	}
	
	public function updateBitmap( bmd:BitmapData ):Void {
		parseFrames( bmd );
	}
   
	private function parseFrames( bmd:BitmapData, frameCount:Int = 0 ):Void {
		frames = [];
		var cols:Int = Math.ceil( bmd.width / frameWidth );
		var rows:Int = Math.ceil( bmd.height / frameHeight );
		
		if ( frameCount == 0 )
			frameCount = cols * rows;
		var frame:BitmapData;
		var r:Rectangle = new Rectangle( 0, 0, frameWidth, frameHeight );
		var p:Point = new Point();
		var i:Int = 0;
		for ( y in 0...rows )
			for ( x in 0...cols ) {
				if ( i >= frameCount )
					continue;
				r.x = x * frameWidth;
				r.width = Math.min( frameWidth, bmd.width - r.x );
				r.y = y * frameHeight;
				r.height = Math.min( frameHeight, bmd.height - r.y );
				#if !neko
				frame = new BitmapData( frameWidth, frameHeight, true, 0x00000000 );
				#else
				frame = new BitmapData( frameWidth, frameHeight, true, { rgb: 0, a: 0 } );
				#end
				frame.copyPixels( bmd, r, p );
				frames.push( frame );
				i++;
			}
	}
	
	private function getFullCanvas():BitmapData	{
		
		var cols:Int = 0;
		var rows:Int = 0;
		
		/*
		// POT - power of two texture
		var n:Int = 1;
		var willFit:Bool = false;
		var size:Int = 0;
		while ( !willFit ) {
			size = Math.round( Math.pow( 2, n ) );
			cols = Math.floor( size / frameWidth );
			if ( cols > 0 ) {
				rows = Math.ceil( frames.length / cols );
				if ( rows * frameHeight <= size )
					willFit = true;
			}
			n++;
		}		*/
		
		var prevAngle:Float = 0;
		var angle:Float = 0;
		while ( cols < frames.length ) {
			cols++;
			rows = Math.ceil( frames.length / cols );
			angle = Math.atan(( cols * frameWidth ) / ( rows * frameHeight ));
			if (  Math.abs( 1 - prevAngle ) < Math.abs( 1 - angle ) ) {
				cols--;
				break;
			}
			prevAngle = angle;
		}
		rows = Math.ceil( frames.length / cols );
		
		var bitmapData:BitmapData = new BitmapData( cols*frameWidth, rows*frameHeight, true, 0x00000000 );
		var r:Rectangle = new Rectangle( 0, 0, frameWidth, frameHeight );
		var p:Point = new Point();
		var i:Int = 0;
		for ( y in 0...rows )
			for ( x in 0...cols ) {
				if ( i < frames.length ) {
					p.x = x * frameWidth;
					p.y = y * frameHeight;
					bitmapData.copyPixels( frames[ i ], r, p );
				}
				i++;
			}
		return bitmapData;
	}
	
	public function resize( global:Bool, w:Int, h:Int, frameCount:Int = 0 ):Void {
		if ( global ) {
			var bitmapData:BitmapData = getFullCanvas();
			this.frameWidth = w;
			this.frameHeight = h;
			parseFrames( bitmapData, frameCount );
		} else {
			// TODO resize image locally
		}
	}
}
