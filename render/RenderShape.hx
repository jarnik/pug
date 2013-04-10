package render;

import model.symbol.SymbolShape;

/**
 * ...
 * @author Jarnik
 */
class RenderShape extends Render
{
	public var shape:SymbolShape;

	public function new( shape:SymbolShape ) 
	{
		this.shape = shape;
	}
	
	override public function render( frame:Int ):Void {
		super.render();
		
		applyTransform( shape.gizmoTransform, this, frame );
		applyAttributes( shape.gizmoAttributes, this, frame );
        var s:Sprite = new Sprite();
        //s.x = fixedSize.x;
        //s.y = fixedSize.y;
        //trace("rendering shape at "+s.x+" "+s.y);

        var inPath:Path = shape.path;
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

        for(segment in path.segments)           
            segment.toGfx(mGfx, context);

        mGfx.endFill();
        mGfx.endLineStyle();

        //s.alpha = alpha;

        addChild( s );
    }
	
}