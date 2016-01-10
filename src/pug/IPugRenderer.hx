package pug;

import pug.PugClip;
import pug.PugLib.PugRenderer;

interface IPugRenderer
{

	function add(child:IPugRenderer):Void;

	public var x(get,set):Float;
	public var y(get,set):Float;
	public var w(get,set):Float;
	public var h(get,set):Float;
	public var scaleX(get,set):Float;
	public var scaleY(get,set):Float;
	public var alpha(get,set):Float;
	public var visible(get,set):Bool;
	public var name(get,set):String;
	public var textSettings(get,set):PugClip.TEXT_SETTINGS;
	public var text(get,set):String;
	public var image(get,set):String;
	public var color(get,set):Int;
	public var contentWidth(get,null):Float;
	public var contentHeight(get,null):Float;
	
}