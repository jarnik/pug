package pug.model.gizmo;

import pug.model.value.ValueString;
import pug.model.param.Param;

/**
 * ...
 * @author Jarnik
 */
class GizmoState extends Gizmo
{

	public function new() {
		super(
			"State",
			[
				new Param( "State", [ new ValueString( "main" ) ] )
			]
		);
	}
	
}
