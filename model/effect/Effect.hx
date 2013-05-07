package pug.model.effect;

import pug.model.gizmo.Gizmo;
import pug.model.gizmo.GizmoAlignment;
import pug.model.gizmo.GizmoCanvas;
import pug.model.gizmo.GizmoAttributes;
import pug.model.gizmo.GizmoTransform;
import pug.model.Library;
import pug.model.symbol.Symbol;

/**
 * ...
 * @author Jarnik
 */
class Effect
{
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Effect {
        var id:String = xml.get("id");
        var e:Effect = null;
        switch ( xml.nodeName ) {
            case "group":
                var g:Xml = xml.elementsNamed("children").next();
                e = EffectGroup.parse( g, l, libData );
                if ( e == null )
                    return null;
            case "symbol":            
                var s:Symbol = l.get( xml.get("use") );
                if ( s == null ) 
                    return null;
                e = EffectSymbol.create( s );
			case "particles":            
                e = new EffectParticleEmitter();
			case "text":            
                e = new EffectText();
            default:
        }
		e.id = id;
		if ( xml.get("start") != null )
			e.frameStart = Std.parseInt( xml.get("start") );
		if ( xml.get("frames") != null )
			e.frameLength = Std.parseInt( xml.get("frames") );
		if ( xml.get("level") != null )
			e.level = Std.parseInt( xml.get("level") );
        var g:Gizmo;
        var gid:String;
        for ( x in xml.elementsNamed("gizmo") ) {
            gid = x.get("name");
            g = Reflect.field( e, "gizmo"+gid );
            g.parse( x );
        }

        return e;
    }
	
	public static function createClone( e:Effect ):Effect {
		var c:Effect = e.clone();
		c.copy( e );
		return c;
	}

    public var parent:IEffectGroup;
	public var gizmos:Array<Gizmo>;
	
	public var frameStart:Int;
	public var frameLength:Int;
	public var level:Int;
	public var id:String;
	
	public var gizmoTransform:GizmoTransform;
	public var gizmoAttributes:GizmoAttributes;
	
	public function new( gizmos:Array<Gizmo> ) 
	{
		this.gizmos = gizmos;
		
		frameStart = 0;
		frameLength = 1;
		level = 0;

        id = "effect"+Math.floor(Math.random()*1000);
		
		gizmos.push( gizmoTransform = new GizmoTransform() );
		gizmos.push( gizmoAttributes = new GizmoAttributes() );
	}
	
    public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("effect");
        xml.set("id", id);
        xml.set("start", Std.string( frameStart ));
        xml.set("frames", Std.string( frameLength ));
        xml.set("level", Std.string( level ));
        var child_export:EXPORT_PUG;
        for ( g in gizmos ) {
            child_export = g.export( export );
            xml.addChild( child_export.xml );
        }
        export.xml = xml;        
		return export;
	}
	
	public function clone():Effect {
		return new Effect( [] );
	}
	
	public function copy( e:Effect ):Void {
		parent = e.parent;
		frameStart = e.frameStart;
		frameLength = e.frameLength;
		level = e.level+1;
		id = e.id + Std.string( Math.floor( Math.random() * 10 ) );
		for ( i in 0...gizmos.length )
			gizmos[i].copy( e.gizmos[ i ] ); 
	}
}
