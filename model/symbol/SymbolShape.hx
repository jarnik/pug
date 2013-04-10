package pug.model.symbol;

import format.svg.Path;
import format.gfx.GfxExtent;
import format.svg.RenderContext;

class SymbolShape extends Symbol
{
    public var path:Path;

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
    }
    
}
