package pug.render;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.display.Sprite;
import pug.model.effect.Effect;
import pug.model.effect.EffectSub;
import pug.model.symbol.ISymbolSub;
import pug.model.symbol.Symbol;
import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class RenderSub extends Render
{
	private var sub:ISymbolSub;
	private var s:DisplayObject;

	public function new( effect:Effect, sub:ISymbolSub ) {
		super( effect );
		this.sub = sub;
		
		var symbol:Symbol = Library.lib.get( sub.source );
		if ( symbol != null ) {
			var asset:SUBASSET = symbol.fetchSymbolSub( sub.path );
			if ( asset != null ) {
				switch ( asset ) {
					case SubAssetBitmapData( bmd ):
						s = new Bitmap( bmd );
					case SubAssetDisplayNode( n ):
						s = RenderShape.renderDisplayNode( n );
				}
				if ( s != null ) {
					addChild( s );
				}
			}
		}
	}
	
}