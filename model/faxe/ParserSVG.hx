package pug.model.faxe;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.utils.ByteArray;

import format.svg.PathSegment;
import format.gfx.GfxGraphics;
import format.svg.Group;
import format.svg.PathParser;
import format.svg.RenderContext;

import format.svg.SVGData;

class ParserSVG
{
    private static var data:SVGData;
	
	public static function parseName( name:String ):String {
        var r:EReg = ~/([^\[]*)/;
        if ( !r.match( name ) )
            return name;
        return r.matched( 1 );
    } 

    public static function parse( svg:String ):IDisplayNode {
        data = new SVGData (Xml.parse ( svg ));
        var root:IDisplayNode = parseElement( DisplayGroup( data ), 2 );
        return root;
    }

    private static function parseElement( de:DisplayElement, forcedSizeLevel:Int = 0 ):IDisplayNode {
        var e:IDisplayNode = null;
        var forcedSize:Rectangle = null;
        switch ( de ) {
            case DisplayGroup( group ):
                //trace("group "+group.name);
                //var align:AlignConfig = Parser.parseAlign( group.name );
                var g:DisplayNode = new DisplayNode( parseName( group.name ) );
                for ( kid in group.children )
                    g.addChild( parseElement( kid, forcedSizeLevel - 1 ) );
                if ( forcedSizeLevel > 0 ) {
                    forcedSize = new Rectangle( 0, 0, data.width, data.height );
                }
                g.updateExtent( forcedSize );
                //g.alignment = align;
                e = g;
            case DisplayPath( p ): 
                //trace( "path "+p+" "+p.matrix );
                e = new DisplayShape( p );
            /*case DisplayText( t ): 
                trace( "text not implemented yet, sorry :) " );*/
            default:
        }
        return e;
    }

}
