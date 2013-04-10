package pug.model.effect;

import pug.model.gizmo.GizmoState;
import pug.model.param.Param;
import pug.model.symbol.Symbol;
import pug.model.symbol.SymbolLayer;
import pug.model.value.ValueString;

/**
 * ...
 * @author Jarnik
 */
class EffectSymbolLayer extends EffectSymbol
{

	public function new( symbol:Symbol ) {
		super( symbol );
		gizmoAttributes.params.push( 
			new Param( "State", [ new ValueString( SymbolLayer.getDefaultStateName() ) ] ) 
		);
	}
	
}
