package pug.render;
import pug.model.effect.Effect;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.IEffectGroup;
import nme.display.DisplayObject;

/**
 * ...
 * @author Jarnik
 */
class RenderGroup extends Render
{
    public var cachedInstances:Hash<Render>;
    public var stickers:Hash<DisplayObject>;
	public var group:IEffectGroup;
	private var frameCount:Int;

	public function new( effect:Effect, group:IEffectGroup ) 
	{
		super( effect );
		stickers = new Hash<DisplayObject>();
		loadGroup( group );
	}
	
	private function loadGroup( group:IEffectGroup ):Void {
		this.group = group;
		cachedInstances = new Hash<Render>();
		for ( e in group.children )
			frameCount = Math.floor( Math.max(frameCount, e.frameStart + e.frameLength ) );
	}
	
	private function clear():Void {
		while ( this.numChildren > 0 ) {
			removeChildAt( 0 );
		}
	}

    public function addSticker( id:String, sprite:DisplayObject ):Void {
        stickers.set( id, sprite );
    }
	
	override private function onSetFrame( f:Int ):Void {
		if ( player.loop )  
			render( f % frameCount );
		else {
			if ( f < frameCount ) {
				render( f );
			} else {
				player.stop();
				render( frameCount - 1 );
			}
		}
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
		super.render( frame, applyTransforms );
        clear();
		
		frame = effect.gizmoAttributes.params[ 0 ].getValues( frame )[ 0 ];
		
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
			r.render( f );
		}
		
		var s:DisplayObject;
		for ( k in stickers.keys() ) {
			r = cachedInstances.get( k );
			s = stickers.get( k );
			if ( r != null && !r.contains( s ) )
				r.addChild( s );
		}
	}
	
	private function isVisible( e:Effect, frame:Int ):Bool { 
		if ( frame >= e.frameStart && frame < e.frameStart + e.frameLength )
			return true;
		return false;
	}
}
