package pug;

import pug.PugClip;

import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import phoenix.Texture;
import phoenix.Batcher;

class PugRendererLuxe extends luxe.Entity implements IPugRenderer
{

	public function addPug(child:IPugRenderer):Void
	{
		cast(child,luxe.Entity).parent = this;
		cast(child,PugRendererLuxe).batcher = this.batcher;
	}
	
	public var batcher : Batcher;

	private var width : Float = 0;
	private var height : Float = 0;

	private var imageComponent:Sprite;
	private var currentImage:String;
	
	private var textComponent:Text;
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
		this.currentImage = url;

		if (this.imageComponent == null)
		{
			this.imageComponent = new Sprite({
				parent: this,
				batcher : this.batcher,
				centered: false
			});
		}
		this.imageComponent.texture = Luxe.resources.texture(url);
		this.imageComponent.size = new Vector(
			this.imageComponent.texture.width,
			this.imageComponent.texture.height
		);
		var c:luxe.Color = new luxe.Color();
		c.rgb(this.currentColor);
		c.a = this.alpha;
		this.imageComponent.color = c;
		
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
		
		if (this.textComponent == null)
		{
			this.textComponent = /*new luxe.Text({
				point_size : 32,
			});*/
			new Text({
				parent: this,
	            // pos : new Vector(20,20),
	            // point_size : 32,
	            // depth : 3,
	            // align : TextAlign.center,
	            font : Luxe.resources.font('assets/fonts/simplicity_10.fnt'),
				batcher : this.batcher
	            // text : 'DAY: 1'
	            // color : new Color(0,0,0,0).rgb(0x242424)
				
	        });
			
			this.textComponent.font.pages.get(0).filter_min = FilterType.nearest;
			this.textComponent.font.pages.get(0).filter_mag = FilterType.nearest;
		}
		textComponent.text = text;
		
		this.currentText = text;
		return text;
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
				
		if (this.textComponent == null)
		{
			this.text = ""; // to create a textfield
		}
		this.currentTextSettings = Reflect.copy(settings);
		/*
		if (this.textFormat == null)
		{
			this.textFormat = new TextFormat();
		}*/
		if (settings.font != null)
		{
			trace("FONT "+settings.font);
			this.textComponent.font = Luxe.resources.font(settings.font);			
			var textOriginal:String = this.text;
			this.text = textOriginal+"X";
			this.textComponent.sdf = false;
			this.text = textOriginal;
		}
		
		this.textComponent.point_size = settings.size;
		switch ( settings.alignment )
		{
			case "right":
				this.textComponent.align = luxe.TextAlign.right;
			case "center":
				this.textComponent.align = luxe.TextAlign.center;
			default:
				this.textComponent.align = luxe.TextAlign.left;
		}
		
		var c:luxe.Color = new luxe.Color();
		c.rgb(settings.color);
		this.textComponent.color = c;
		
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
		if ( this.imageComponent != null)
		{
			this.imageComponent.scale.x = (this.width / this.contentWidth);
			// trace("w "+value);
		}
		// TODO must get exact text size from TF
		/*if ( this.textComponent != null )
		{
			this.node.transform.scaleX = (this.width / this.contentWidth);
			trace("text w "+value+" scale "+this.node.transform.scaleX);
		}*/
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
			this.imageComponent.scale.y = (this.height / this.contentHeight);
			// trace("h "+value);
		}
		
		/*
		// TODO must get exact text size from TF
		if ( this.textComponent != null )
		{
			this.node.transform.scaleY = (this.height / this.contentHeight);
			trace("text h "+value+" scale "+this.node.transform.scaleY);
		}
		*/
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

		if (this.imageComponent != null)
		{
			var c:luxe.Color = new luxe.Color();
			c.rgb(this.currentColor);
			c.a = this.alpha;
			this.imageComponent.color = c;
		}
		
		if (this.textComponent != null)
		{
			var c:luxe.Color = new luxe.Color();
			c.rgb(this.currentColor);
			c.a = this.alpha;
			this.textComponent.color = c;
		}

		this.currentColor = value;
		/*
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
		if (this.imageComponent != null && this.imageComponent.texture != null)
		{
			return this.imageComponent.texture.width;
		}
		/* else if (this.textComponent != null)
		{
			return this.textComponent.getContentWidth();
		}*/
		return 0;
	}
	
	public var contentHeight(get,null):Float;
	public function get_contentHeight():Float
	{		
		if (this.imageComponent != null && this.imageComponent.texture != null)
		{
			return this.imageComponent.texture.height;
		} 
		else if (this.textComponent != null && this.textComponent.bounds != null)
		{
			return this.textComponent.bounds.h;
		}
		return 0;
	}
	
	
	public var x(get,set) : Float;
	public function get_x() : Float
	{
		return this.pos.x;
	}
	public function set_x(value:Float) : Float
	{
		this.pos.x = value;
		return this.x;
	}
	
	public var y(get,set) : Float;
	public function get_y() : Float
	{
		return this.pos.y;
	}
	public function set_y(value:Float) : Float
	{
		this.pos.y = value;
		return this.y;
	}
	
	public var scaleX(get,set) : Float;
	public function get_scaleX() : Float
	{
		return this.scale.x;
	}
	public function set_scaleX(value:Float) : Float
	{
		this.scale.x = value;
		return this.scaleX;
	}
	
	public var scaleY(get,set) : Float;
	public function get_scaleY() : Float
	{
		return this.scale.y;
	}
	public function set_scaleY(value:Float) : Float
	{
		this.scale.y = value;
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
		return this.active;
	}
	public function set_visible(value:Bool) : Bool
	{
		this.active = value;
		return this.visible;
	}
	
}