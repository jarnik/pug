package pug.model.symbol;

import pug.model.effect.IEffectGroup;
import pug.model.effect.Effect;
import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class SymbolLayerState implements IEffectGroup
{
	 public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):SymbolLayerState {
        var id:String = xml.get("id");
        var s:SymbolLayerState = new SymbolLayerState( id );
        if ( xml.get("frames") != null )
            s.frameCount = Std.parseInt( xml.get("frames") );
		
		var e:Effect;
        for ( x in xml.elements() ) {
            e = Effect.parse( x, l, libData );
            if ( e == null ) {
                return null;
            } else {
				s.addChild( e );
            }
        }
        return s;
    }
	
	public var children:Array<Effect>;
    public var frameCount:Int;
	public var parentSymbol:SymbolLayer;
	public var parent:IEffectGroup;
	public var name:String;

	public function new( name:String ) {
		children = [];
		this.name = name;
        frameCount = 1;
	}
	
	public function addChild( e:Effect ):Void {        
        e.parent = this;
		e.level = children.length;
		children.push( e );
    }

    public function removeChild( e:Effect ):Void {
		children.remove( e );
        for ( i in 0...children.length )
			children[ i ].level = i;
    }
	
	public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("state");
		xml.set( "id", name );
		xml.set( "frames", Std.string( frameCount ) );
        var child_export:EXPORT_PUG;
        for ( c in children ) {
            child_export = c.export( export );
            xml.addChild( child_export.xml );
        }
        export.xml = xml;        
		return export;
	}
	
	public function setLevel( e:Effect, level:Int ):Void {
		children.remove( e );
		children.insert( level, e );
		for ( i in 0...children.length )
			children[ i ].level = i;
	}
	
}
