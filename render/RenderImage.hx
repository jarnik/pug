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
	public var bitmap:Bitmap;

	public function new( effect:Effect, image:SymbolImage ) {
		super( effect );
		this.image = image;
		addChild( bitmap = new Bitmap() );
		bitmap.bitmapData = image.frames[ 0 ];
        bitmap.x = -image.frameWidth/2;
        bitmap.y = -image.frameHeight/2;
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
		bitmap.bitmapData = image.frames[ frame ];
		super.render( frame, applyTransforms );
		
	}
	
}
