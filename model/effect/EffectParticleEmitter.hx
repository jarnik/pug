package pug.model.effect;
import nme.geom.Point;
import pug.model.symbol.Symbol;

/**
 * ...
 * @author Jarnik
 */
class EffectParticleEmitter extends Effect
{
	public var gizmoParticles:GizmoParticles;

	public function new() 
	{
		super();
		gizmos.push( gizmoParticles = new GizmoParticles() );
	}
	
}