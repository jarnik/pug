package pug.model.effect;
import nme.geom.Point;
import pug.model.symbol.Symbol;
import pug.model.gizmo.GizmoParticles;

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
	
}
