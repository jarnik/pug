package pug.model.effect;

import pug.model.faxe.DisplayNode;
import pug.model.faxe.DisplayShape;
import pug.model.faxe.IDisplayNode;
import pug.model.symbol.SymbolShape;
import pug.model.Library;

/**
 * ...
 * @author Jarnik
 */
class EffectRef extends Effect
{
	public var path:Array<Int>;
	public var source:Effect;

	public function new( source:Effect, path:Array<Int> ) {
		super( [] );
		this.source = source;
		this.path = path.copy();
		renderable = false;
		source.addRef( this );
	}
	
	override public function export( export:EXPORT_PUG ):EXPORT_PUG {
		export = super.export( export );
		export.xml.set("path", path.join(",") );
		export.xml.set("source", source.id );
        export.xml.nodeName = "ref";
		return export;
	}
	
	public function realign():Void {
		var rx:Float = 0;
		var ry:Float = 0;
		
		var node:IDisplayNode = cast( cast( source, EffectSymbol ).symbol, SymbolShape ).getDisplayNode();
		var index:Int = 0;
		while ( index < path.length - 1 ) {
			index++;
			if ( Std.is( node, DisplayShape ) ) {
				break;
			} else {
				node = cast( node, DisplayNode ).children[ path[ index ] ];
			}
		}
		rx = node.fixedSize.x;
		ry = node.fixedSize.y;
		
		gizmoTransform.paramPosition.values[ 0 ].setValue( rx );
		gizmoTransform.paramPosition.values[ 1 ].setValue( ry );
	}
	
}