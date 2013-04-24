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
            g.frameCount = Std.parseInt( xml.get("frames") );

        for ( x in xml.elements() ) {
            e = Effect.parse( x, l, libData );
            if ( e == null ) 
                return null;
            g.addChild( e );
        }
        return g;
    }

	public var children:Array<Effect>;
    public var frameCount:Int;

	public function new() 
	{
		super( [] );
        id = "group"+Math.floor(Math.random()*1000);
        frameCount = 1;
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
        export.xml.set("frames",Std.string(frameCount));
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
}
