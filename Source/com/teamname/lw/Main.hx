package com.teamname.lw;

import openfl.display.Sprite;
import openfl.display.Bitmap;

class Main extends Sprite {
	public function new() {
		super();
		trace("Hello World!");

		var w = new World();

		var b = new Bitmap(w.mesh.toImage());
		//b.scaleX = b.scaleY = 2;
		addChild(b);
	}
}