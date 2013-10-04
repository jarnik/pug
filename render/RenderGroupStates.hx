package pug.render;
import nme.geom.Point;
import nme.geom.Rectangle;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.IEffectGroup;
import pug.model.symbol.SymbolLayer;
import pug.model.symbol.SymbolLayerState;

typedef CACHED_STATE = {
	cachedInstances:Map<String,Render>,
	group:IEffectGroup
}

/**
 * ...
 * @author Jarnik
 */
class RenderGroupStates extends RenderGroup
{
	private var cachedStates:Map<String,CACHED_STATE>;
	public var currentState:String;

	public function new( e:EffectSymbolLayer ) {
		var stateName:String = cast( e.symbol, SymbolLayer ).getFirstStateName();
		var state:SymbolLayerState = cast( e.symbol, SymbolLayer ).states.get( stateName );
		super( e, state );
		cachedStates = new Map<String,CACHED_STATE>();
		currentState = stateName;
	}
	
	public function switchState( newState:String, immediateRender:Bool = false ):Void {
		cachedStates.set( currentState, { 
			cachedInstances: this.cachedInstances,
			group: this.group
		} );
		
		var cached:CACHED_STATE = cachedStates.get( newState );
		if ( cached != null ) {
			cachedInstances = cached.cachedInstances;
			group = cached.group;
			frameCount = group.groupFrames;
			currentState = newState;
		} else {
			var state:SymbolLayerState = cast( cast( effect, EffectSymbolLayer ).symbol, SymbolLayer ).states.get( newState );
			if ( state != null ) {
				currentState = newState;
				loadGroup( state );
			}
		}
		if ( immediateRender )
			render( 0, false );
	}
	
	override public function play( loop:Bool = false, fps:Float = 0, state:String = null, onFinishedCallback:Dynamic = null ):Void {
		if ( state != null && currentState != state )
			switchState( state );
		super.play( loop, fps, state, onFinishedCallback );
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
		var state:String = cast( effect, EffectSymbolLayer ).paramState.getValues( frame )[ 0 ];
		if ( currentState != state && applyTransforms )
			switchState( state );
		frameCount = group.groupFrames;
		super.render( frame, applyTransforms );
	}
	
	public override function getFixedSize():Rectangle {
		return cast( effect, EffectSymbolLayer ).symbol.size;
	}
}
