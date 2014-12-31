/*
* Random circles.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;

class Circles {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height);
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;

		var size : Int = Std.int((map.sec_width < map.sec_height ? map.sec_width : map.sec_height)/2.0);
		size = (size == 0 ? 1 : size);

		for (r in 0...map.num_row) {
			for (c in 0...map.num_col) {
				var center = map.RandPointSectionOffset(r, c, 0);
				g.beginFill(0x000000);
				g.drawCircle(center.x, center.y, Std.random(size) + 1);
				g.endFill();
			}
		}

		bmp.draw(sprite);
		return bmp;
	}
}