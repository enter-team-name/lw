/*
* One big, solid, random polygon that takes up most of the map.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class RandPoly {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp : BitmapData;
		if(map.background == 0) // TODO: unify all functions in this
			bmp = new BitmapData(map.width, map.height);
		else
			bmp = new BitmapData(map.width, map.height, false, 0x000000);
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;

		/* Color sections
		for (i in 0...map.num_col) {
			for (j in 0...map.num_row) {
				bmp.fillRect(new Rectangle(Std.int(i*map.sec_width), Std.int(j*map.sec_height), Std.int(map.sec_width), Std.int(map.sec_height)), 0xFF000000 + Std.random(0xFFFFFF));
			}
		} */

		var PAD = Std.int(Math.min(5, (Math.min(map.sec_width, map.sec_height) - 1) / 2) );
		/* Just 5 in original, but could cause rectangle instead poly if sec_width or sec_height < 2*PAD
			See Map.hx:RandPointSectionOffset:
				RandNum(from, to) works weird if from > to
			(Seriously, what's the random number greater than 10 and less than 0?) */

		var r : Int, c : Int;
		
		if(map.background ==0) {
			g.lineStyle(0,0x000000);
			g.beginFill(0x000000);
		}
		else {
			g.lineStyle(0,0xFFFFFF);
			g.beginFill(0xFFFFFF);
		}

		var start = map.RandPointSectionOffset(0, 0, PAD);
		g.moveTo(start.x, start.y);

		/* top */
		r = 0;
		for(c in 1...map.num_col) {
			var vert = map.RandPointSectionOffset(r, c, PAD);
			g.lineTo(vert.x, vert.y);
		}

		/* right side */
		c = map.num_col-1;
		for(r in 1...map.num_row) {
			var vert = map.RandPointSectionOffset(r, c, PAD);
			g.lineTo(vert.x, vert.y);
		}

		/* bottom */
		r = map.num_row-1;
		for(c in range(map.num_col-2, -1, -1)) {
			var vert = map.RandPointSectionOffset(r, c, PAD);
			g.lineTo(vert.x, vert.y);
		}

		/* left side */
		c = 0;
		for(r in range(map.num_row-2, 0, -1)) {
			var vert = map.RandPointSectionOffset(r, c, PAD);
			g.lineTo(vert.x, vert.y);
		}

		g.lineTo(start.x, start.y);
		g.endFill();

		bmp.draw(sprite);
		return bmp;
	}
}