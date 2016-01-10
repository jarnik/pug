package pug;

import gaxe.Debug;
import spacr.utils.Color;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.text.TextField;
import openfl.text.TextFormat;
import pug.PugClip;

class PugRendererSprite extends Sprite implements IPugRenderer
{

	public function add(child:IPugRenderer):Void
	{
		super.addChild(cast(child,Sprite));
	}

	private var bitmap:Bitmap;
	private var currentImage:String;
	private var textfield:TextField;
	private var textFormat:TextFormat;
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

		if (this.bitmap == null)
		{
			this.bitmap = new Bitmap();
			this.addChild(this.bitmap);
		}
		this.currentImage = url;
		this.bitmap.bitmapData = openfl.Assets.getBitmapData(this.currentImage);
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

		if (this.textfield == null)
		{
			this.textfield = new TextField();
			this.textfield.wordWrap = true;
			this.textfield.embedFonts = true;
			this.addChild(this.textfield);
		}
		this.currentText = text;
		this.textfield.text = text;
		return text;
	}
	public var tf(get,null):TextField;
	public function get_tf():TextField
	{
		return this.textfield;
	}

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
			
		if (this.textfield == null)
		{
			this.text = ""; // to create a textfield
		}
		this.currentTextSettings = Reflect.copy(settings);
		if (this.textFormat == null)
		{
			this.textFormat = new TextFormat();
		}
		if (settings.font != null)
		{
			this.textFormat.font = openfl.Assets.getFont(settings.font).fontName;
		}
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
		this.textFormat.size = settings.size;
		this.textFormat.align = settings.alignment;
//#end		
		this.textFormat.color = settings.color;
		this.textfield.defaultTextFormat = this.textFormat;
		this.textfield.text = this.currentText;
		return settings;
	}

	/*
	public function getChild(index:Int):IPugRenderer
	{
		return cast( this.getChildAt(index), PugRendererSprite);
	}*/

	public var w(get,set):Float;
	public function get_w():Float
	{
		return this.width;
	}
	public function set_w(value:Float):Float
	{
		//this.width = value;
		if (this.bitmap != null)
		{
			this.bitmap.width = value / this.scaleX;
			// trace("w "+value);
		}
		if (this.textfield != null)
		{
			this.textfield.width = value / this.scaleX + 2; // offset for cpp target
			// Debug.log("TEXT w "+value);
		}
		return value;
	}

	public var h(get,set):Float;
	public function get_h():Float
	{
		return this.height;
	}
	public function set_h(value:Float):Float
	{
		//this.height = value;
		if (this.bitmap != null)
		{
			this.bitmap.height = value / this.scaleY;
			// trace("h "+value);
		}
		if (this.textfield != null)
		{
			this.textfield.height = value / this.scaleY + 2; // offset for cpp target
			// trace("w "+value);
		}
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

		this.currentColor = value;
		var rgb:RGB = Color.hex2rgb(value);
		this.transform.colorTransform = new ColorTransform( 
			rgb.r / 255, 
			rgb.g / 255, 
			rgb.b / 255,
			this.alpha
		);
		
		return value;
	}

	public var contentWidth(get,null):Float;
	public function get_contentWidth():Float
	{
		if (this.bitmap != null)
		{
			return this.bitmap.bitmapData.width;
		} else if (this.textfield != null)
		{
			return this.textfield.textWidth;
		}
		return 0;
	}
	
	public var contentHeight(get,null):Float;
	public function get_contentHeight():Float
	{
		if (this.bitmap != null)
		{
			return this.bitmap.bitmapData.height;
		} else if (this.textfield != null)
		{
			return this.textfield.textHeight;
		}
		return 0;
	}
	
}