package pug.render;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.IEffectGroup;
import pug.model.symbol.SymbolLayer;
import pug.model.symbol.SymbolLayerState;

typedef CACHED_STATE = {
	cachedInstances:Hash<Render>,
	group:IEffectGroup,
	frameCount:Int
}

/**
 * ...
 * @author Jarnik
 */
class RenderGroupStates extends RenderGroup
{
	private var cachedStates:Hash<CACHED_STATE>;
	public var currentState:String;

	public function new( e:EffectSymbolLayer ) {
		var stateName:String = cast( e.symbol, SymbolLayer ).getFirstStateName();
		var state:SymbolLayerState = cast( e.symbol, SymbolLayer ).states.get( stateName );
		super( e, state );
		cachedStates = new Hash<CACHED_STATE>();
		currentState = stateName;
	}
	
	public function switchState( newState:String ):Void {
		cachedStates.set( currentState, { 
			cachedInstances: this.cachedInstances,
			group: this.group,
			frameCount: this.frameCount
		} );
		
		var cached:CACHED_STATE = cachedStates.get( newState );
		if ( cached != null ) {
			cachedInstances = cached.cachedInstances;
			group = cached.group;
			frameCount = cached.frameCount;
			currentState = newState;
		} else {
			var state:SymbolLayerState = cast( cast( effect, EffectSymbolLayer ).symbol, SymbolLayer ).states.get( newState );
			if ( state != null ) {
				currentState = newState;
				loadGroup( state );
			}
		}
	}
	
	override public function render( frame:Int, applyTransforms:Bool = true ):Void {
		var state:String = cast( effect, EffectSymbolLayer ).gizmoAttributes.params[ 3 ].getValues( frame )[ 0 ];
		if ( currentState != state )
			switchState( state );
		super.render( frame, applyTransforms );
	}
	
}