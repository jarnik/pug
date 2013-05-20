package pug.model.faxe;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.display.Graphics;
import nme.geom.Rectangle;
import nme.geom.Matrix;

import format.svg.PathSegment;
import format.gfx.GfxGraphics;
import format.gfx.GfxExtent;
import format.svg.PathParser;
import format.svg.Path;
import format.svg.RenderContext;

class DisplayShape implements IDisplayNode 
{
    public var path:Path;
    public var fixedSize:Rectangle;

	public function new ( p:Path ) 
	{
        path = p;
        updateExtent();
	}

    private function updateExtent():Void {
        var gfx:GfxExtent = new GfxExtent();
        var context:RenderContext = new RenderContext( path.matrix.clone() );
        for(segment in path.segments) { 
            segment.toGfx(gfx, context);
        }

        fixedSize = gfx.extent;
        var dx:Float = -gfx.extent.x;
        var dy:Float = -gfx.extent.y;
        path.matrix.translate( dx, dy );
    }
}
