package pug.model.effect;

class Text extends Effect
{
    private var tf:TextField;
    private var format:TextFormat;

	public function new () 
	{
		super( [] );
		this.id = id;
		
        tf = new TextField();
        format = new TextFormat();
	}

}
