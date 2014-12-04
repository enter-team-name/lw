package com.teamname.lw;

import com.teamname.lw.mesh.*;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

class Main extends Sprite {
	public function new() {
		super();
		trace("Hello World!");

		var bitmapData = Assets.getBitmapData("maps/world1.png");
		var mesh : Mesh<Int> = new WriteOptimizedMesh<Int>(bitmapData.width, bitmapData.height, 0);
		mesh.addBitmap(bitmapData);
		mesh.mergeAll(8);
		mesh = new ReadOptimizedMesh<Int>(mesh.width, mesh.height, 0, mesh);

		var b = new Bitmap(mesh.toBitmap());
		b.scaleX = b.scaleY = 2;
		addChild(b);
	}
}