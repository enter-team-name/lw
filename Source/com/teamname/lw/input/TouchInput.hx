
package com.teamname.lw.input;

import com.teamname.lw.Main;

import openfl.display.Sprite;
import openfl.events.MouseEvent;

class TouchInput implements InputMethod {
	public var dx(default, null) : Int = 0;
	public var dy(default, null) : Int = 0;

	private var lastX(default, null) : Float = 250;
	private var lastY(default, null) : Float = 400;
	private var scale(default, null) : Float = 0;
	private var haveUpdate(default, null) : Bool = false;

	public function new(scale : Float) {
		this.scale = scale;
		Main.instance.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		// Main.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		// Main.instance.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	public static inline function create(scale : Float) {
		return new TouchInput(scale);
	}

	// private function onMouseDown(e : MouseEvent) {
	// 	lastX = e.localX / scale;
	// 	lastY = e.localX / scale;
	// 	Main.instance.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	// }

	// private function onMouseUp(e : MouseEvent) {
	// 	dx = 0;
	// 	dy = 0;
	// 	Main.instance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	// }

	public function onMouseMove(e : MouseEvent) {
		dx = Std.int(e.localX / scale - lastX);
		dy = Std.int(e.localY / scale - lastY);
		lastX = e.localX / scale;
		lastY = e.localY / scale;
		haveUpdate = true;
	}

	public function tick() {
		if(haveUpdate)
			haveUpdate = false;
		else {
			dx = 0;
			dy = 0;
		}
	}
}