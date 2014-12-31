/*
* A bunch of boxes of the same size.
*
* This works best if r/c are large and close to each other.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class Boxes {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height);

		var startx : Int, starty : Int, endx : Int, endy : Int;
		var pad : Int = 1;

		for (r in 0...map.num_row) {
			for (c in 0...map.num_col) {
				/* 1 out 2 chance to draw box */
				if (Std.random(2) == 0 ) {
					/*
					* if box is on the edge of the map i use
					* the absolute pixel
					*/
					if (c == 0)
						startx = pad+1;
					else
						startx = Std.int(map.sec_width*c+pad);

					if (r == 0)
						starty = pad+1;
					else
						starty = Std.int(map.sec_height*r+pad);

					if (c == map.num_col-1)
						endx = map.width-pad-2;
					else
						endx = Std.int(map.sec_width*(c+1)-pad);

					if (r == map.num_row-1)
						endy = map.height-pad-2;
					else
						endy = Std.int(map.sec_height*(r+1)-pad);

					bmp.fillRect(new Rectangle(startx, starty, endx-startx, endy-starty), 0xFF000000);
				}
			}
		}

		return bmp;
	}
}