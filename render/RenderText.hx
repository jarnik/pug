package pug.render;

import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import pug.model.effect.Effect;
import pug.model.effect.EffectText;

/**
 * ...
 * @author Jarnik
 */
class RenderText extends Render
{
	private var tf:TextField;
	private var format:TextFormat;

	public function new( effect:Effect ) {
		super( effect );
		tf = new TextField();
		format = new TextFormat();
		tf.defaultTextFormat = format;
		addChild( tf );
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        super.render( frame, applyTransforms );
		var et:EffectText = cast( effect, EffectText );
		var font:Array<Dynamic> = et.gizmoText.paramFont.getValues( frame );		
		var size:Array<Dynamic> = et.gizmoText.paramSize.getValues( frame );		
		var text:String = et.gizmoText.paramText.getValues( frame )[ 0 ];
		var alignment:String = et.gizmoText.paramAlignment.getValues( frame )[ 0 ];
		var color:Int = et.gizmoText.paramColor.getValues( frame )[ 0 ];
		format.font = font[ 0 ];
		format.size = font[ 1 ];
		switch ( alignment ) {
			case "left", "": format.align = TextFormatAlign.LEFT;
			case "right": format.align = TextFormatAlign.RIGHT;
			case "center": format.align = TextFormatAlign.CENTER;
		}
		format.color = color;		
		tf.width = size[ 0 ];
		tf.height = size[ 1 ];
		if ( tf.text != text )
			tf.text = text;
		tf.setTextFormat( format );
	}
	
}