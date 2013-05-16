package pug.model.symbol;

import format.svg.Path;
import format.gfx.GfxExtent;
import format.svg.RenderContext;
import nme.display.DisplayObject;
import pug.model.faxe.DisplayNode;
import pug.model.faxe.ParserSVG;

enum ShapeSource {
	ShapeLink( shape:SymbolShape, path:String );
	ShapeFile( svg:String, name:String );
}

class SymbolShape extends Symbol
{
	
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
	
	public function fetchDisplayNode( path:String ):DisplayNode {
		// TODO
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
