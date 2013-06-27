package pug.render;
import nme.geom.Rectangle;
import pug.model.effect.Effect;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.IEffectGroup;
import nme.display.DisplayObject;

enum STICKER {
	ADD( d:DisplayObject );
	INFINITE;
	HIDE_RENDERS;
}

/**
 * ...
 * @author Jarnik
 */
class RenderGroup extends Render
{
    public var cachedInstances:Hash<Render>;
    public var stickers:Hash<STICKER>;
	public var group:IEffectGroup;	

	public function new( effect:Effect, group:IEffectGroup ) 
	{
		super( effect );
		stickers = new Hash<STICKER>();
		loadGroup( group );
	}
	
	private function loadGroup( group:IEffectGroup ):Void {
		this.group = group;
		cachedInstances = new Hash<Render>();
		frameCount = group.groupFrames;
	}
	
	private function clear():Void {
		while ( this.numChildren > 0 ) {
			removeChildAt( 0 );
		}
	}

    public function addSticker( id:String, sprite:DisplayObject ):Void {
        stickers.set( id+"===ADD", ADD( sprite ) );
    }
	
	public function addStickerHideRenders( id:String ):Void {
        stickers.set( id+"===HIDE", HIDE_RENDERS );
    }
	
	public function addStickerInfinite( id:String ):Void {
        stickers.set( id+"===INFINITE", INFINITE );
    }
	
	override private function onSetFrame( f:Int ):Void {
		if ( player.loop )  
			render( f % frameCount, false );
		else {
			if ( f < frameCount || infinite ) {
				render( f, false );
			} else {
				player.stop();
				render( frameCount - 1, false );
				if ( onFinishedCallback != null )
					onFinishedCallback();
			}
		}
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        clear();
		
		var innerFrame:Int = frame;
		
		if ( !infinite ) {
			innerFrame = effect.gizmoAttributes.params[ 0 ].getValues( frame )[ 0 ];
			innerFrame = innerFrame % frameCount;
		}
		
		updatePivot();		
		
		var r:Render;
        var e:Effect;
        var f:Int;
		for ( i in 0...group.children.length ) {
            e = group.children[ i ];
			if ( !isVisible( e, innerFrame ) || !e.renderable )
				continue;
			r = cachedInstances.get( e.id );
            if ( r == null ) {
                r = Render.create( e );
                cachedInstances.set( e.id, r );
            }
			addChild( r );
            f = innerFrame - e.frameStart;
			if ( r.renderUpdatesEnabled ) {
				r.render( f );
				r.x -= pivot.x;
				r.y -= pivot.y;
			}
		}
		
		var s:DisplayObject;
		for ( k in stickers.keys() ) {
			r = fetch( k.split( "===" )[0] );
			if ( r != null ) {
				switch ( stickers.get( k ) ) {
					case ADD( d ):
						if ( !r.contains( d ) )
							r.addChild( d );
					case HIDE_RENDERS:
						r.hideContents();
					case INFINITE:
						r.infinite = true;
				}
			}
		}
		
		super.render( frame, applyTransforms );
	}
	
	override public function play( loop:Bool = false, fps:Float = 0, state:String = null, onFinishedCallback:Dynamic = null ):Void {
		if ( fps == 0 )
			fps = group.fps;
		super.play( loop, fps, state, onFinishedCallback );
	}
	
	public override function align( r:Rectangle = null, frame:Int = 0 ):Void {
		super.align( r, frame );
		
		if ( alignmentSize == null )
			return;
		
        r.x = 0; r.y = 0;
        r.width = ( manualAlignRange != null ) ? r.width : alignmentSize.width;
        r.height = ( manualAlignRange != null ) ? r.height : alignmentSize.height;

		var kid:Render;
        var e:Effect;
		for ( i in 0...group.children.length ) {
            e = group.children[ i ];
			if ( !isVisible( e, frame ) || !e.renderable )
				continue;
			kid = cachedInstances.get( e.id );
			kid.align( r.clone(), frame - e.frameStart );
		}		
	}
	
	override public function hideContents():Void {
		for ( r in cachedInstances )
			r.visible = false;
	}
	
	public function fetch( id:String ):Render {
		var child:String = id.split(".")[0];
		var r:Render = cachedInstances.get( child );
		if ( r == null )
			return null;
		if ( child == id )
			return r;
		if ( Std.is( r, RenderGroup ) )
			return cast( r, RenderGroup ).fetch( id.substr( child.length+1 ) );
		return null;
	}
	
	private function isVisible( e:Effect, frame:Int ):Bool { 
		var isInfinite:Bool = stickers.exists(e.id+"===INFINITE");
		if ( 
			( frame >= e.frameStart && frame < e.frameStart + e.frameLength ) // within range
			|| ( isInfinite && frame >= frameCount - 1 )  // infinite and at the end of the parent
		)
			return true;
		return false;
	}
}
