package pug.model;

import haxe.io.Input;
import haxe.zip.Entry;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.Loader;
import nme.display.LoaderInfo;
import pug.model.Library;
import haxe.io.Bytes;
import nme.events.Event;
import nme.utils.ByteArray;
import pug.model.symbol.SymbolImage;

import hsl.haxe.DirectSignaler;

#if neko
import sys.io.FileInput;
import haxe.zip.Reader;
#end

typedef LOADCONTENT = {
	loader: Loader,
	content: Bytes,
	crc: Int
}

/**
 * ...
 * @author Jarnik
 */
class LoaderPug
{
	public var onLibDataLoaded:DirectSignaler<LIB_DATA>;
	
	private var filesToLoad:Int;
    private var filesLoaded:Int;
    private var loadImagesLoaders:Map<String,LOADCONTENT>;
	private var libData:LIB_DATA;
	private var input:Input;

	public function new() 
	{
		onLibDataLoaded = new DirectSignaler(this);
	}
	
	private function resetLoading():Void {
        filesToLoad = 0;
        filesLoaded = 0;
		libData = { xml:null, images: new Map<String,FILEDATA>(), svgs: new Map<String,FILEDATA>() };
        loadImagesLoaders = new Map<String,LOADCONTENT>();
    }
	
	public function importLibDataPug( input:Input ):Void {
        this.input = input;
		#if neko
			var fp:Input = input;
			var zipFiles:List<Entry> = Reader.readZip( fp );
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
                    loadImage( id, f.data, f.crc32 );
                case "xml":
                    libData.xml = Xml.parse( f.data.toString() );
				case "svg":
					libData.svgs.set( id, {
						name: id, 
						bmd: null,
						string: f.data.toString(),
						bytes: f.data,
						crc: f.crc32
					});	
					filesLoaded++;        
            }
        }
		checkFilesLoaded();
    }
	
	private function bytesToBA( b:Bytes ):ByteArray {
        var ba:ByteArray = new ByteArray();
		for ( i in 0...b.length )
			ba.writeByte( b.get( i ) );
        ba.position = 0;
        return ba;
    }
	
	private function loadImage( id:String, bytes:Bytes, crc:Int ):Void {
        var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onImageLoaderComplete );
        loadImagesLoaders.set( id, { loader: loader, content: bytes, crc: crc } );        
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
            if ( loadImagesLoaders.get( id ).loader == loader ) {
                //trace("A-HA! this is a "+id+" "+cast( loader.content, Bitmap ).bitmapData );
				libData.images.set( id, { 
					name: id,
					bmd: bitmapData, 
					string: null,
					bytes: loadImagesLoaders.get( id ).content,
					crc: loadImagesLoaders.get( id ).crc
				} );
                break;
            }
        }
		filesLoaded++;
        checkFilesLoaded();
	}
	
	private function checkFilesLoaded():Void {
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
