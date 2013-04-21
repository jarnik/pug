package pug.model;

import haxe.io.Input;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Loader;
import nme.display.LoaderInfo;
import pug.model.Library;
import haxe.io.Bytes;
import nme.events.Event;
import nme.utils.ByteArray;

import hsl.haxe.DirectSignaler;

#if neko
import sys.io.FileInput;
import neko.zip.Reader;
#end

/**
 * ...
 * @author Jarnik
 */
class LoaderPug
{
	public var onLibDataLoaded:DirectSignaler<LIB_DATA>;
	
	private var filesToLoad:Int;
    private var filesLoaded:Int;
    private var loadImagesLoaders:Hash<Loader>;
	private var libData:LIB_DATA;
	private var input:Input;

	public function new() 
	{
		onLibDataLoaded = new DirectSignaler(this);
	}
	
	private function resetLoading():Void {
        filesToLoad = 0;
        filesLoaded = 0;
		libData = { xml:null, images: new Hash<BitmapData>() };
        loadImagesLoaders = new Hash<Loader>();
    }
	
	public function importLibDataPug( input:Input ):Void {
        this.input = input;
		//trace( "gonna read data of " + input );
		#if neko
			var fp:FileInput = cast( input, FileInput );
			var zipFiles:List<ZipEntry> = neko.zip.Reader.readZip( fp );
			fp.close();
			
			var files:List<format.zip.Data.Entry> = new List<format.zip.Data.Entry>();
			for ( f in zipFiles ) {
				files.add({
					fileName: f.fileName,
					fileSize: f.fileSize,
					fileTime: f.fileTime,
					compressed: f.compressed,
					dataSize: 0,                
					data: f.data,
					crc32: f.crc32,
					extraFields : new List()
				});
			}
			
			processLibZip( files );
		#else
			var reader:format.zip.Reader = new format.zip.Reader( input );
			var files:List<format.zip.Data.Entry> = reader.read();
			processLibZip( files );
		#end
	}
	
	private function processLibZip( files:List<format.zip.Data.Entry> ):Void {
        resetLoading();
		filesToLoad = files.length - 1;
		//trace("processLibZip "+filesToLoad);
        var extension:String;
        var id:String;
        for ( f in files ) {
            extension = f.fileName.split(".").pop().toLowerCase();
            id = f.fileName.substr( 0, f.fileName.length - 4 );
            switch ( extension ) {
                case "png":
                    loadImage( id, f.data );
                case "xml":
                    libData.xml = Xml.parse( f.data.toString() );
            }
        }
    }
	
	private function bytesToBA( b:Bytes ):ByteArray {
        var ba:ByteArray = new ByteArray();
		for ( i in 0...b.length )
			ba.writeByte( b.get( i ) );
        ba.position = 0;
        return ba;
    }
	
	private function loadImage( id:String, bytes:Bytes ):Void {
        var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaderComplete );
        loadImagesLoaders.set( id, loader );        
		var ba:ByteArray;
        #if flash
        ba = bytes.getData();
        #else
        ba = bytesToBA( bytes );
        #end
        loader.loadBytes( ba );
	}
	
	private function onImageLoaderComplete( e:Event ):Void {
		//trace("load complete!");
        var bitmapData:BitmapData = null;
        var loader:Loader = cast( e.target, LoaderInfo ).loader;
		if ( Std.is( loader.content, Bitmap ) )
			bitmapData = cast( loader.content, Bitmap ).bitmapData;
        for ( id in loadImagesLoaders.keys() ) {
            if ( loadImagesLoaders.get( id ) == loader ) {
                //trace("A-HA! this is a "+id+" "+cast( loader.content, Bitmap ).bitmapData );
                libData.images.set( id, bitmapData );
                break;
            }
        }
        filesLoaded++;
        if ( filesToLoad == filesLoaded ) {
            //trace("lib done with images " + libData.images );
			//for ( k in libData.images.keys() ) 
				//trace( "img "+k+" "+libData.images.get( k ).width+"x"+libData.images.get( k ).height );
            //onLibDataLoaded.dispatch( libData );
			#if !neko
				input.close();
			#end
			onLibDataLoaded.dispatch( libData );
        }
	}
	
}
