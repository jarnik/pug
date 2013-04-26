package pug.model.gizmo;
import pug.model.param.Param;
import pug.model.value.ValueColor;
import pug.model.value.ValueString;
import pug.model.value.ValueFrame;
import pug.model.value.ValueFloat;

/**
 * ...
 * @author Jarnik
 */
class GizmoText extends Gizmo
{
	public var paramSize:Param;
	public var paramFont:Param;
	public var paramAlignment:Param;
	public var paramColor:Param;
	public var paramText:Param;

	public function new() 
	{
		super(
			"Text",
			[
				paramSize = new Param( "Size",[ new ValueFloat( 50 ), new ValueFloat( 20 ) ] ),
				paramFont = new Param( "Font",[ new ValueString(), new ValueFloat( 14 ) ] ),
				paramAlignment = new Param( "Alignment",[ new ValueString() ] ),
				paramColor = new Param( "Color",[ new ValueColor() ] ),
				paramText = new Param( "Text",[ new ValueString() ] )
			]
		);
	}
	
}
