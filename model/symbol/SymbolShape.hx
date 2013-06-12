package pug.model.symbol;

import format.svg.Path;
import format.gfx.GfxExtent;
import format.svg.RenderContext;
import haxe.io.Bytes;
import nme.display.DisplayObject;
import pug.model.faxe.DisplayNode;
import pug.model.faxe.ParserSVG;
import pug.model.Library;
import pug.model.symbol.ISymbolSub;
import haxe.Int32;

class SymbolShape extends Symbol
{
	
	public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        var id:String = xml.get("id");
		var filename:String = xml.get( "data" );
		return new SymbolShape( id, libData.svgs.get( id ).string, libData.svgs.get( id ) );
    }
	
	public var svgRoot:DisplayNode;
	public var svg:String;
	private var file:FILEDATA;
	
	public function new ( id:String, svg:String, file:FILEDATA ) {
		this.file = file;
		super( id );
		updateSVG( svg );
	}
	
	public function updateSVG( svg:String ):Void {
		this.svg = svg;
		svgRoot = cast( ParserSVG.parse( svg ), DisplayNode );
	}
	
	public override function fetchSymbolSub( path:String ):SUBASSET {
		var n:DisplayNode = fetchDisplayNode( path );
		if ( n != null )
			return SubAssetDisplayNode( n );
		return null; 
	}
	
	private function fetchDisplayNode( path:String, sourceNode:DisplayNode = null ):DisplayNode {
		if ( sourceNode == null )
			sourceNode = svgRoot;
		
		if ( path == null || path == "" )
			return sourceNode;
			
        var pathElements:Array<String> = path.split("."); 
        //Debug.log("fetching kid "+pathElements[0]+"  ");

        var g:DisplayNode;
        for ( kid in sourceNode.children ) {
            //Debug.log("matching kid "+kid.name);
            if ( !Std.is( kid, DisplayNode ) )
                continue;
            g = cast( kid, DisplayNode );
            if ( g.name == pathElements[0] ) {
                if ( pathElements.length == 1 )
                    return g;
                else
                    return fetchDisplayNode( path.substr( path.indexOf(".")+1 ), g );
            }
        }

        return null;
    }
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
		var xml:Xml = export.xml;
		xml.nodeName = "symbolShape";
		var filename:String = id+".svg";
		xml.set( "data", filename );	
		file.name = filename;
		file.bytes = getSVGBytes();
		export.files.push( file );
		return export;
	}
	
	private function getSVGBytes():Bytes {
		return Bytes.ofString( svg );
	}
	
}
