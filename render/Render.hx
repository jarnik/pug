package pug.render;
import flash.display.DisplayObject;
import flash.geom.Rectangle;
import nme.geom.Point;
import nme.Lib;
import pug.model.effect.Effect;
import pug.model.effect.EffectSymbol;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.EffectGroup;
import pug.model.effect.EffectParticleEmitter;
import pug.model.effect.EffectText;
import pug.model.effect.EffectRef;
import pug.model.effect.EffectSub;
import pug.model.effect.IEffectGroup;
import pug.model.gizmo.GizmoAlignment;
import pug.model.Library;
import pug.model.symbol.SymbolImage;
import pug.model.symbol.SymbolLayer;
import pug.model.symbol.SymbolLayerState;
import pug.model.symbol.SymbolShape;
import pug.model.symbol.SymbolSub;
import pug.model.gizmo.GizmoAttributes;
import pug.model.gizmo.GizmoTransform;
import pug.model.value.ValueFloat;
import pug.model.value.Value;
import nme.display.DisplayObjectContainer;
import nme.display.Sprite;
import pug.model.symbol.Symbol;
import pug.model.value.ValueAngle;
import pug.model.value.ValueScale;
import pug.model.value.ValueString;
import nme.events.MouseEvent;

/**
 * ...
 * @author Jarnik
 */
class Render extends Sprite
{
	public static function renderSymbol( s:Symbol ):Render {
		var r:Render = null;
		var e:Render;
		var f:Effect;
        if ( Std.is( s, SymbolLayer ) ) {
			r = new RenderGroupStates( new EffectSymbolLayer( s ) );
			r.effect.gizmoAttributes.params[3].values[0].setValue( cast( s, SymbolLayer ).getFirstStateName() );
        } else if ( Std.is( s, SymbolImage ) ) {
			r = new RenderImage( null, cast( s, SymbolImage ) );
		} else if ( Std.is( s, SymbolShape ) ) {
			r = new RenderShape( null, cast( s, SymbolShape ) );
		} else if ( Std.is( s, SymbolSub ) ) {
			r = new RenderSub( null, cast( s, SymbolSub ) );
		}
		
		if ( r != null ) {
			r.render( 0, false );
			return r;
		}
		return null;
	}
	
	public static function renderGroupStates( id:String, lib:Library = null, state:String = null ):RenderGroupStates {
		if ( lib == null )
			lib = Library.lib;
		var r:RenderGroupStates = cast( renderSymbol( lib.get( id ) ), RenderGroupStates );
		if ( state != null )
			r.switchState( state );
		r.render( 0, false );
		return r;
	}
	
	public static function create( e:Effect ):Render {
		if ( Std.is( e, EffectSymbolLayer ) ) {
			return new RenderGroupStates( cast( e, EffectSymbolLayer ) );
		} else if ( Std.is( e, EffectSymbol ) ) {
            if ( Std.is( cast( e, EffectSymbol ).symbol, SymbolImage ) ) {
				return new RenderImage( e, cast( cast( e, EffectSymbol ).symbol, SymbolImage ) );
            } else if ( Std.is( cast( e, EffectSymbol ).symbol, SymbolShape ) ) {
				return new RenderShape( e, cast( cast( e, EffectSymbol ).symbol, SymbolShape ) );
			} else if ( Std.is( cast( e, EffectSymbol ).symbol, SymbolSub ) ) {
				return new RenderSub( e, cast( cast( e, EffectSymbol ).symbol, SymbolSub ) );
            } else
				return null;
		} else if( Std.is( e, EffectGroup ) ) {
			return new RenderGroup( e, cast( e, EffectGroup ) );	
		} else if( Std.is( e, EffectParticleEmitter ) ) {
			return new RenderParticles( e );	
        } else if( Std.is( e, EffectText ) ) {
			return new RenderText( e );	
		} else if( Std.is( e, EffectSub ) ) {
			return new RenderSub( e, cast( e, EffectSub ) );	
        }
		return null;
	}

	private static function applyTransform( g:GizmoTransform, d:DisplayObject, frame:Int = 0 ):Void {
		var position:Array<Dynamic> = g.paramPosition.getValues( frame );
		var rot:Array<Dynamic> = g.paramRotation.getValues( frame );
		var scale:Array<Dynamic> = g.paramScale.getValues( frame );
		d.x = position[ 0 ];
		d.y = position[ 1 ];
		d.rotation = rot[ 0 ];
		d.scaleX = scale[ 0 ];
		d.scaleY = scale[ 1 ];
	}
	
	private static function applyAttributes( g:GizmoAttributes, d:DisplayObject, frame:Int = 0 ):Void {
		var alpha:Array<Dynamic> = g.paramAlpha.getValues( frame );
        d.alpha = alpha[ 0 ];
    }
		
	public var effect:Effect;
	public var player:Player;
	public var renderUpdatesEnabled:Bool;
	public var infinite:Bool;
	public var frameCount:Int;
	public var manualAlignRange:Rectangle;
	public var alignmentSize:Rectangle;
	private var onFinishedCallback:Dynamic;
	
