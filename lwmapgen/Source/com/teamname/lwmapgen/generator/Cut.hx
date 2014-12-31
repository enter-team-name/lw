/*
* Makes a bunch random lines.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;

class Cut {
	public function new() { }

	public function generate(bmp : BitmapData) : BitmapData {
		var map = Main.instance.map;
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;

		var fromr : Int, fromc : Int, tor : Int, toc : Int;
		var vert = [];

		var size = Std.int((map.sec_width > map.sec_height ? map.sec_width : map.sec_height)/8.0);
		size = (size == 0 ? 1 : size);

		/* vertical */
		fromr = 0;
		tor = map.num_row-1;
		for (i in range(0, map.num_col, 2)) {
			fromc = Std.random(map.num_col);
			toc = Std.random(map.num_col);

			var start = map.SectionCenter(fromr, fromc);
			var end = map.SectionCenter(tor, toc);

			vert[0] = start.x - size;
			vert[1] = 1;
			vert[2] = start.x + size;
			vert[3] = 1;

			vert[4] = end.x + size;
			vert[5] = map.height - 1;
			vert[6] = end.x - size;
			vert[7] = map.height - 1;

			g.lineStyle(0,0xFFFFFF);
			g.beginFill(0xFFFFFF);
			g.moveTo(vert[0], vert[1]);
			g.lineTo(vert[2], vert[3]);
			g.lineTo(vert[4], vert[5]);
			g.lineTo(vert[6], vert[7]);
			g.lineTo(vert[0], vert[1]);
			g.endFill();
		}

		/* horizontial */
		fromc = 0;
		toc = map.num_col-1;
		for (i in range(0, map.num_row, 2)) {
			fromr = Std.random(map.num_row);
			tor = Std.random(map.num_row);

			var start = map.SectionCenter(fromr, fromc);
			var end = map.SectionCenter(tor, toc);

			vert[0] = 1;
			vert[1] = start.y + size;
			vert[2] = 1;
			vert[3] = start.y - size;

			vert[4] = map.width - 2;
			vert[5] = end.y - size;
			vert[6] = map.width - 2;
			vert[7] = end.y + size;

			g.lineStyle(0,0xFFFFFF);
			g.beginFill(0xFFFFFF);
			g.moveTo(vert[0], vert[1]);
			g.lineTo(vert[2], vert[3]);
			g.lineTo(vert[4], vert[5]);
			g.lineTo(vert[6], vert[7]);
			g.lineTo(vert[0], vert[1]);
			g.endFill();
		}

		bmp.draw(sprite);
		return bmp;
	}
}