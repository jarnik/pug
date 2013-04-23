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
    private var states:Hash<Array<ParticleState>>;
    private var range:Rectangle;

	public function new( effect:Effect ) {
		super( effect );
        
        particleContainer = this;
        init();
	}

    private function init():Void {
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
        range = new Rectangle(0,0,30,30);

        states = new Hash<Array<ParticleState>>();
        computeState( 0 );
    }

    override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        super.render( frame, applyTransforms );

        if ( !states.exists( Std.string( frame ) ) ) {
            computeState( frame );
        }
        var state:Array<ParticleState> = states.get( Std.string( frame ) );

        for ( i in 0...state.length ) {
            particles[ i ].apply( state[ i ] );
        }
    }

    private function computeState( frame:Int ):Void {        
        var state:Array<ParticleState> = [];

        var s:ParticleState;
        var p:Particle;
        var a:Float;
        var l:Float = 3;//speed;                                                        
        var firstState:Array<ParticleState> = null;
        if ( frame != 0 )
            firstState = states.get( "0" );

        for ( i in 0...particles.length ) {
            s = {
                position: new Point(),
                velocity: new Point(),
                visible: false,
                life: 0
            }
            p = particles[ i ];

            if ( frame == 0 ) {
                a = Math.random()*Math.PI*2;
                s.velocity.x = Math.sin(a)*l;
                s.velocity.y = -Math.cos(a)*l;
                s.position.x = range.left + range.width*Math.random();
                s.position.y = range.top + range.height*Math.random();           
            } else {
                s.position.x =  firstState[ i ].position.x + firstState[ i ].velocity.x * frame;
                s.position.y =  firstState[ i ].position.y + firstState[ i ].velocity.y * frame;
                s.velocity.x =  firstState[ i ].velocity.x;
                s.velocity.y =  firstState[ i ].velocity.y;
            }

            s.visible = true;
            state.push( s );
        }

        states.set( Std.string( frame ), state );
    }
	
}

typedef ParticleState = {
    var position:Point;
    var velocity:Point;
    var visible:Bool;
    var life:Float;
}

class Particle
{
    public var skin:DisplayObject;

    public function new() 
    {
    }
    
    public function apply( state:ParticleState ) {
        skin.x = state.position.x;
        skin.y = state.position.y;
        skin.visible = state.visible;
    }

}
