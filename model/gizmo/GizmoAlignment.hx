package pug.model.gizmo;

import pug.model.value.ValueAlignment;
import pug.model.param.Param;

/**
 * ...
 * @author Jarnik
 */
class GizmoAlignment extends Gizmo
{

	public function new() 
	{
		super(
			"Alignment",
			[
				new Param( "Horizontal", [ new ValueAlignment() ] ),
				new Param( "Vertical",[ new ValueAlignment() ] )
			]
		);
	}
	
}
