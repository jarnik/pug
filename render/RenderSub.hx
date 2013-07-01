package pug.render;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Rectangle;
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
	private var cached_path:String;
	private var size:Rectangle;

	public function new( effect:Effect, sub:ISymbolSub ) {
		super( effect );
		this.sub = sub;
		
		updateSub();
	}
	
	private function updateSub():Void {
		if ( (sub.source + "_" + sub.path) == cached_path)
			return;
		
		if ( s != null )
			removeChild( s );
		cached_path = sub.source + "_" + sub.path;
		
		size = new Rectangle( 0, 0, 0, 0 );
		var symbol:Symbol = Library.lib.get( sub.source );
		if ( symbol != null ) {
			var asset:SUBASSET = symbol.fetchSymbolSub( sub.path );
			if ( asset != null ) {
				switch ( asset ) {
					case SubAssetBitmapData( bmd ):
						s = new Bitmap( bmd );
						size = new Rectangle( 0, 0, bmd.width, bmd.height );
					case SubAssetDisplayNode( n ):
						s = RenderShape.renderDisplayNode( n );
						s.x = 0;
						s.y = 0;
						size = n.fixedSize.clone();
						if ( effect.cachedBitmap ) {
							if ( effect.cachedBitmapData == null ) {
								effect.cachedBitmapData = new BitmapData( Std.int( size.width ), Std.int( size.height ), true, 0x00000000 );
								effect.cachedBitmapData.draw( s );
							}
							s = new Bitmap( effect.cachedBitmapData );
							size = new Rectangle( 0, 0, effect.cachedBitmapData.width, effect.cachedBitmapData.height );
						}
				}
				if ( s != null ) {
					addChild( s );
				}
			}
		}
	}
	
	public override function render( frame:Int, applyTransforms:Bool = true ):Void {
		super.render( frame, applyTransforms );
		updateSub();
		if ( s != null ) {
			updatePivot();
			s.x = - pivot.x;
			s.y = - pivot.y;
		}		
	}
	
	public override function getFixedSize():Rectangle {
		return size;
	}
	
}