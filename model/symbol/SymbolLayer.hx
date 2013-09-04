package pug.model.symbol;

import pug.model.effect.Effect;
import pug.model.effect.IEffectGroup;
import pug.model.Library;

class SymbolLayer extends Symbol
{
	public var states:Map<String,SymbolLayerState>;
	
	public static function getDefaultStateName():String {
		return "main";
	}
	
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):Symbol {
        var id:String = xml.get("id");
        var s:SymbolLayer = new SymbolLayer( id );

        var ss:SymbolLayerState;
        for ( x in xml.elements() ) {
            ss = SymbolLayerState.parse( x, l, libData );
            if ( ss == null ) {
                return null;
            } else {
                s.addState( ss.name, ss );
            }
        }

        return s;
    }

	public function new ( id:String ) 
	{
		super( id );
        states = new Map<String,SymbolLayerState>();
		//addState( getDefaultStateName() );
	}
	
	private function sortString( a:String, b:String ):Int {
		if ( a == b )
			return 0;
		if ( a < b )
			return -1;
		return 1;
	}
	
	public function getFirstStateName():String {
		var keys:Array<String> = [];
		for ( n in states.keys() )
			keys.push( n );
		keys.sort( sortString );
		if ( keys.length == 0 )
			return null;
		return keys[0];
	}
	
	public function addState( name:String, existingState:SymbolLayerState = null ):SymbolLayerState {
		var state:SymbolLayerState;
		if ( existingState != null )
			state = existingState;
		else { 
			state = new SymbolLayerState( name );
		}
		state.parentSymbol = this;
		states.set( name, state );
		return state;
	}

	public function renameState( name:String, newName:String ):Void {
        var state:SymbolLayerState = states.get( name );
        if ( state == null )
            return;
        removeState( name );
        states.set( newName, state );
        state.name = newName;
    }

	public function removeState( name:String ):Void {
        states.remove( name );
    }
	
	private function cmpString(a:String, b:String):Int
	{
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}

    override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
		var xml:Xml = export.xml;
		xml.nodeName = "symbolLayer";
        var child_export:EXPORT_PUG;
		
		var stateNames:Array<String> = [];
		for ( k in states.keys() )
			stateNames.push( k );
		stateNames.sort(cmpString);
		
        for ( s in stateNames ) {
            child_export = states[s].export( export );
            xml.addChild( child_export.xml );
        }
        export.xml = xml;        
		return export;
	}

}
