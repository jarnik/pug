package pug.model.curve;

/**
 * ...
 * @author Jarnik
 */
class Curve
{
    // each keyframe determines the curve shape ahead
    // HOLD - keep the value constant
    // LINEAR - change value linearly
    // SMOOTH - bezier, can change angle and size of a handle symmetrically
    // SMOOTH_SPIKE - bezier, can change handle for each side separately
    // if both nodes are smooth, use Cubic Bezier, otherwise Quadratic
    // http://www.paultondeur.com/2008/03/09/drawing-a-cubic-bezier-curve-using-actionscript-3/
	
	// gonna do TCB http://en.wikipedia.org/wiki/Kochanek%E2%80%93Bartels_spline
	// 				http://www.gamedev.net/topic/500802-tcb-spline-interpolation/

	public function new() {
		
	}
	
	public function getValue( x:Float, k1:KEY_TYPE, k2:KEY_TYPE, x1:Float, y1:Float, x2:Float, y2:Float ):Float {
        return getLinear( x, x1, y1, x2, y2 );
        return 0;
	}

	public function getLinear( x:Float, x1:Float, y1:Float, x2:Float, y2:Float ):Float {
    }
	
}
