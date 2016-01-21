package pug;

// import pug.PugLib.PugRenderer;

enum ALIGN
{
	ALIGN_NONE;
	ALIGN_MIN;
	ALIGN_CENTER;
	ALIGN_MAX;
	ALIGN_STRETCH;
	ALIGN_FIT;
	ALIGN_FIT_SHRINK;
	ALIGN_FIT_EXPAND;
}

typedef RECTANGLE = 
{
	x:Float,
	y:Float,
	w:Float,
	h:Float
}

typedef TEXT_SETTINGS = 
{
	size:Null<Float>,
	font:String,
	alignment:String,
	color:Null<Int>	
}

typedef RENDER_OPTIONS = 
{
	@:optional var align:RECTANGLE;
}

class PugClip
{

	public var template:PugClip;

	public var name:String;
	public var w:Float = 0;
	public var h:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var alpha:Float = 1;
	public var color:Int = 0xffffff;
	public var visible:Bool = true;
	public var borderTop:Float = 0;
	public var borderBottom:Float = 0;
	public var borderLeft:Float = 0;
	public var borderRight:Float = 0;
	public var halign:ALIGN = ALIGN_NONE;
	public var valign:ALIGN = ALIGN_NONE;

	public var image:String;
	public var text:String;
	public var textSettings:TEXT_SETTINGS;
	public var symbolRef:PugClip;

	public var layers:Array<PugClip>;
	public var renderer:IPugRenderer;
	public var parent:PugClip;
	
	private var alignRect:RECTANGLE;

	public function new(template:PugClip,layers:Array<PugClip> = null):Void
	{
	    this.template = template;	    
	    this.layers = layers;
		this.alignRect = {x:0, y:0, w:0, h:0};

	    if (template != null)
	    {
			this.w = template.w;
			this.h = template.h;
			this.scaleX = template.scaleX;
			this.scaleY = template.scaleY;
			this.color = template.color;
			this.alpha = template.alpha;
			this.visible = template.visible;
			this.halign = template.halign;
			this.valign = template.valign;
			this.name = template.name;
			this.image = template.image;
			this.text = template.text;
			this.textSettings = Reflect.copy(template.textSettings);
			this.symbolRef = template.symbolRef;
			this.borderTop = template.borderTop;
			this.borderBottom = template.borderBottom;
			this.borderLeft = template.borderLeft;
			this.borderRight = template.borderRight;
	    }
	}

	public function fetch(path:String):PugClip
	{
		var firstDelimiter = path.indexOf("/");
		var childName:String = path;
		if (firstDelimiter != -1)
		{
			childName = path.substr(0,firstDelimiter);
			path = path.substr(firstDelimiter+1);
		}
		for (l in layers)
		{
			if (l.name == childName)
			{
				if (firstDelimiter != -1)
				{
					return l.fetch(path);
				}
				return l;
			}
		}
		
	    return null;
	}

	public function render(?opts:RENDER_OPTIONS = null):Void
	{
		if (this.renderer == null)
		{
			trace(name+" missing renderer!");
			return;
		}

	    renderer.scaleX = this.scaleX;
	    renderer.scaleY = this.scaleY;
	    renderer.alpha = this.alpha;
	    renderer.visible = this.visible;
	    renderer.name = this.name;
	    renderer.color = this.color;

	    if (this.image != null)
	    {
	    	renderer.image = this.image;
	    }
	    if (this.text != null)
	    {
	    	renderer.textSettings = this.textSettings;
	    	renderer.text = this.text;
	    }

	    var layer:PugClip;
	    var templateLayers:Array<PugClip> = template.layers;
	    if (this.symbolRef != null)
	    {
	    	templateLayers = this.symbolRef.layers;
	    }

	    if (templateLayers != null && layers == null)
	    {
	    	layers = [];
	    	for (i in 0...templateLayers.length)
		    {
	    		layer = new PugClip(templateLayers[i]);
	    		// trace(name+" create LAYER "+layer.name);
	    		addLayer(layer);
		    }
	    }

		var parentFrame:RECTANGLE = ( opts != null ? opts.align : null );
		if (parentFrame == null)
		{
			parentFrame = this.alignRect;
		} else 
		{
			this.alignRect = Reflect.copy( parentFrame );
		}
		var innerFrame:RECTANGLE = align( this.alignRect );

	    if (this.layers != null)
	    {
	    	//trace(name+" render layers "+this.layers.length);
		    for (l in this.layers)
		    {
		    	l.render({ align: innerFrame });
		    }
	    }
	}

