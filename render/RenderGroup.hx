package pug.render;
import pug.model.effect.Effect;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.IEffectGroup;
import nme.display.DisplayObject;

enum STICKER {
	ADD( d:DisplayObject );
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
	public var frameCount:Int;

	public function new( effect:Effect, group:IEffectGroup ) 
	{
		super( effect );
		stickers = new Hash<STICKER>();
		loadGroup( group );
	}
	
	private function loadGroup( group:IEffectGroup ):Void {
		this.group = group;
		cachedInstances = new Hash<Render>();
		frameCount = 0;
		for ( e in group.children )
			frameCount = Math.floor( Math.max(frameCount, e.frameStart + e.frameLength ) );
	}
	
	private function clear():Void {
		while ( this.numChildren > 0 ) {
			removeChildAt( 0 );
		}
	}

    public function addSticker( id:String, sprite:DisplayObject ):Void {
        stickers.set( id+"_ADD", ADD( sprite ) );
    }
	
	public function addStickerHideRenders( id:String ):Void {
        stickers.set( id+"_HIDE", HIDE_RENDERS );
    }
	
	override private function onSetFrame( f:Int ):Void {
		if ( player.loop )  
			render( f % frameCount, false );
		else {
			if ( f < frameCount ) {
				render( f, false );
			} else {
				player.stop();
				render( frameCount - 1, false );
			}
		}
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
		super.render( frame, applyTransforms );
        clear();
		
		frame = effect.gizmoAttributes.params[ 0 ].getValues( frame )[ 0 ];
		
		frame = frame % frameCount;
		
		var r:Render;
        var e:Effect;
        var f:Int;
		for ( i in 0...group.children.length ) {
            e = group.children[ i ];
			if ( !isVisible( e, frame ) )
				continue;
			r = cachedInstances.get( e.id );
            if ( r == null ) {
                r = Render.create( e );
                cachedInstances.set( e.id, r );
            }
			addChild( r );
            f = frame - group.children[ i ].frameStart;
			if ( r.renderUpdatesEnabled )
				r.render( f );
		}
		
		var s:DisplayObject;
		for ( k in stickers.keys() ) {
			r = fetch( k.split( "_" )[0] );
			if ( r != null ) {
				switch ( stickers.get( k ) ) {
					case ADD( d ):
						if ( !r.contains( d ) )
							r.addChild( d );
					case HIDE_RENDERS:
						/*
						for ( i in 0...r.numChildren )
							if ( Std.is( r.getChildAt( i ), Render ) )
								r.getChildAt( i ).visible = false;*/
						if ( Std.is( r, RenderImage ) )
							cast( r, RenderImage ).bitmap.visible = false;
				}
			}
		}
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
		if ( frame >= e.frameStart && frame < e.frameStart + e.frameLength )
			return true;
		return false;
	}
}
