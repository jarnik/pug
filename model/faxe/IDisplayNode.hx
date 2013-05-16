package pug.model.faxe;

import nme.Assets;
import nme.text.TextField;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;


/*
enum DisplayNode {
    //NodeBitmap( b:Bitmap );
    NodeShape( s:Sprite );
    //NodeElement( e:ElementSprite );
    //NodeText( t:TextField );
}*/

interface IDisplayNode
{
    var fixedSize:Rectangle;
    //var alpha:Float;

    //function render( isRoot:Bool = false ):DisplayNode;
}


