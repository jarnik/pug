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
        var l:Float = 3;//speed;                                                        
        var firstState:Array<ParticleState> = null;
        var paramVelocityX:Array<Dynamic> = null;        
        var paramVelocityY:Array<Dynamic> = null;        
        if ( frame != 0 )
            firstState = states.get( "0" );
        else {
            paramVelocityX = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityX.getValues( 0 );
            paramVelocityY = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityY.getValues( 0 );
        }

        for ( i in 0...particles.length ) {
            s = {
                position: new Point(),
                velocity: new Point(),
                visible: false,
                life: 0
            }
            p = particles[ i ];

            if ( frame == 0 ) {
                s.velocity.x = paramVelocityX[ 0 ] + Math.random() * ( paramVelocityX[1] - paramVelocityX[0] );
                s.velocity.y = paramVelocityY[ 0 ] + Math.random() * ( paramVelocityY[1] - paramVelocityY[0] );
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
