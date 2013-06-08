package pug.render;

import format.gfx.GfxGraphics;
import format.svg.Path;
import format.svg.RenderContext;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import pug.model.effect.Effect;
import pug.model.faxe.DisplayNode;
import pug.model.faxe.DisplayShape;
import pug.model.symbol.SymbolShape;

/**
 * ...
 * @author Jarnik
 */
class RenderShape extends Render
{
	
	public var shape:SymbolShape;
	public var sprite:DisplayObject;
	public var node:DisplayNode;

	public function new( effect:Effect, shape:SymbolShape ) 
	{
		super( effect );
		this.shape = shape;
		
		node = shape.svgRoot;
		sprite = renderDisplayNode( node );
		sprite.x = 0;
		sprite.y = 0;
		addChild( sprite );
	}
	
	public override function render( frame:Int, applyTransforms:Bool = true ):Void {
		super.render( frame, applyTransforms );
		renderSubElements( frame );
	}
	
	public static function renderDisplayNode( n:DisplayNode ):DisplayObject {
		var s:Sprite = new Sprite();
		s.x = n.fixedSize.x;
        s.y = n.fixedSize.y;
		var kid:DisplayObject;
        for ( c in n.children ) {
			if ( Std.is( c, DisplayNode ) ) {
				kid = renderDisplayNode( cast( c, DisplayNode ) );
			} else {
				kid = renderDisplayShape( cast( c, DisplayShape ) );
			}
			if ( kid != null )
				s.addChild( kid );
        }
		
		return s;
	}
	
	
	public static function renderDisplayShape( n:DisplayShape ):DisplayObject {
        var s:Sprite = new Sprite();
        s.x = n.fixedSize.x;
        s.y = n.fixedSize.y;
        //trace("rendering shape at "+s.x+" "+s.y);
        var inPath:Path = n.path;
        var m:Matrix = inPath.matrix.clone();
        var mGfx:GfxGraphics = new GfxGraphics( s.graphics );
        var context:RenderContext = new RenderContext( m );

        // Move to avoid the case of:
        //  1. finish drawing line on last path
        //  2. set fill=something
        //  3. move (this draws in the fill)
        //  4. continue with "real" drawing
        inPath.segments[0].toGfx(mGfx, context);
 
        switch(inPath.fill)
        {
           case FillGrad(grad):
              grad.updateMatrix(m);
              mGfx.beginGradientFill(grad);
           case FillSolid(colour):
              mGfx.beginFill(colour,inPath.fill_alpha);
           case FillNone:
              //mGfx.endFill();
        }
 
        if (inPath.stroke_colour==null)
        {
           //mGfx.lineStyle();
        }
        else
        {
           var style = new format.gfx.LineStyle();
           var scale = Math.sqrt(m.a*m.a + m.c*m.c);
           style.thickness = inPath.stroke_width*scale;
           style.alpha = inPath.stroke_alpha;
           style.color = inPath.stroke_colour;
           style.capsStyle = inPath.stroke_caps;
           style.jointStyle = inPath.joint_style;
           style.miterLimit = inPath.miter_limit;
           mGfx.lineStyle(style);
        }

        for(segment in inPath.segments)           
            segment.toGfx(mGfx, context);

        mGfx.endFill();
        mGfx.endLineStyle();

        s.alpha = inPath.alpha;

        return s;
    }
	
	public override function getFixedSize():Rectangle {
		return node.fixedSize;
	}
	
}