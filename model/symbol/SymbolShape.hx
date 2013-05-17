package pug.model.symbol;

import format.svg.Path;
import format.gfx.GfxExtent;
import format.svg.RenderContext;
import haxe.io.Bytes;
import nme.display.DisplayObject;
import pug.model.faxe.DisplayNode;
import pug.model.faxe.ParserSVG;
import pug.model.Library;

enum ShapeSource {
	ShapeLink( shape:SymbolShape, path:String );
	ShapeFile( svg:String, name:String );
}

class SymbolShape extends Symbol
{
	
	public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        var id:String = xml.get("id");
		if ( xml.get( "data" ) != null ) {
			var filename:String = xml.get( "data" );
			return new SymbolShape( id, ShapeFile( libData.svgs.get( id ), id ) );
		} else {
			var source:String = xml.get( "source" );
			var path:String = xml.get( "path" );
			var sourceShape:SymbolShape = cast( l.get( source ), SymbolShape );
			if ( sourceShape == null )
				return null;
			return new SymbolShape( id, ShapeLink( sourceShape, path ) );
		}
		return null;
    }
	
	public var source:ShapeSource;
	private var svgRoot:DisplayNode;
	
	public function new ( id:String, source:ShapeSource ) {
		super( id );
		this.source = source;
		switch ( source ) {
			case ShapeLink( shape, path ):
			case ShapeFile( svg, name ):
				// parse SVG, produce browsable hierarchy composed of Paths
				svgRoot = cast( ParserSVG.parse( svg ), DisplayNode );
		}
	}
	
	public function fetchDisplayNode( path:String, sourceNode:DisplayNode = null ):DisplayNode {
		if ( sourceNode == null )
			sourceNode = getDisplayNode();
		
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
	
	public function getDisplayNode():DisplayNode {
		switch ( source ) {
			case ShapeLink( s, p ):
				return s.fetchDisplayNode( p );
			case ShapeFile( svg, name ):
				return svgRoot;
		}
		return null;
	}
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("symbolShape");
		xml.set( "id", id );
		
		switch ( source ) {
			case ShapeLink( s, p ):
				xml.set( "source", s.id );
				xml.set( "path", p );
			case ShapeFile( svg, name ):
				var filename:String = id+".svg";
				xml.set( "data", filename );			
				export.files.push( {
					name: filename,
					bytes: getSVGBytes()
				} );
		}
		export.xml = xml;
		       
		return export;
	}
	
	public function getSVGBytes():Bytes {
		switch ( source ) {
			case ShapeLink( s, p ):
				return null;
			case ShapeFile( svg, name ):
				return Bytes.ofString( svg );
		}
		return null;
	}
	
	
    /*public var path:Path;

	public function new ( id:String, p:Path ) 
	{
		super( "Shape" );
		
        path = p;
        updateExtent();
	}

    private function updateExtent():Void {
        var gfx:GfxExtent = new GfxExtent();
        var context:RenderContext = new RenderContext( path.matrix.clone() );

        for(segment in path.segments) { 
            segment.toGfx(gfx, context);
        }
		
		size = gfx.extent.clone();
		
        var dx:Float = -gfx.extent.x;
        var dy:Float = -gfx.extent.y;
        path.matrix.translate( dx, dy );
    }*/
    
}
