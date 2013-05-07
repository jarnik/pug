package pug.model.param;

import pug.model.value.Value;
import pug.model.value.ValueFloat;
import pug.model.value.ValueFrame;
import pug.model.value.ValueAngle;
import pug.model.value.ValueScale;
import pug.model.value.ValueString;
import pug.model.value.ValueColor;
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
		if ( keyTypes.length == 0 ) {
			keyTypes = [];
			for ( i in 0...values.length )
				keyTypes.push( LINEAR );
		}
	}

    public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var xml:Xml = Xml.createElement("key");
        xml.set("frame",Std.string(frame));
        var vals:Array<Dynamic> = [];
        for ( v in values )
            vals.push( v.getValue() );
        xml.set("values", vals.join(","));
		var keys:Array<String> = [];
		for ( k in keyTypes ) {
			switch ( k ) {
				case HOLD:
					keys.push( "H" );
				case LINEAR:
					keys.push( "L" );
				default:
			}
		}
		xml.set("nodes", keys.join(","));
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
			
			if ( keyTypes[ i ] == HOLD )
				ratio = 0;
			
			switch( Type.getClass( v1 ) ) {
                case ValueFrame:
					v = cast( v1, ValueFrame ).frame + Math.floor( ratio * ( k.frame - frame ) );
				default:
					v = v1.mix( v2, ratio );
			}
			
			out.push( v );
		}
		return out;
	}
	
	public function clone():CurveKey {
		var k:CurveKey = new CurveKey();
		k.frame = frame;
		for ( v in values )
			k.values.push( v.clone() );
		for ( t in keyTypes )
			k.keyTypes.push( t );
		return k;
	}
	
}
