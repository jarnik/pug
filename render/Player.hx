package pug.render;

import pug.model.utils.Signaler;
import nme.events.Event;
import nme.Lib;

/**
 * ...
 * @author Jarnik
 */
class Player
{
	public var onSetFrame:Signaler<Int>;
	
	private var useCustomClock:Bool;
	public var loop:Bool;
	public var isPlaying:Bool;
	private var timeElapsed:Float;
    private var prevFrameTime:Float;
	public var playStartFrame:Int;
	private var playDuration:Float;
	private var fps:Float;

	public function new( useCustomClock:Bool = false ) 
	{
		isPlaying = false;
		playDuration = -1;
		prevFrameTime = 0;
		loop = false;
		fps = 16;
		this.useCustomClock = useCustomClock;
		
		onSetFrame = new Signaler();
		if ( useCustomClock )
			Lib.current.stage.addEventListener (Event.ENTER_FRAME, stage_onEnterFrame);
	}
	
	public function play( loop:Bool, fps:Float ):Void {
		isPlaying = true;
		this.loop = loop;
		this.fps = fps;
		playStartFrame = 0;
		playDuration = 0;
	}
	
	public function stop():Void {
		isPlaying = false;
		playDuration = -1;
	}

	public function update( elapsed:Float ):Void {
        timeElapsed = elapsed;
		
		if ( playDuration >= 0 ) {
			playDuration += timeElapsed;
			var frame:Int = playStartFrame + Math.floor( playDuration * fps );
			onSetFrame.dispatch( frame );
		}
	}
	
	private function stage_onEnterFrame( e:Event ):Void {
		var now:Float = Lib.getTimer() / 1000;
        var timeElapsed:Float = (now - prevFrameTime);
        prevFrameTime = now;
		
		update( timeElapsed );
	}	
	
}