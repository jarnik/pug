package pug;

import pug.PugClip;

// typedef PugRenderer = PugRendererSprite;
// typedef PugRenderer = PugRendererFig;

class PugLib 
{

	public static var rendererClass : Class<IPugRenderer>;
	
	public static function createRenderer(args:Array<Dynamic> = null) : IPugRenderer
	{
		if (args == null)
		{
			args = [];
		}
		return Type.createInstance(rendererClass, args);
	}
	
	private var symbols:Map<String,PugClip>;

	private var lines:Array<String>;
	private var currentLine:Int;
	private var defaultSymbolProps:String;
	
	public function new():Void
	{
	    
	}

	public function createClip(symbolName:String):PugClip
	{
	    var clip:PugClip = new PugClip( getSymbol(symbolName) );	   	
	    clip.name = symbolName;
	   	return clip;
	}
	
	public function load(input:String):Void
	{
		this.symbols = new Map<String,PugClip>();

	    this.lines = input.split("\n");
	    this.currentLine = 0;
	    this.defaultSymbolProps = "";

		var symbolRE:EReg = ~/^(symbol|image|default) (.*)?/;

		var line:String;
		var refName:String;
		for (i in 0...1000)
		{
			line = getLine();
			nextLine();
			if (symbolRE.match( line ))
			{
				refName = StringTools.trim(symbolRE.matched(2));
				switch ( symbolRE.matched(1) ) 
				{
					case "image":
						//trace("IMAGE ASSET "+symbolRE.matched(2));
					case "symbol":
						//trace("SYMBOL "+symbolRE.matched(2));
						parseSymbol(refName);
					case "default":
						var defaultRE:EReg = ~/^\{([^\}]*)\}/;
						if (defaultRE.match(refName))
						{
							this.defaultSymbolProps = defaultRE.matched(1);
							trace("default props: "+this.defaultSymbolProps);
						}
				}
			} else 
			{
				trace("ignoring unmatched line: "+line);
			}
			if (!hasMoreLines())
			{
				break;
			}			
		}
		// trace("PARSED!");
	}

	private function getLine():String
	{	    
	    return this.lines[this.currentLine];
	}

	private function hasMoreLines():Bool
	{
		return (this.currentLine < this.lines.length);
	}

	private function nextLine():Void
	{
		this.currentLine++;
	}

	private function parseImage():Void
	{
	    
	}

	private function parseSymbol(name:String):Void
	{
	    var symbol:PugClip = getSymbol(name);
	    var layers:Array<PugClip> = parseLayers(1);
	    symbol.layers = layers;
	}

	private function getSymbol(name:String):PugClip
	{
		if (this.symbols.exists(name))
		{
			return this.symbols[name];
		}
	 	var symbol:PugClip = new PugClip(null);
	 	symbol.halign = ALIGN_STRETCH;
	   	symbol.valign = ALIGN_STRETCH;
	   	symbol.name = name;
	    this.symbols[name] = symbol;
	    return symbol;
	}

	private function parseLayers(level:Int):Array<PugClip>
	{
		var layers:Array<PugClip> = [];

		var layerRE:EReg = ~/^([\t ]*)((symbol|image|text|clip)(<(.*)>)?) ([^\{]+)(\{(.*)\})?/;

		var line:String;
		var parsedLevel:Int;
		var clip:PugClip;

		var layerType:String;
		var layerRef:String;
		var layerName:String;
		var layerProps:String;

		if (!hasMoreLines())
		{
			return layers;
		}

		for (i in 0...1000)
		{
			line = getLine();
			if (layerRE.match( line ))
			{
				parsedLevel = layerRE.matched(1).length;
				//trace("matched layer "+line+" level "+parsedLevel);
				if (parsedLevel < level)
				{
					// end of layer group
					break;
				}
				nextLine();
				layerType = layerRE.matched(3);
				//trace("matching layer type "+layerType);
				layerRef = layerRE.matched(5);
				layerName = StringTools.trim(layerRE.matched(6));
				layerProps = layerRE.matched(8);
				//trace("layer "+layerName+" props "+layerProps);
				clip = new PugClip(null);
				clip.name = layerName;

				if (this.defaultSymbolProps != null)
				{
					parseLayerProperties(clip,this.defaultSymbolProps);
				}

				parseLayerProperties(clip,layerProps);
				switch ( layerType ) 
				{
					case "symbol":
						//trace("will parse symbol "+layerRef);
						clip.symbolRef = getSymbol(layerRef);
					case "image":
						//trace("will parse image "+layerRef);
						clip.image = layerRef;
					case "text":
						///trace("will parse label");
						clip.text = layerRef;
					case "clip":
						//trace("will parse clip layers "+layerProps);
						clip.layers = parseLayers(level+1);
				}					
				layers.push(clip);
			} else
			{
				trace("unmatched layer "+line);
				break;
			}

			if (!hasMoreLines())
			{
				break;
			}
		}

		return layers;
	}

	private function parseLayerProperties(clip:PugClip, input:String):Void
	{
		if (input == null)
		{
			return;
		}

		var prop:String = "";
		var levelCounter:Int = 0;
		for (i in 0...input.length)
		{
			switch (input.charAt(i)) 
			{
				case '"':
					if (levelCounter == 0)
					{
						levelCounter++;
					} else 
					{
						levelCounter--;
					}
				case '{':
					levelCounter++;
					prop += input.charAt(i);
				case '}':
					levelCounter--;
					prop += input.charAt(i);
				case ',':
					if (levelCounter == 0)
					{
						parseLayerProp(clip,prop);
						prop = "";
					} else 
					{
						prop += input.charAt(i);
					}
				default:
					prop += input.charAt(i);
			}
		}
		parseLayerProp(clip,prop);
	}

	private function parseLayerProp(clip:PugClip, prop:String):Void
	{
		var propName:String = prop.substr(0,prop.indexOf(":"));
		var propVal:String = prop.substr(prop.indexOf(":")+1);
		//trace("USE val "+propName+" = "+propVal);

		switch (propName) 
		{
			case "w":
				clip.w = Std.parseFloat(propVal);
			case "h":
				clip.h = Std.parseFloat(propVal);
			case "color":
				clip.color = Std.parseInt(StringTools.replace(propVal,"#","0x"));
			case "sx":
				clip.scaleX = Std.parseFloat(propVal);
			case "sy":
				clip.scaleY = Std.parseFloat(propVal);
			case "s":
				clip.scaleX = Std.parseFloat(propVal);
				clip.scaleY = Std.parseFloat(propVal);
			case "ha","va":
				var alignment:ALIGN = ALIGN_NONE;
				switch (propVal) 
				{
					case "s":
						alignment = ALIGN_STRETCH;
					case "-":
						alignment = ALIGN_MIN;
					case "+":
						alignment = ALIGN_MAX;
					case "c":
						alignment = ALIGN_CENTER;
					case "f":
						alignment = ALIGN_FIT;
					case "f-":
						alignment = ALIGN_FIT_SHRINK;
					case "f+":
						alignment = ALIGN_FIT_EXPAND;
					default:
						alignment = ALIGN_NONE;
						trace("unknown alignment value "+propVal);
				}
				if (propName == "ha")
				{
					clip.halign = alignment;	
				} else 
				{
					clip.valign = alignment;
				}
			case "a":
				clip.alpha = Std.parseFloat(propVal);
			case "textSize", "textFont", "textAlign", "textColor":
				if (clip.textSettings == null)
				{
					clip.textSettings = {size:null,font:null,alignment:null,color:null};
				}
				switch (propName) 
				{
					case "textSize":
						if (StringTools.endsWith(propVal,"%"))
						{
							clip.textSettings.size = Std.parseFloat(propVal.substring(0,propVal.length-1)) / 100 * clip.textSettings.size;
						} else 
						{
							clip.textSettings.size = Std.parseFloat(propVal);
						}
					case "textFont":
						clip.textSettings.font = propVal;
					case "textAlign":
						clip.textSettings.alignment = propVal;
					case "textColor":
						clip.textSettings.color = Std.parseInt(StringTools.replace(propVal,"#","0x"));
				}
			case "border":
				var values:Array<String> = propVal.split("|");
				switch ( values.length ) 
				{
					case 1:
						clip.borderTop = Std.parseFloat(values[0]);
						clip.borderBottom = Std.parseFloat(values[0]);
						clip.borderLeft = Std.parseFloat(values[0]);
						clip.borderRight = Std.parseFloat(values[0]);
					case 2:
						clip.borderTop = Std.parseFloat(values[0]);
						clip.borderBottom = Std.parseFloat(values[0]);
						clip.borderLeft = Std.parseFloat(values[1]);
						clip.borderRight = Std.parseFloat(values[1]);
					case 3:
						clip.borderTop = Std.parseFloat(values[0]);
						clip.borderLeft = Std.parseFloat(values[1]);
						clip.borderRight = Std.parseFloat(values[1]);
						clip.borderBottom = Std.parseFloat(values[2]);
					case 4:
						clip.borderTop = Std.parseFloat(values[0]);
						clip.borderRight = Std.parseFloat(values[1]);
						clip.borderBottom = Std.parseFloat(values[2]);
						clip.borderLeft = Std.parseFloat(values[3]);
				}
			case "top":
				clip.borderTop = Std.parseFloat(propVal);
			case "bottom":
				clip.borderBottom = Std.parseFloat(propVal);
			case "left":
				clip.borderLeft = Std.parseFloat(propVal);
			case "right":
				clip.borderRight = Std.parseFloat(propVal);
		}
	}

}