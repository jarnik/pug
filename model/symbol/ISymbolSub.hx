package pug.model.symbol;

import nme.display.BitmapData;
import pug.model.faxe.DisplayNode;
import pug.model.effect.Effect;

interface ISymbolSub {
	var source:String;
	var path:String;
}

enum SUBASSET {
	SubAssetBitmapData( bmd:BitmapData );
	SubAssetDisplayNode( n:DisplayNode );
}
