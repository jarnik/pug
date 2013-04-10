package pug.model.gizmo;

import nme.geom.Rectangle;

import pug.model.param.Param;
import pug.model.value.ValueFloat;


/**
 * ...
 * @author Jarnik
 */
class GizmoCanvas extends Gizmo
{

	public function new() 
	{
		super(
			"Canvas",
			[
				new Param( "Position", [ new ValueFloat(), new ValueFloat() ] ),
				new Param( "Size",[ new ValueFloat(), new ValueFloat() ] )
			]
		);
	}
	
	public function setCanvasParams( r:Rectangle ):Void {
		cast( params[ 0 ].values[ 0 ], ValueFloat ).setValue( r.top );
		cast( params[ 0 ].values[ 1 ], ValueFloat ).setValue( r.left );
		cast( params[ 1 ].values[ 0 ], ValueFloat ).setValue( r.width );
		cast( params[ 1 ].values[ 1 ], ValueFloat ).setValue( r.height );
	}
	
}
