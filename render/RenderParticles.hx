package pug.render;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Point;
import nme.geom.Rectangle;
import pug.model.Library;
import pug.model.effect.Effect;
import pug.model.symbol.Symbol;

/**
 * ...
 * @author Jarnik
 */
class RenderParticles extends Render
{
	public var particleContainer:DisplayObjectContainer;
	public var attractor:Point;

    private var particles:Array<Particle>;
    private var timer:Float;
    private var emitTimer:Float;
    private var next:Int;
    private var life:Float;
    private var range:Rectangle;

	public function new( effect:Effect ) {
		super( effect );
        
        particleContainer = this;

        var particleCount:Int = 5;
        particles = [];
        var s:Symbol = Library.lib.get("marker");        
        var r:Render;
        var p:Particle;
        for ( i in 0...particleCount ) {
            r = Render.renderSymbol( s );
            particleContainer.addChild( r );
            p = new Particle();
            p.skin = r;
            r.visible = false;
            particles.push( p );
        }
        next = 0;
        life = 4;
        range = new Rectangle(0,0,30,30);

        timer = life;
        emitTimer = 0;
        for ( i in 0...particles.length )
            emit();
	}

    override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        super.render( frame, applyTransforms );
        updateEmitter();
    }

    private function updateEmitter():Void {
        var elapsed:Float = 1;
        var p:Particle;
        if ( timer >= 0 || emitTimer > 0 ) {
            timer -= elapsed;

            if ( timer <= 0 && emitTimer > 0 ) {
                timer = emitTimer;
                emit();
            }

            for ( i in 0...particles.length ) {
                p = particles[i];
                /*
                if ( target != null ) {
                    var ratio:Float = Math.sqrt(timer/life);
                    p.x = p.x * (ratio) + target.x * (1 - ratio);
                    p.y = p.y * (ratio) + target.y * (1 - ratio);
                }*/
                p.update( elapsed );

            }
        }
    }

    private function emit():Void {
        var p:Particle;
        var a:Float;
        var l:Float = 3;//speed;
        a = Math.random()*Math.PI*2;
        p = particles[ next ];
        p.velocity.x = Math.sin(a)*l;
        p.velocity.y = -Math.cos(a)*l;
        p.skin.x = range.left + range.width*Math.random();
        p.skin.y = range.top + range.height*Math.random();
        p.skin.visible = true;
        p.emit( life );
        next++;
        if ( next >= particles.length )
            next = 0;
        visible = true;
    }
	
}

class Particle
{
    public var velocity:Point;
    private var life:Float;
    public var skin:DisplayObject;

    public function new() 
    {
        velocity = new Point();
    }

    public function emit( life:Float ):Void {
        this.life = life;
        skin.alpha = 1;
        skin.visible = true;
    }

    public function update( elapsed:Float ):Void {
        if ( life >= 0 ) {
            if ( life < 0.5 )
                skin.alpha = life / 0.5;
            life -= elapsed;
        } else
            skin.visible = false;
        skin.x += velocity.x * elapsed;
        skin.y += velocity.y * elapsed;
    }

}
