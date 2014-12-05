package com.teamname.lw;

import com.teamname.lw.mesh.*;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.MouseEvent;

class Main extends Sprite {
	var world : World;
	var bitmap : Bitmap;
	var lastX : Int;
	var lastY : Int;

	public function new() {
		super();
		trace("Hello World!");


		var bitmapData = Assets.getBitmapData("maps/world1.png");
		world = new World(bitmapData);

		bitmap = new Bitmap();
		bitmap.scaleX = bitmap.scaleY = 2;
		addChild(bitmap);

		addEventListener(Event.ENTER_FRAME, tick);
		addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
	}

	public function mouseMove(event) {
		var x = event.localX / bitmap.scaleX;
		var y = event.localY / bitmap.scaleY;
		trace(x, y);
		world.moveCursor(Std.int(x), Std.int(y), 2 * Std.int(Math.max(Math.abs(world.cursorX - x), Math.abs(world.cursorY - y))));
		bitmap.bitmapData = world.armyPathfinders[0].getDebugBitmap();
	}

	public function tick(e : Event) {
		world.tick();
		bitmap.bitmapData = world.getBitmap(0);
	}
}