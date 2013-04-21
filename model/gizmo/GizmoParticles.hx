package pug.model.gizmo;
import pug.model.param.Param;
import pug.model.value.ValueString;
import pug.model.value.ValueFrame;
import pug.model.value.ValueFloat;

/**
 * ...
 * @author Jarnik
 */
class GizmoParticles extends Gizmo
{
	public var paramTemplate:Param; // symbol name + state name
	public var paramFrames:Param; // 0 means particle frame is set randomly at start
	public var paramSize:Param;
	public var paramLife:Param;
	public var paramVelocityX:Param;
	public var paramVelocityY:Param;

	public function new() 
	{
		super(
			"Particles",
			[
				paramTemplate = new Param( "Template",[ new ValueString(), new ValueString() ] ),
				paramFrames = new Param( "Frames",[ new ValueFrame() ] ),
				paramSize = new Param( "Size",[ new ValueFloat( 1 ), new ValueFloat( 1 ) ] ),
				paramLife = new Param( "Life",[ new ValueFloat( 1 ) ] ),
				paramVelocityX = new Param( "VelocityX",[ new ValueFloat(), new ValueFloat() ] ),
				paramVelocityY = new Param( "VelocityY",[ new ValueFloat(), new ValueFloat() ] )
			]
		);
	}
	
}