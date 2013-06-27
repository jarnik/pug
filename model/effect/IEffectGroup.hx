package pug.model.effect;

/**
 * ...
 * @author Jarnik
 */
interface IEffectGroup {
	var children:Array<Effect>;
    var parent:IEffectGroup;
	var groupFrames:Int;
	var fps:Float;
    function addChild( e:Effect ):Void;
    function removeChild( e:Effect ):Void;
	function setLevel( e:Effect, level:Int ):Void;
}
