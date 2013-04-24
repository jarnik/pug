package pug.model.effect;

/**
 * ...
 * @author Jarnik
 */
interface IEffectGroup {
	var children:Array<Effect>;
    var parent:IEffectGroup;
    var frameCount:Int;
    function addChild( e:Effect ):Void;
    function removeChild( e:Effect ):Void;
	function setLevel( e:Effect, level:Int ):Void;
}
