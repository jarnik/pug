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
    private var states:Hash<ParticleSystemState>;
    private var range:Rectangle;
    private var hash:String;
	private var lastBuiltFrame:Int;

	public function new( effect:Effect ) {
		super( effect );
        
        particleContainer = this;
	}

    private function init():Void {

        hash = cast( effect, EffectParticleEmitter ).hash;
		lastBuiltFrame = -1;

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

        states = new Hash<ParticleSystemState>();
        computeState( 0 );
		lastBuiltFrame = 0;
    }

    override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        super.render( frame, applyTransforms );

        if ( hash != cast( effect, EffectParticleEmitter ).hash )
            init();
			
		if ( states == null )
			return;

        if ( lastBuiltFrame < frame ) {
			for ( f in (lastBuiltFrame+1)...frame+1 )
				computeState( f );
			lastBuiltFrame = frame;
        }
        var state:ParticleSystemState = states.get( Std.string( frame ) );

        for ( i in 0...state.p.length ) {
            particles[ i ].apply( state.p[ i ] );
        }
    }

    private function computeState( frame:Int ):Void {        
        var state:ParticleSystemState = { p: [], emitTimer:0, nextIndex:0 };

        var prevState:ParticleSystemState = states.get( Std.string( frame - 1 ) );
		
        var paramVelocityX:Array<Dynamic> = null;        
        var paramVelocityY:Array<Dynamic> = null;        
        var paramAccel:Array<Dynamic> = null;        
        var paramFadeout:Float = 0;
        var paramLife:Float = 1;
        var paramCycle:Array<Dynamic> = null;
		var randomFrames:Bool = false;
		
		paramFadeout = cast( effect, EffectParticleEmitter ).gizmoParticles.paramFadeout.getValues( 0 )[ 0 ];
		randomFrames = (cast( effect, EffectParticleEmitter ).gizmoParticles.paramFrames.getValues( 0 )[0] == 1);
		paramCycle = cast( effect, EffectParticleEmitter ).gizmoParticles.paramCycle.getValues( 0 );
		
		var emitNewParticles:Int = 0;
		if ( frame == 0 ) {
			if ( paramCycle[0] == 0 ) {
				emitNewParticles = particles.length;
				state.emitTimer = Math.POSITIVE_INFINITY;
			} else {
				emitNewParticles = Math.floor( Math.max( 1, 1 / paramCycle[0] ) );
				state.emitTimer = 0;
			}
		} else {
			state.emitTimer = prevState.emitTimer;
			state.nextIndex = prevState.nextIndex;
			if ( state.emitTimer != Math.POSITIVE_INFINITY ) {
				var d:Float = (frame - state.emitTimer);
				emitNewParticles =  Math.floor( d / paramCycle[0] );
				state.emitTimer += emitNewParticles * paramCycle[0] + Math.random() * paramCycle[1];
			}
		}
		
		if ( emitNewParticles > 0 ) {
			paramVelocityX = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityX.getValues( frame );
            paramVelocityY = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityY.getValues( frame );
			paramLife = cast( effect, EffectParticleEmitter ).gizmoParticles.paramLife.getValues( frame )[ 0 ];
			paramAccel = cast( effect, EffectParticleEmitter ).gizmoParticles.paramAcceleration.getValues( frame );
		}
		
		var o:ParticleState;
		var s:ParticleState;
		var p:Particle;
		for ( i in 0...particles.length ) {
			if ( isWithinEmitRange( i, particles.length, state.nextIndex, emitNewParticles ) ) { 
				// particle is within newly emitted range
				p = particles[ i ];
				s = { position: new Point(), velocity: new Point(), acceleration: new Point( paramAccel[0], paramAccel[1] ),
					visible: true, alpha: 1, life: 0, age: 0, frame: 0 };
				s.velocity.x = paramVelocityX[ 0 ] + Math.random() * ( paramVelocityX[1] - paramVelocityX[0] );
                s.velocity.y = paramVelocityY[ 0 ] + Math.random() * ( paramVelocityY[1] - paramVelocityY[0] );
                s.position.x = range.left + range.width*Math.random();
                s.position.y = range.top + range.height * Math.random();
				if ( randomFrames && Std.is( p.skin, Render ) )
					s.frame = Math.floor( Math.random() * cast( p.skin, Render ).getFrameCount() );
				s.life = paramLife;
			} else {
				// just update the particle		
				if ( prevState == null ) {
					s = { position: new Point(), velocity: new Point(), acceleration: new Point(),
						visible: false, alpha: 1, life: 0, age: 0, frame: 0 };
				} else {
					o = prevState.p[ i ];
					s = { position: o.position.clone(), velocity: o.velocity.clone(), acceleration: o.acceleration.clone(),
						visible: o.visible, alpha: o.alpha, life: o.life, age: o.age, frame: o.frame };
					if ( s.visible ) {
						s.age++;
						if ( s.age > s.life )
							s.visible = false;
						if ( s.visible ) {
							s.velocity.x += s.acceleration.x;
							s.velocity.y += s.acceleration.y;
							s.position.x += s.velocity.x;
							s.position.y += s.velocity.y;
							if ( !randomFrames )
								s.frame++;
							if ( s.age > s.life - paramFadeout )
								s.alpha = (s.life - s.age) / paramFadeout;
						}
					}
				}				
			}
			state.p.push( s );
		}
		state.nextIndex = (state.nextIndex + emitNewParticles) % particles.length;

        states.set( Std.string( frame ), state );
    }
	
	private function isWithinEmitRange( i:Int, cycle:Int, rangeStart:Int, rangeLength:Int ):Bool {
		if ( rangeStart + rangeLength > cycle ) {
			return ( i >= rangeStart || i < (rangeStart + rangeLength) % cycle );
		} else {
			return ( i >= rangeStart && i < rangeStart + rangeLength );
		}
		return false;
	}
	
}

typedef ParticleSystemState = {
	var p:Array<ParticleState>;
	var emitTimer:Float;
	var nextIndex:Int;
}

typedef ParticleState = {
    var position:Point;
    var velocity:Point;
    var acceleration:Point;
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
