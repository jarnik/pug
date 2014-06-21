package pug.render;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import pug.model.effect.Effect;
import pug.model.effect.EffectSub;
import pug.model.symbol.ISymbolSub;
import pug.model.symbol.Symbol;
import pug.model.Library;
import nme.display.PixelSnapping;

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
	private var cachedBitmapOffset:Point;

	public function new( effect:Effect, sub:ISymbolSub ) {
		super( effect );
		this.sub = sub;
		cachedBitmapOffset = new Point();
		
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
					#if pug_svg
					case SubAssetDisplayNode( n ):
						s = RenderShape.renderDisplayNode( n );
						s.x = 0;
						s.y = 0;
						size = n.fixedSize.clone();
						if ( effect.cachedBitmap )
							forceCachedBitmap();
					#end
				}
				if ( s != null ) {
					addChild( s );
				}
			}
		}
	}
	
	public override function forceCachedBitmap():Void {
		if ( !Std.is( s, Sprite ) )
			return;
		if ( contains( s ) )
			removeChild( s );
		var margin:Float = 10;	
		
		if ( effect.cachedBitmapData == null ) {
			var m:Matrix = new Matrix();
			m.translate( margin, margin );
			
			effect.cachedBitmapData = new BitmapData( Std.int( size.width + margin * 2 ), Std.int( size.height + margin * 2 ), true, 0x00000000 );
			effect.cachedBitmapData.draw( s, m );
		}
		s = new Bitmap( effect.cachedBitmapData, PixelSnapping.AUTO, true );
		size = new Rectangle( 0, 0, effect.cachedBitmapData.width, effect.cachedBitmapData.height );
		cachedBitmapOffset.x = -margin;
		cachedBitmapOffset.y = -margin;
		addChild( s );
	}
	
	public override function render( frame:Int, applyTransforms:Bool = true ):Void {
		super.render( frame, applyTransforms );
		updateSub();
		if ( s != null ) {
			updatePivot();
			s.x = - pivot.x + cachedBitmapOffset.x;
			s.y = - pivot.y + cachedBitmapOffset.y;
		}		
	}
	
	public override function getFixedSize():Rectangle {
		return size;
	}
	
}