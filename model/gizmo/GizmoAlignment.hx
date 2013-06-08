package pug.model.gizmo;

import pug.model.value.ValueAlignment;
import pug.model.param.Param;
import pug.model.value.ValueBool;
import pug.model.value.ValueFloat;
import pug.model.value.ValueFrame;
import pug.model.value.ValueString;

/**
 * ...
 * @author Jarnik
 */
class GizmoAlignment extends Gizmo
{
	public var paramSwitches:Param;
	public var paramAlignment:Param;
	public var paramBorders:Param; // Left Top Right Bottom
	public var paramFixedSize:Param;

	public function new() 
	{
		super(
			"Alignment",
			[
				paramSwitches = new Param( "Switches", [ new ValueBool( false, "align" ), new ValueBool( false, "fixedSize" ) ] ),
				paramAlignment = new Param( "Alignment", [ new ValueAlignment(), new ValueAlignment() ] ),
				paramBorders = new Param( "Borders",[ new ValueFloat(), new ValueFloat(), new ValueFloat(), new ValueFloat() ] ), 
				paramFixedSize = new Param( "FixedSize",[ new ValueFloat(), new ValueFloat() ] )
			]
		);
	}
	
}