	public function new( effect:Effect ) 
	{
		super();
		renderUpdatesEnabled = true;
		this.effect = effect;
		frameCount = 1;
		infinite = false;
		if ( effect != null )
			name = effect.id;
	}
	
	public function render( frame:Int, applyTransforms:Bool = true ):Void {
		if ( effect != null && applyTransforms ) {
			applyTransform( effect.gizmoTransform, this, frame );
			applyAttributes( effect.gizmoAttributes, this, frame );			
		}
		if ( manualAlignRange != null && effect != null )
			align( manualAlignRange, frame );
	}
	
	public function renderSubElements( frame:Int ):Void {
		var d:DisplayObject;
		if ( effect != null )
			for ( e in effect.refs ) {
				d = fetchSubElement( e.path );
				if ( d != null ) {
					applyTransform( e.gizmoTransform, d, frame );
					applyAttributes( e.gizmoAttributes, d, frame );
				}
			}
	}
	
	public function fetchSubElement( path:Array<Int> ):DisplayObject {
		var index:Int = -1;
		var p:DisplayObjectContainer = this;
		while ( index < path.length-1 ) {
			index++;
			if ( p.numChildren < path[ index ] )
				return null;
			if ( index == path.length-1 ) {
				return p.getChildAt( path[ index ] );
			} else {
				if ( !Std.is( p.getChildAt( path[ index ] ), DisplayObjectContainer ) )
					return null;
				p = cast( p.getChildAt( path[ index ] ), DisplayObjectContainer );
			}
		}
		return null;
	}
	
	public function getFrameCount():Int {
		return frameCount;
	}
	
	public function alignTo( d:DisplayObject ):Void {
		var p:Point = new Point(0, 0);		
		p = d.localToGlobal( p );
		p = parent.globalToLocal( p );
		x = p.x;
		y = p.y;
	}
	
	public function getFixedSize():Rectangle {
		return new Rectangle(); // given by fixed symbol / SVG shape / image size
	}
	
	public function align( r:Rectangle = null, frame:Int = 0 ):Void {
        //Debug.log(name+" align CFG "+alignment+" margins "+marginLeft+" "+marginRight+" "+marginTop+" "+marginBottom);
		var g:GizmoAlignment = effect.gizmoAlignment;
		var switches:Array<Dynamic> = g.paramSwitches.getValues( frame );
		
		alignmentSize = getFixedSize().clone();
		
		if ( switches[1] ) {
			// use fixed size frame
			var fixedSize:Array<Dynamic> = g.paramFixedSize.getValues( frame );
			alignmentSize.width = fixedSize[0];
			alignmentSize.height = fixedSize[1];
		}

		if ( switches[ 0 ] || manualAlignRange != null ) {
			var alignment:Array<Dynamic> = g.paramAlignment.getValues( frame );
			var borders:Array<Dynamic> = g.paramBorders.getValues( frame );
			
			switch ( alignment[0] ) {
				case "min":
					x = r.x + borders[ 0 ];
				case "max":
					x = r.x + r.width - alignmentSize.width - borders[ 2 ];
				case "center":
					x = r.x + (r.width - alignmentSize.width) / 2;
				case "stretch":
					x = r.x;
					alignmentSize.width = r.width;
				default:
			}

			switch ( alignment[1] ) {
				case "min":
					y = r.y + borders[ 1 ];
				case "max":
					y = r.y + r.height - alignmentSize.height - borders[ 3 ];
				case "center":
					y = r.y + (r.height - alignmentSize.height) / 2;
				case "stretch":
					y = r.y;
					alignmentSize.height = r.height;
				default:                    
			}
		} else {
			alignmentSize = null;
		}
        //trace(name+" aligning myself to "+x+" "+y+" within "+r+" by "+alignment);        
    }
	
	public function hideContents():Void {
	}
	
	public function setLabel( text:String ):Void {}
	
	public function update( timeElapsed:Float ):Void {
		if ( player != null ) {
			player.update( timeElapsed );
		}
	}
	
	public function play( loop:Bool = false, fps:Float = 30, state:String = null, onFinishedCallback:Dynamic = null ):Void {
		if ( player == null ) {
			player = new Player();
			player.onSetFrame.bind( onSetFrame );
		}
		this.onFinishedCallback = onFinishedCallback;
		onSetFrame( 0 );
		player.play( loop, fps );
	}
	
	public function stop():Void {
		if ( player != null )
			player.stop();
	}
	
	private function onSetFrame( f:Int ):Void {
		render( f, false );
	}	
	
	public function onClick( _callback:Dynamic = null ):Void {
        buttonMode = true;
        mouseChildren = false;
        addEventListener( MouseEvent.CLICK, _callback );
    }

    public function onEvents( events:Array<String>, _callback:Dynamic = null ):Void {
        buttonMode = true;
        mouseChildren = false;
        for ( e in events )
            addEventListener( e, _callback );
    } 
}