	public function addLayer(layer:PugClip):Void
	{
		trace(name+" add PUG LAYER");
		layers.push(layer);
		layer.renderer = PugLib.createRenderer(); //new PugRenderer();
		layer.parent = this;
		renderer.addPug(layer.renderer);
	}
	
	private function align(parentFrame:RECTANGLE) : RECTANGLE
	{			
		// trace(name+" pframe w "+pFrame.w+" this.w "+this.w+" this.h "+this.h);
		var innerFrame:RECTANGLE = { x:0, y:0, w: this.w, h: this.h };
		
		if (this.renderer == null)
		{
			trace(name+" missing renderer!");
			return innerFrame;
		}

		if (this.renderer != null)
		{
			// content size given by fixed symbol / SVG shape / image size
			if (innerFrame.w == 0)
			{
				innerFrame.w = this.renderer.contentWidth;
			}
			if (innerFrame.h == 0)
			{
				innerFrame.h = this.renderer.contentHeight;
			}
		}
		
	    var x:Float = 0;
	    var y:Float = 0;
		// Debug.log(name+" align frame "+innerFrame.w+" x "+frame.height);

		// fitting
		if ( this.halign == ALIGN_FIT || this.valign == ALIGN_FIT ) 
		{
			var parentAspect:Float = ( parentFrame.w - this.borderLeft - this.borderRight ) / ( parentFrame.h - this.borderTop - this.borderBottom );
			var mineAspect:Float = innerFrame.w / innerFrame.h;
			var targetWidth:Float = innerFrame.w;
			if ( parentAspect < mineAspect ) {
				targetWidth = parentFrame.w - this.borderLeft - this.borderRight;
			} else {
				targetWidth = ( parentFrame.h - this.borderTop - this.borderBottom ) * mineAspect;
			}		

			this.w = targetWidth;
			innerFrame.w = this.w;

			this.h = targetWidth / mineAspect;
			innerFrame.h = this.h;
			// trace(name+" FIT W "+targetWidth+" paspect "+parentAspect+" mAspect "+mineAspect);

			if ( this.halign == ALIGN_FIT )
			{
				x = parentFrame.x + this.borderLeft + ( parentFrame.w - this.borderLeft - this.borderRight - targetWidth ) / 2;
			}
			if ( this.valign == ALIGN_FIT )
			{
				y = parentFrame.y + this.borderTop + ( parentFrame.h - this.borderTop - this.borderBottom - targetWidth / mineAspect ) / 2;
			}
		}

		// alignment
		switch ( this.halign ) 
		{
			case ALIGN_MIN:
				x = parentFrame.x + this.borderLeft;
				// trace("x MIN "+x);
			case ALIGN_CENTER:
				x = parentFrame.x + (parentFrame.w - innerFrame.w) / 2;
				// trace(this.name+" HC parentFrame.x "+parentFrame.x +" parentFrame.w " + parentFrame.w +" innerFrame.w "+ innerFrame.w+" x "+x);
			case ALIGN_MAX:
				x = parentFrame.x + parentFrame.w - innerFrame.w - this.borderRight;
				// trace("x MAX "+x+" rw "+r.width);
			case ALIGN_STRETCH:
				x = parentFrame.x + this.borderLeft;
				w = parentFrame.w - this.borderLeft - this.borderRight;
				//  trace(name+" HS innerFrame.w "+w+" parentFrame.w "+parentFrame.w+" this.borderLeft "+this.borderLeft+" this.borderRight "+this.borderRight);
				innerFrame.w = w;
			default:
		}
		renderer.w = innerFrame.w;

		switch ( this.valign ) {
			case ALIGN_MIN:
				y = parentFrame.y + this.borderTop;
			case ALIGN_CENTER:
				y = parentFrame.y + (parentFrame.h - innerFrame.h) / 2;				
			case ALIGN_MAX:
				y = parentFrame.y + parentFrame.h - innerFrame.h - this.borderBottom;
				// trace(this.name+" V+ parentFrame.y "+parentFrame.y +" parentFrame.h " + parentFrame.h +" innerFrame.h "+ innerFrame.h + " this.borderBottom " + this.borderBottom);
			case ALIGN_STRETCH:
				y = parentFrame.y + this.borderTop;
				h = parentFrame.h - this.borderTop - this.borderBottom;
				innerFrame.h = h;
			default:                    
		}
		renderer.h = innerFrame.h;

		renderer.x = x;
		renderer.y = y;
	    innerFrame.x = 0;
	    innerFrame.y = 0;

		return innerFrame;
	}
}