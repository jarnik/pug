package pug.model.effect;
import nme.geom.Point;
import pug.model.symbol.Symbol;
import pug.model.gizmo.GizmoParticles;
import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class EffectParticleEmitter extends Effect
{
	public var gizmoParticles:GizmoParticles;
    public var hash:String;

	public function new() 
	{
		super( [] );
		gizmos.push( gizmoParticles = new GizmoParticles() );
        changed();
	}

    public function changed():Void {
        hash = Std.string( Math.random() * 100000 );
    }
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
        export.xml.nodeName = "particles";
		return export;
	}
	
	override public function clone():Effect {
		return new EffectParticleEmitter();
	}
}
