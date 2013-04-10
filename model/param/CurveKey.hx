package pug.model.param;

import pug.model.value.Value;
import pug.model.value.ValueFloat;
import pug.model.value.ValueFrame;
import pug.model.value.ValueAngle;
import pug.model.value.ValueScale;
import pug.model.value.ValueString;
import pug.model.Library;

enum KEY_TYPE {
    HOLD;
    LINEAR;
    SMOOTH( angle:Float, size:Float );
    SMOOTH_SPIKE( angleLeft:Float, sizeLeft:Float, angleRight:Float, sizeRight:Float );
}

/**
 * ...
 * @author Jarnik
 */
class CurveKey
{
	public var frame:Int;
	public var values:Array<Value>;
    public var keyTypes:Array<KEY_TYPE>;    

	public function new() {
	    values = [];
        keyTypes = [];	
	}
	
	public function setValues( values:Array<Value> ):Void {
		this.values = values;
        keyTypes = [];
        for ( i in 0...values.length )
            keyTypes.push( LINEAR );
	}

    public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("key");
        xml.set("frame",Std.string(frame));
        var vals:Array<Dynamic> = [];
        for ( v in values )
            vals.push( v.getValue() );
        xml.set("values",vals.join(","));
        export.xml = xml;        
		return export;
	}
	
	public function mix( k:CurveKey, ratio:Float ):Array<Dynamic> {
		var out:Array<Dynamic> = [];
		var v1:Value;
		var v2:Value;
		var v:Dynamic;
		for ( i in 0...values.length ) {
			// TODO - this is linear only, test other key types
			v = 0;
			v1 = values[ i ];
			v2 = k.values[ i ];
			switch( Type.getClass( v1 ) ) {
				case ValueFloat:
					v = cast( v1, ValueFloat ).float * (1 - ratio) + cast( v2, ValueFloat ).float * (ratio);
				case ValueAngle:
					v = cast( v1, ValueAngle ).degrees * (1 - ratio) + cast( v2, ValueAngle ).degrees * (ratio);
				case ValueScale:
					v = cast( v1, ValueScale ).scale*(1-ratio) + cast( v2, ValueScale ).scale*(ratio);
				case ValueString:
					v = cast( v1, ValueString ).string;
                case ValueFrame:
					//v = Math.floor( cast( v1, ValueFrame ).frame * (1 - ratio) + cast( v2, ValueFrame ).frame * (ratio) );
					v = cast( v1, ValueFrame ).frame + Math.floor( ratio*( k.frame - frame ) );
			}
			out.push( v );
		}
		return out;
	}
	
}
