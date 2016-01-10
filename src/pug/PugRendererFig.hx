package pug;

import pug.PugClip;

import fig.Component;
import fig.Image;
import fig.Node;

class PugRendererFig extends Component implements IPugRenderer
{

	public function add(child:IPugRenderer):Void
	{
		// PugRendererFig has no parent yet, need to create one here
		var node:Node = this.node.addChild(new Node());
		node.addExistingComponent(cast(child,PugRendererFig));
	}

	private var width : Float = 0;
	private var height : Float = 0;

	private var imageComponent:Image;
	private var currentImage:String;
	// private var textfield:TextField;
	// private var textFormat:TextFormat;
	private var currentText:String;
	private var currentTextSettings:TEXT_SETTINGS;
	private var currentColor:Int = 0xffffff;

	public var image(get,set):String;
	public function get_image():String
	{
		return this.currentImage;
	}
	public function set_image(url:String):String
	{
		if (this.image == url)
		{
			return url;
		}

		if (this.imageComponent == null)
		{
			this.imageComponent = this.node.addComponent(Image);
		}
		this.currentImage = url;
		this.imageComponent.url = url;//openfl.Assets.getBitmapData(this.currentImage);
		return url;
	}

	public var text(get,set):String;
	public function get_text():String
	{
		return this.currentText;
	}
	public function set_text(text:String):String
	{
		if (this.currentText == text)
		{
			return text;
		}

		/*
		if (this.textfield == null)
		{
			this.textfield = new TextField();
			this.textfield.wordWrap = true;
			this.textfield.embedFonts = true;
			this.addChild(this.textfield);
		}
		this.textfield.text = text;*/
		this.currentText = text;
		return text;
	}
	
	/*
	public var tf(get,null):TextField;
	public function get_tf():TextField
	{
		return this.textfield;
	}*/

	public var textSettings(get,set):TEXT_SETTINGS;
	public function get_textSettings():TEXT_SETTINGS
	{
		return this.currentTextSettings;
	}
	public function set_textSettings(settings:TEXT_SETTINGS):TEXT_SETTINGS
	{
		if (
			this.currentTextSettings != null &&
			settings != null &&
			this.currentTextSettings.size == settings.size &&
			this.currentTextSettings.font == settings.font &&
			this.currentTextSettings.alignment == settings.alignment &&
			this.currentTextSettings.color == settings.color
		)
		{
			return settings;
		}
			
		/*
		if (this.textfield == null)
		{
			this.text = ""; // to create a textfield
		}*/
		this.currentTextSettings = Reflect.copy(settings);
		/*
		if (this.textFormat == null)
		{
			this.textFormat = new TextFormat();
		}
		if (settings.font != null)
		{
			this.textFormat.font = openfl.Assets.getFont(settings.font).fontName;
		}*/
/*#if cpp // non-legacy
		this.textFormat.size = cast(settings.size,Int);
		var align:openfl.text.TextFormatAlign;
		switch (settings.alignment)
		{
			case "center":
				align = openfl.text.TextFormatAlign.CENTER;
			case "right":
				align = openfl.text.TextFormatAlign.RIGHT;
			default:
				align = openfl.text.TextFormatAlign.LEFT;
		}
		this.textFormat.align = align;
#else*/
		/*
		this.textFormat.size = settings.size;
		this.textFormat.align = settings.alignment;*/
//#end		
		/*this.textFormat.color = settings.color;
		this.textfield.defaultTextFormat = this.textFormat;
		this.textfield.text = this.currentText;*/
		return settings;
	}

	public var w(get,set):Float;
	public function get_w():Float
	{
		return this.width;
	}
	public function set_w(value:Float):Float
	{
		this.width = value;
		if (this.imageComponent != null)
		{
			this.node.transform.scaleX = (this.width / this.contentWidth);
			// trace("w "+value);
		}
		/*if (this.textfield != null)
		{
			this.textfield.width = value / this.scaleX + 2; // offset for cpp target
			// Debug.log("TEXT w "+value);
		}*/
		return value;
	}

	public var h(get,set):Float;
	public function get_h():Float
	{
		return this.height;
	}
	public function set_h(value:Float):Float
	{
		this.height = value;
		if (this.imageComponent != null)
		{
			this.node.transform.scaleY = (this.height / this.contentHeight);
			// trace("h "+value);
		}
		/*
		if (this.textfield != null)
		{
			this.textfield.height = value / this.scaleY + 2; // offset for cpp target
			// trace("w "+value);
		}*/
		return value;
	}

	public var color(get,set):Int;
	public function get_color():Int
	{
		return this.currentColor;
	}
	public function set_color(value:Int):Int
	{
		if (value == this.currentColor)
		{
			return value;
		}

		/*
		this.currentColor = value;
		var rgb:RGB = Color.hex2rgb(value);
		this.transform.colorTransform = new ColorTransform( 
			rgb.r / 255, 
			rgb.g / 255, 
			rgb.b / 255,
			this.alpha
		);*/
		
		return value;
	}

	public var contentWidth(get,null):Float;
	public function get_contentWidth():Float
	{
		if (this.imageComponent != null)
		{
			return this.imageComponent.getContentWidth();
		}/* else if (this.textfield != null)
		{
			return this.textfield.textWidth;
		}*/
		return 0;
	}
	
	public var contentHeight(get,null):Float;
	public function get_contentHeight():Float
	{
		if (this.imageComponent != null)
		{
			return this.imageComponent.getContentHeight();
		}/* else if (this.textfield != null)
		{
			return this.textfield.textHeight;
		}*/
		return 0;
	}
	
	
	public var x(get,set) : Float;
	public function get_x() : Float
	{
		return this.node.transform.x;
	}
	public function set_x(value:Float) : Float
	{
		this.node.transform.x = value;
		return this.x;
	}
	
	public var y(get,set) : Float;
	public function get_y() : Float
	{
		return this.node.transform.y;
	}
	public function set_y(value:Float) : Float
	{
		this.node.transform.y = value;
		return this.y;
	}
	
	public var scaleX(get,set) : Float;
	public function get_scaleX() : Float
	{
		return this.node.transform.scaleX;
	}
	public function set_scaleX(value:Float) : Float
	{
		this.node.transform.scaleX = value;
		return this.scaleX;
	}
	
	public var scaleY(get,set) : Float;
	public function get_scaleY() : Float
	{
		return this.node.transform.scaleY;
	}
	public function set_scaleY(value:Float) : Float
	{
		this.node.transform.scaleY = value;
		return this.scaleY;
	}
	
	public var _alpha:Float;	
	public var alpha(get,set) : Float;
	public function get_alpha() : Float
	{
		return this._alpha;
	}
	public function set_alpha(value:Float) : Float
	{
		this._alpha = value;
		return this._alpha;
	}
	
	public var visible(get,set) : Bool;
	public function get_visible() : Bool
	{
		return this.node.active;
	}
	public function set_visible(value:Bool) : Bool
	{
		this.node.active = value;
		return this.visible;
	}
	
	public var name(get,set) : String;
	public function get_name() : String
	{
		return this.node.name;
	}
	public function set_name(value:String) : String
	{
		this.node.name = value;
		return this.name;
	}
	
}