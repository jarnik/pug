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
	// define a range to create new particles
	public var rangeOverride(get,set):Rectangle;
	private var _rangeOverride:Rectangle;
	// particle states are not cached
	public var realtimeMode:Bool;

    private var particles:Array<Particle>;
    private var states:Map<String,ParticleSystemState>;
    private var hash:String;
	private var firstCachedFrame:Int;
	private var lastBuiltFrame:Int;

	public function new( effect:Effect ) {
		super( effect );
        
		realtimeMode = false;
        particleContainer = this;
	}

    private function init():Void {

        hash = cast( effect, EffectParticleEmitter ).hash;
		lastBuiltFrame = -1;
		firstCachedFrame = 0;

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

        states = new Map<String,ParticleSystemState>();
        computeState( 0 );
		lastBuiltFrame = 0;
    }
	
	public function rehash():Void {
		hash = "";
	}

    override public function render( frame:Int, applyTransforms:Bool = true ):Void {
        super.render( frame, applyTransforms );

        if ( hash != cast( effect, EffectParticleEmitter ).hash )
            init();
			
		if ( states == null )
			return;

		var state:ParticleSystemState = null;
		if ( lastBuiltFrame < frame ) {
			for ( f in (lastBuiltFrame+1)...frame+1 )
				computeState( f );
			lastBuiltFrame = frame;
		}
		state = states.get( Std.string( frame ) );
		if ( realtimeMode ) {
			if ( lastBuiltFrame > 0 ) {
				for ( f in (firstCachedFrame)...lastBuiltFrame )
					states.remove( Std.string( f ) );
				firstCachedFrame = lastBuiltFrame - 1;
			}
		}

		if ( state != null ) 
			for ( i in 0...state.p.length ) {
				particles[ i ].apply( state.p[ i ] );
			}
    }

    private function computeState( frame:Int ):ParticleSystemState {        
        var state:ParticleSystemState = { p: [], emitTimer:0, nextIndex:0 };

        var prevState:ParticleSystemState = states.get( Std.string( frame - 1 ) );
		
        var paramVelocityX:Array<Dynamic> = null;        
        var paramVelocityY:Array<Dynamic> = null;        
        var paramAccel:Array<Dynamic> = null;        
        var paramFadeout:Float = 0;
        var paramLife:Float = 1;
        var paramCycle:Array<Dynamic> = null;
		var paramSize:Array<Dynamic> = null;
		var randomFrames:Bool = false;
		var range:Rectangle = null;
		
		paramFadeout = cast( effect, EffectParticleEmitter ).gizmoParticles.paramFadeout.getValues( 0 )[ 0 ];
		randomFrames = (cast( effect, EffectParticleEmitter ).gizmoParticles.paramFrames.getValues( 0 )[0] == 1);
		paramCycle = cast( effect, EffectParticleEmitter ).gizmoParticles.paramCycle.getValues( 0 );
		
		var emitNewParticles:Int = 0;
		var cycle:Float = paramCycle[0];
		var cycleVariance:Float = paramCycle[1];
		if ( frame == 0 ) {
			if ( cycle == 0 ) {
				emitNewParticles = particles.length;
				state.emitTimer = Math.POSITIVE_INFINITY;
			} else {
				emitNewParticles = Math.floor( Math.max( 1, 1 / cycle ) );
				state.emitTimer = 0;
			}
		} else {
			state.emitTimer = prevState.emitTimer;
			state.nextIndex = prevState.nextIndex;
			if ( state.emitTimer != Math.POSITIVE_INFINITY ) {
				var d:Float = (cast( frame, Float) - state.emitTimer);
				emitNewParticles =  Math.floor( d / cycle );
				state.emitTimer += emitNewParticles * cycle + Math.random() * cycleVariance;
			}
		}
		
		if ( emitNewParticles > 0 ) {
			paramVelocityX = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityX.getValues( frame );
            paramVelocityY = cast( effect, EffectParticleEmitter ).gizmoParticles.paramVelocityY.getValues( frame );
			paramLife = cast( effect, EffectParticleEmitter ).gizmoParticles.paramLife.getValues( frame )[ 0 ];
			paramAccel = cast( effect, EffectParticleEmitter ).gizmoParticles.paramAcceleration.getValues( frame );
			
			paramSize = cast( effect, EffectParticleEmitter ).gizmoParticles.paramSize.getValues( frame );      
			if ( rangeOverride == null ) {
				range = new Rectangle();
				range.width = paramSize[ 0 ];
				range.height = paramSize[ 1 ];
				range.x = -range.width / 2;
				range.y = -range.height / 2;
			} else {
				range = rangeOverride;
			}
		}
		
		var o:ParticleState;
		var s:ParticleState;
		var p:Particle;
		for ( i in 0...particles.length ) {
			if ( isWithinEmitTimeFrame( i, particles.length, state.nextIndex, emitNewParticles ) ) { 
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
		return state;
    }
	
	private function isWithinEmitTimeFrame( i:Int, cycle:Int, timeFrameStart:Int, timeFrameLength:Int ):Bool {
		if ( timeFrameStart + timeFrameLength > cycle ) {
			return ( i >= timeFrameStart || i < (timeFrameStart + timeFrameLength) % cycle );
		} else {
			return ( i >= timeFrameStart && i < timeFrameStart + timeFrameLength );
		}
		return false;
	}
	
	public function get_rangeOverride():Rectangle {
		return _rangeOverride;
	}
	
	public function set_rangeOverride(r:Rectangle):Rectangle {
		_rangeOverride = r;
		return r;
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
