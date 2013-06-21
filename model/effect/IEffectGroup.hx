package pug.model.effect;

/**
 * ...
 * @author Jarnik
 */
interface IEffectGroup {
	var children:Array<Effect>;
    var parent:IEffectGroup;
    function addChild( e:Effect ):Void;
    function removeChild( e:Effect ):Void;
	function setLevel( e:Effect, level:Int ):Void;
	function getFrameCount():Int;
	function setFrameCount( f:Int ):Void;
}
