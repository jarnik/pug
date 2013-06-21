package pug.model.effect;

import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class EffectGroup extends Effect, implements IEffectGroup
{
    public static function parse( xml:Xml, l:Library, libData:LIB_DATA ):EffectGroup {
        var g:EffectGroup = new EffectGroup();
        var e:Effect = null;
        if ( xml.get("frames") != null )
            g.setFrameCount( Std.parseInt( xml.get("frames") ) );

        for ( x in xml.elements() ) {
            e = Effect.parse( x, l, libData );
            if ( e == null ) 
                return null;
            g.addChild( e );
        }
        return g;
    }

	public var children:Array<Effect>;
    //private var frameCount:Int;

	public function new() 
	{
		super( [] );
        id = "group"+Math.floor(Math.random()*1000);
		children = [];
	}

    public function addChild( e:Effect ):Void {
        e.level = children.length;
        e.parent = this;
		children.push( e );
    }

    public function removeChild( e:Effect ):Void {
		children.remove( e );
        for ( i in 0...children.length )
			children[ i ].level = i;
    }
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
        export.xml.nodeName = "group";
        export.xml.set("frames",Std.string( getFrameCount() ));
		var xml:Xml = Xml.createElement("children");        
        var child_export:EXPORT_PUG = { xml:null, files: export.files };
        for ( e in children ) {
            child_export = e.export( child_export );
            xml.addChild( child_export.xml );
        }
        export.xml.addChild( xml );        
		return export;
	}
	
	public function setLevel( e:Effect, level:Int ):Void {
		children.remove( e );
		children.insert( level, e );
		for ( i in 0...children.length )
			children[ i ].level = i;
	}
	
	override public function clone():Effect {
		return new EffectGroup();
	}
	
	override public function copy( e:Effect ):Void {
		super.copy( e ); 
		cast( e, EffectGroup ).setFrameCount( getFrameCount() );
		var childClone:Effect;
		for ( c in cast( e, EffectGroup ).children ) {
			addChild( Effect.createClone( c ) );
		}
	}
	
	public function getFrameCount():Int {
		return frameLength;
	}
	
	public function setFrameCount( f:Int ):Void {
		frameLength = f;
	}
}
