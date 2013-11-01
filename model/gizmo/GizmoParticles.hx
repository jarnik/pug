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
	public var paramFadeout:Param;
	public var paramCount:Param; // how many particles
	public var paramSize:Param;
	public var paramLife:Param;
	public var paramVelocityX:Param;
	public var paramVelocityY:Param;
	public var paramCycle:Param; // how often should I release new particle, 0 means all at once
	public var paramAcceleration:Param;

	public function new() 
	{
		super(
			"Particles",
			[
				paramTemplate = new Param( "Template",[ new ValueString(), new ValueString() ] ),
				paramCount = new Param( "Count",[ new ValueFloat() ] ),
				paramFrames = new Param( "Frames",[ new ValueFloat() ] ),
				paramFadeout = new Param( "Fadeout",[ new ValueFloat() ] ),
				paramSize = new Param( "Size",[ new ValueFloat( 1 ), new ValueFloat( 1 ) ] ),
				paramLife = new Param( "Life",[ new ValueFloat( 1 ) ] ),			
				paramVelocityX = new Param( "VelocityX",[ new ValueFloat(), new ValueFloat() ] ),
				paramVelocityY = new Param( "VelocityY", [ new ValueFloat(), new ValueFloat() ] ),
				paramCycle = new Param( "Cycle",[ new ValueFloat( 0 ), new ValueFloat( 0 ) ] ),
				paramAcceleration = new Param( "Acceleration",[ new ValueFloat( 0 ), new ValueFloat( 0 ) ] )
			]
		);
	}
	
}
