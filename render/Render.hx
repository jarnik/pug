package pug.render;
import flash.display.DisplayObject;
import nme.geom.Point;
import pug.model.effect.Effect;
import pug.model.effect.EffectSymbol;
import pug.model.effect.EffectSymbolLayer;
import pug.model.effect.EffectGroup;
import pug.model.effect.IEffectGroup;
import pug.model.symbol.SymbolImage;
import pug.model.symbol.SymbolLayer;
import pug.model.symbol.SymbolLayerState;
import pug.model.symbol.SymbolShape;
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

/**
 * ...
 * @author Jarnik
 */
class Render extends Sprite
{
	public static function renderSymbol( s:Symbol ):Render {
		var r:Render;
		var e:Render;
		var f:Effect;
        if ( Std.is( s, SymbolLayer ) ) {
			r = new RenderGroupStates( new EffectSymbolLayer( s ) );
			r.effect.gizmoAttributes.params[3].values[0].setValue( cast( s, SymbolLayer ).getFirstStateName() );
			//if ( state != null )
			//	cast( r, pug.render.RenderGroupStates ).switchState( state );
			return r;
        } else if ( Std.is( s, SymbolImage ) ) {
			r = new RenderImage( null, cast( s, SymbolImage ) );
			return r;
		}
		return null;
	}
	
	public static function create( e:Effect ):Render {
		if ( Std.is( e, EffectSymbolLayer ) ) {
			return new RenderGroupStates( cast( e, EffectSymbolLayer ) );
		} else if ( Std.is( e, EffectSymbol ) ) {
            if ( Std.is( cast( e, EffectSymbol ).symbol, SymbolImage ) ) {
				return new RenderImage( e, cast( cast( e, EffectSymbol ).symbol, SymbolImage ) );
            } else
				return null;
		} else if( Std.is( e, EffectGroup ) ) {
			return new RenderGroup( e, cast( e, EffectGroup ) );
		}
		return null;
	}
	
	public var effect:Effect;
	public var player:Player;
	public var renderUpdatesEnabled:Bool;
	
	public function new( effect:Effect ) 
	{
		super();
		renderUpdatesEnabled = true;
		this.effect = effect;
	}
	
	public function render( frame:Int, applyTransforms:Bool = true ):Void {
		if ( effect != null && applyTransforms ) {
			applyTransform( effect.gizmoTransform, this, frame );
			applyAttributes( effect.gizmoAttributes, this, frame );			
		}
	}
	
	
	
	public function alignTo( d:DisplayObject ):Void {
		var p:Point = new Point(0, 0);		
		p = d.localToGlobal( p );
		p = parent.globalToLocal( p );
		x = p.x;
		y = p.y;
	}
	
	public function hideContents():Void {
	}
	
	public function update( timeElapsed:Float ):Void {
		if ( player != null ) {
			player.update( timeElapsed );
		}
	}
	
	public function play( loop:Bool = false, fps:Float = 30 ):Void {
		if ( player == null ) {
			player = new Player();
			player.onSetFrame.bind( onSetFrame );
		}
		player.play( loop, fps );
	}
	
	public function stop():Void {
		if ( player != null )
			player.stop();
	}
	
	private function onSetFrame( f:Int ):Void {
		render( f, false );
	}
	
	private function applyTransform( g:GizmoTransform, d:DisplayObject, frame:Int = 0 ):Void {
		var position:Array<Dynamic> = g.paramPosition.getValues( frame );
		var rot:Array<Dynamic> = g.paramRotation.getValues( frame );
		var scale:Array<Dynamic> = g.paramScale.getValues( frame );
		x = position[ 0 ];
		y = position[ 1 ];
		rotation = rot[ 0 ];
		scaleX = scale[ 0 ];
		scaleY = scale[ 1 ];
	}
	
	private function applyAttributes( g:GizmoAttributes, d:DisplayObject, frame:Int = 0 ):Void {
		var alpha:Array<Dynamic> = g.paramAlpha.getValues( frame );
        this.alpha = alpha[ 0 ];
    }
}
