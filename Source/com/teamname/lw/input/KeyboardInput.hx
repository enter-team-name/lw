
package com.teamname.lw.input;

import com.teamname.lw.Main;

import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

class KeyboardInput implements InputMethod {
	public var dx(default, null) : Int = 0;
	public var dy(default, null) : Int = 0;

	private var keyW : UInt;
	private var keyE : UInt;
	private var keyN : UInt;
	private var keyS : UInt;
	private var pressed = [0, 0, 0, 0];

	public function new(keyW, keyE, keyN, keyS) {
		this.keyW = keyW;
		this.keyE = keyE;
		this.keyN = keyN;
		this.keyS = keyS;

		Main.instance.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		Main.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public static inline function createWASD() {
		return new KeyboardInput(Keyboard.A, Keyboard.D, Keyboard.W, Keyboard.S);
	}
	public static inline function createArrows() {
		return new KeyboardInput(Keyboard.LEFT, Keyboard.RIGHT, Keyboard.UP, Keyboard.DOWN);
	}

	private function onKeyUp(e : KeyboardEvent) {
		//trace('onKeyUp($e)');
		if (e.keyCode == keyW)
			pressed[0] = 0;
		if (e.keyCode == keyE)
			pressed[1] = 0;
		if (e.keyCode == keyN)
			pressed[2] = 0;
		if (e.keyCode == keyS)
			pressed[3] = 0;
	}
	
	private function onKeyDown(e : KeyboardEvent) {
		//trace('onKeyDown($e)');
		if (e.keyCode == keyW)
			pressed[0] = 1;
		if (e.keyCode == keyE)
			pressed[1] = 1;
		if (e.keyCode == keyN)
			pressed[2] = 1;
		if (e.keyCode == keyS)
			pressed[3] = 1;
	}

	public function tick() {
		dx = pressed[1] - pressed[0];
		dy = pressed[3] - pressed[2];
	}
}