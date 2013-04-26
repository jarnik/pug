package pug.render;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Point;
import nme.geom.Rectangle;
import pug.model.Library;
import pug.model.effect.Effect;
import pug.model.symbol.Symbol;
import pug.model.effect.EffectParticleEmitter;

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
    private var hash:String;

	public function new( effect:Effect ) {
		super( effect );
        
        particleContainer = this;
	}

    private function init():Void {

        hash = cast( effect, EffectParticleEmitter ).hash;

        if ( particles != null )
            for ( p in particles )
                particleContainer.removeChild( p.skin );            

        particles = [];
		states = null;

        var template:Array<Dynamic> = cast( effect, EffectParticleEmitter ).gizmoParticles.paramTemplate.getValues( 0 );
        var symbolName:String = template[ 0 ];
        var stateName:String = template[ 1 ];
        
        var s:Symbol = Library.lib.get( symbolName );        
        if ( s == null )
            return;
        
        var paramSize:Array<Dynamic> = cast( effect, EffectParticleEmitter ).gizmoParticles.paramSize.getValues( 0 );        
		range = new Rectangle();
        range.width = paramSize[ 0 ];
        range.height = paramSize[ 1 ];
        range.x = -range.width / 2;
        range.y = -range.height / 2;
        var particleCount:Int = cast( effect, EffectParticleEmitter ).gizmoParticles.paramCount.getValues( 0 )[ 0 ];
        var r:Render;
        var p:Particle;
        for ( i in 0...particleCount ) {
            r = Render.renderSymbol( s );
            particleContainer.addChild( r );
            p = new Particle();
            p.skin = r;
            if ( Std.is( r, RenderGroupStates ) )
                cast( r, RenderGroupStates ).switchState( stateName );

            r.visible = false;
            particles.push( p );
        }

        states = new Hash<Array<ParticleState>>();
        computeState( 0 );
    }

    override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        super.render( frame, applyTransforms );

        if ( hash != cast( effect, EffectParticleEmitter ).hash )
            init();
			
		if ( states == null )
			return;

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
        var firstState:Array<ParticleState> = null;
        var paramVelocityX:Array<Dynamic> = null;        
        var paramVelocityY:Array<Dynamic> = null;        
        var paramFadeout:Float = 0;
        var paramLife:Float = 1;
		var randomFrames:Bool = false;
        if ( frame != 0 ) {
            firstState = states.get( "0" );
			paramFadeout = cast( effect, EffectParticleEmitter ).gizmoParticles.paramFadeout.getValues( 0 )[ 0 ];
		} else {
            paramVelocityX = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityX.getValues( 0 );
            paramVelocityY = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityY.getValues( 0 );
			paramLife = cast( effect, EffectParticleEmitter ).gizmoParticles.paramLife.getValues( 0 )[ 0 ];
        }
		randomFrames = (cast( effect, EffectParticleEmitter ).gizmoParticles.paramFrames.getValues( 0 )[0] == 1);

        for ( i in 0...particles.length ) {
            s = {
                position: new Point(),
                velocity: new Point(),
                visible: false,
                alpha: 1,
                life: 0,
                age: 0,
                frame: 0
            }
            p = particles[ i ];

            if ( frame == 0 ) {
                s.velocity.x = paramVelocityX[ 0 ] + Math.random() * ( paramVelocityX[1] - paramVelocityX[0] );
                s.velocity.y = paramVelocityY[ 0 ] + Math.random() * ( paramVelocityY[1] - paramVelocityY[0] );
                s.position.x = range.left + range.width*Math.random();
                s.position.y = range.top + range.height * Math.random();
				if ( randomFrames && Std.is( p.skin, Render ) )
					s.frame = Math.floor( Math.random() * cast( p.skin, Render ).getFrameCount() );
				s.life = paramLife;
            } else {
                s.position.x =  firstState[ i ].position.x + firstState[ i ].velocity.x * frame;
                s.position.y =  firstState[ i ].position.y + firstState[ i ].velocity.y * frame;
                s.velocity.x =  firstState[ i ].velocity.x;
                s.velocity.y =  firstState[ i ].velocity.y;
				if ( !randomFrames )
					s.frame = frame;
				else
					s.frame = firstState[ i ].frame;
				s.age = frame;
				if ( s.age > firstState[ i ].life - paramFadeout )
					s.alpha = (firstState[ i ].life - s.age) / paramFadeout;
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
    var alpha:Float;
    var life:Float;
    var age:Float;
    var frame:Int;
}

class Particle
{
    public var skin:DisplayObject;
	private var lastFrame:Int;

    public function new() {
		lastFrame = -1;
    }
    
    public function apply( state:ParticleState ) {
        skin.x = state.position.x;
        skin.y = state.position.y;
        skin.visible = state.visible;
        skin.alpha = state.alpha;
		if ( Std.is( skin, Render ) && lastFrame != state.frame ) {
			lastFrame = state.frame;
			cast( skin, Render ).render( state.frame, false );
		}
    }

}
