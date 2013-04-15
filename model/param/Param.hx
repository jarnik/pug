package pug.model.param;

import pug.model.value.Value;
import pug.model.Library;
import pug.model.value.ValueAngle;
import pug.model.value.ValueFloat;
import pug.model.value.ValueFrame;
import pug.model.param.CurveKey;

/**
 * ...
 * @author Jarnik
 */
class Param
{
	public var name:String;
	public var values:Array<Value>;
    private var tempFrame:Float;
	
	public var keys:Array<CurveKey>;

	public function new( name:String, values:Array<Value> ) 
	{
		this.name = name;
		this.values = values;
		keys = [];
	}

	public function setValues( frame:Int, values:Array<Dynamic> ):Void {
		var k:CurveKey = null;
        var insertIndex:Int = 0;
        for ( i in 0...keys.length ) {
            if ( keys[i].frame == frame ) {
                k = keys[ i ];
                break;
            }
            if ( keys[i].frame > frame ) {
                break;
            }
			insertIndex++;
        }
        if ( k == null ) {
            k = new CurveKey();
            k.frame = frame;
            k.setValues( typeValues( values ) );
            keys.insert( insertIndex, k );
        }

        for ( i in 0...k.values.length ) {
            k.values[ i ].setValue( values[ i ] );
        }
    }

    private function typeValues( data:Array<Dynamic> ):Array<Value> {
        var newValues:Array<Value> = [];
        for ( i in 0...values.length ) {
            newValues.push( 
                Type.createInstance( 
                    Type.getClass( values[ i ] ), 
                    [ data[ i ] ]
                )
            );
        }
        return newValues;
    }
	
	public function addKey( frame:Int, values:Array<Value> ):CurveKey {
		var k:CurveKey = new CurveKey();
		k.frame = frame;
		k.setValues( values );
		keys.push( k );
		return k;
	}
	
	private function getValue( v:Value ):Dynamic {
        if ( Std.is( v, ValueFrame ) ) {
            return Math.floor( cast( v, ValueFrame ).frame + tempFrame );
        }
		return v.getValue();
	}
	
	//private function getSimpleValues(v:Array<Value>, frame:Float):Array<Dynamic> {        
	private function getSimpleValues(k:CurveKey, frame:Float):Array<Dynamic> {        
		var v:Array<Value> = values;
		if ( k != null ) {
			v = k.values;
			if ( Std.is( v[0], ValueFrame ) && k.keyTypes[ 0 ] == HOLD ) {
				frame = 0;
			}
		}
		this.tempFrame = frame;
		return Lambda.array( Lambda.map( v, getValue ) );
	}
	
	public function getValues( frame:Float ):Array<Dynamic> {
		if ( keys.length == 0 )
			return getSimpleValues( null, frame );
		if ( keys.length == 1 )
			return getSimpleValues( keys[0], frame - keys[0].frame );
		var nextKey:Int = -1;
		for ( i in 0...keys.length ) {
			if ( keys[ i ].frame == frame )
				return getSimpleValues( keys[i], frame - keys[i].frame );
			if ( keys[ i ].frame > frame ) {
				nextKey = i;
				break;
			}
		}
		if ( nextKey == -1 )
			return getSimpleValues( keys[ keys.length - 1 ], frame - keys[ keys.length - 1 ].frame );
		if ( nextKey == 0 )
			return getSimpleValues( keys[ 0 ], frame - keys[ 0 ].frame );
			
		return mixKeys( 
			keys[ nextKey - 1 ], 
			keys[ nextKey ], 
			( frame - keys[ nextKey - 1 ].frame ) / ( keys[ nextKey ].frame - keys[ nextKey - 1 ].frame )  
		);
	}
	
	private function mixKeys( k1:CurveKey, k2:CurveKey, ratio:Float ):Array<Dynamic> {
		return k1.mix( k2, ratio );
	}

    public function export( export:EXPORT_PUG ):EXPORT_PUG {
		var elemName:String = name;
		elemName = StringTools.replace( elemName, " ", "_" );
		var xml:Xml = Xml.createElement( elemName );
        var vals:Array<Dynamic> = [];
        for ( v in values )
            vals.push( v.getValue() );
        xml.set("values",vals.join(","));
        var child_export:EXPORT_PUG;
        for ( k in keys ) {
            child_export = k.export( export );
            xml.addChild( child_export.xml );
        }
        export.xml = xml;        
		return export;
	}

    public function parse( x:Xml ):Void {
        var v:Array<String> = x.get("values").split(",");
        var f:Float;
        for ( i in 0...values.length ) {
            values[ i ].parse( v[ i ] );
        }

        for ( k in x.elements() ) {
            parseKey( k );
        }
    }

    private function parseKey( x:Xml ):Void {
        var valsImport:Array<String> = x.get("values").split(",");
        var f:Int = Std.parseInt( x.get("frame") );
        var vals:Array<Value> = [];
        var v:Value;
		var c;
        for ( i in 0...values.length ) {
			c = Type.getClass( values[ i ] );
			#if neko
			v = Type.createInstance( c, [ 0 ] );
			#else
			v = Type.createInstance( c, [] );
			#end
            vals.push( v );
            v.parse( valsImport[ i ] );
        }
		var k:CurveKey = addKey( f, vals );
		if ( x.get("nodes") != null ) {
			var nodes:Array<String> = x.get("nodes").split(",");
			k.keyTypes = [];
			for ( n in nodes ) {
				switch ( n ) {
					case "H": k.keyTypes.push( HOLD );
					case "L": k.keyTypes.push( LINEAR );
					default:
				}
			}
		}
    }
}
