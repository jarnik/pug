package pug.model.symbol;

import haxe.Int32;
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
		var file:FILEDATA = libData.images.get( id );
        return new SymbolImage( id, file.bmd, fw, fh, fc, file );
    }
	
	public static function BAtoBytes( ba:ByteArray ):Bytes {
		var b:Bytes = Bytes.alloc( ba.length );
		ba.position = 0;
		for ( i in 0...ba.length )
			b.set( i, ba.readByte() );
		return b;
	}
	
    public var frames:Array<BitmapData>;
	public var frameHeight:Int;
	public var frameWidth:Int;
	
	private var dirty:Bool;
	private var file:FILEDATA;

	public function new ( id:String, bmd:BitmapData, frameWidth:Int = 0, frameHeight:Int = 0, frameCount:Int = 0, file:FILEDATA = null ) {
		super( id );
		
		if ( frameWidth == 0 || frameHeight == 0 ) {
			frameWidth = bmd.width;
			frameHeight = bmd.height;
		}
		
		this.file = file;
		dirty = Int32.isZero( file.crc );
		
		this.frameWidth = frameWidth;
		this.frameHeight = frameHeight;
		parseFrames( bmd, frameCount );
		
		size = new Rectangle( 0, 0, frameWidth, frameHeight );
	}

	private function getPNGBytes():Bytes {
		if ( !dirty )
			return file.bytes;
		
		var bitmapData:BitmapData = getFullCanvas();
		dirty = false;
		
        #if flash
			file.bytes = BAtoBytes( PNGEncoder.encode( bitmapData ) );
			file.crc = format.tools.CRC32.encode( file.bytes );
		#else
			file.bytes = bitmapData.encode("png", 1);
		#end
		
		return file.bytes;
    }
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
		var xml:Xml = export.xml;
		xml.nodeName = "sprite";
        var filename:String = id+".png";
		xml.set( "data", filename );
		xml.set( "frameWidth", Std.string( frameWidth ) );
		xml.set( "frameHeight", Std.string( frameHeight ) );
		xml.set( "frames", Std.string( frames.length ) );
		file.name = filename;
		file.bytes = getPNGBytes();
		export.files.push( file );
		
		return export;
	}
	
	public function updateBitmap( bmd:BitmapData, file:FILEDATA = null ):Void {
		this.file = file;
		setDirty();
		parseFrames( bmd );
	}
	
	public function setDirty():Void {
		dirty = true;
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
		
		var bitmapData:BitmapData;
		#if neko
			bitmapData = new BitmapData( cols * frameWidth, rows * frameHeight, true, { rgb: 0, a: 0 } );
		#else
			bitmapData = new BitmapData( cols * frameWidth, rows * frameHeight, true, 0x00000000 );
		#end
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
