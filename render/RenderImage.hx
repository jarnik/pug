package pug.render;

import pug.model.effect.Effect;
import pug.model.symbol.SymbolImage;
import nme.display.Bitmap;

/**
 * ...
 * @author Jarnik
 */
class RenderImage extends Render
{
	public var image:SymbolImage;

	public function new( effect:Effect, image:SymbolImage ) {
		super( effect );
		this.image = image;
		var b:Bitmap;
		addChild( b = new Bitmap( image.bitmapData ) );		
        b.x = -b.width/2;
        b.y = -b.height/2;
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
		super.render( frame, applyTransforms );
		
	}
	
}
