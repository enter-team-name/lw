/*
* Random boxes.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class RandBox {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height);

		var bwidth : Int, bheight : Int;


		for (r in 0...map.num_row) {
			for (c in 0...map.num_col) {
				var offset = map.Offset(r, c);
				var start = map.RandPointSection(1);

				/* +1 because we don't want 0 dimensions =] */
				bwidth  = Std.random(Std.int(map.sec_width) ) + 1;
				bheight = Std.random(Std.int(map.sec_height)) + 1;

				/*
				* if the box goes outside the section
				* then just make the box smaller
				* NOTE: -1 is for the padding
				*/
				if (start.x + bwidth > map.sec_width - 1)
					bwidth -= (start.x + bwidth) - (Std.int(map.sec_width) - 1);

				if (start.y + bheight > map.sec_height - 1)
					bheight -= (start.y + bheight) - (Std.int(map.sec_height) - 1);

				bmp.fillRect(new Rectangle(start.x+offset.x, start.y+offset.y, bwidth, bheight), 0xFF000000);
			}
		}

		return bmp;
	}
}