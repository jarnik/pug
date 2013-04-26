package pug.model.effect;

import pug.model.gizmo.GizmoText;
import pug.model.Library;

class EffectText extends Effect
{
    public var gizmoText:GizmoText;

	public function new () 
	{
		super( [] );
		gizmos.push( gizmoText = new GizmoText() );
	}

	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
        export.xml.nodeName = "text";
		return export;
	}
}
