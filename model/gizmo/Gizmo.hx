package pug.model.gizmo;

import pug.model.param.Param;
import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class Gizmo
{
	public var name:String;
	public var params:Array<Param>;

	public function new( name:String, params:Array<Param> ) 
	{
		this.name = name;
		this.params = params;
	}
	
    public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("gizmo");
        xml.set("name", name);
        var child_export:EXPORT_PUG;
        for ( p in params ) {
            child_export = p.export( export );
            xml.addChild( child_export.xml );
        }
        export.xml = xml;        
		return export;
	}

    public function parse( x:Xml ):Void {
        var elemName:String;
        for ( p in params ) {
    		elemName = StringTools.replace( p.name, " ", "_" );
            for ( xp in x.elementsNamed( elemName ) ) {
                p.parse( xp );
            }
        }
    }
}
