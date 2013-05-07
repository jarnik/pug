package pug.model.gizmo;

import pug.model.value.ValueFloat;
import pug.model.value.ValueAngle;
import pug.model.value.ValueScale;
import pug.model.param.Param;

/**
 * ...
 * @author Jarnik
 */
class GizmoTransform extends Gizmo
{
	public var paramPosition:Param;
	public var paramRotation:Param;
	public var paramScale:Param;

	public function new() 
	{
		super(
			"Transform",
			[
				paramPosition = new Param( "Position",[ new ValueFloat(), new ValueFloat() ] ),
				paramRotation = new Param( "Rotation",[ new ValueAngle() ] ),
				paramScale = new Param( "Scale",[ new ValueScale(), new ValueScale() ] )
			]
		);
	}
	
	public function setPosition( frame:Int, x:Float, y:Float ):Void {
        paramPosition.setValues( frame, [ x, y ] );
	}
	
	public function setRotation( frame:Int, a:Float ):Void {
        paramRotation.setValues( frame, [ a ] );
	}
	
	public function setScale( frame:Int, x:Float, y:Float ):Void {
        paramScale.setValues( frame, [ x, y ] );
	}
	
}
