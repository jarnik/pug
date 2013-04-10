package pug.model.gizmo;
import pug.model.param.Param;
import pug.model.value.ValueAngle;
import pug.model.value.ValueFloat;
import pug.model.value.ValueFrame;
import pug.model.value.ValueScale;
import pug.model.value.ValueColor;

/**
 * ...
 * @author Jarnik
 */
class GizmoAttributes extends Gizmo
{
	public var paramFrame:Param;
	public var paramAlpha:Param;
	public var paramTintColor:Param;

	public function new() 
	{
		super(
			"Attributes",
			[
				paramFrame = new Param( "Frame",[ new ValueFrame() ] ),
				paramAlpha = new Param( "Alpha",[ new ValueFloat( 1 ) ] ),
				paramTintColor = new Param( "Tint Color",[ new ValueColor() ] )
			]
		);
	}
	
}
