package pug.render;
import nme.display.DisplayObjectContainer;
import nme.geom.Point;
import pug.model.effect.Effect;

/**
 * ...
 * @author Jarnik
 */
class RenderParticles extends Render
{
	public var particleContainer:DisplayObjectContainer;
	public var attractor:Point;

	public function new( effect:Effect ) {
		super( effect );

	}
	
}
