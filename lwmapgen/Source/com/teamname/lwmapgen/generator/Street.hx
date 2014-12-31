/*
* A map that looks like a bunch of streets.
*
* This works best if r & c are rather large (but not too large).
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Street {
	public function new() { }

	private function rectfill(bmp : BitmapData, x1 : Int, y1 : Int, x2 : Int, y2 : Int, color : UInt) {
		bmp.fillRect(new Rectangle(x1, y1, x2-x1, y2-y1), color);
	}

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height, false, 0x000000);

		var main_row : Array<Int> = new Array<Int>();
		var main_col : Array<Int> = new Array<Int>();
		var r : Int, c : Int, tor : Int, toc : Int,
			size : Int, from : Int, way : Int;

		var MAX_MAIN_ROW = 3;
		var MAX_MAIN_COL = 3;

		/*
		* TODO: its possible only have 1 main and thats bad...
		* 2x3 is best... tho' it may not matter much.
		* What about basing the numbers off map.num_row/col??
		* yeah I like that better than macros.
		* maybe MMR = #rows % 4 + 1..
		*/

		/* pick the main rows/cols to branch from */
		for (i in 0...MAX_MAIN_ROW)
			main_row[i] = Std.random(map.num_row);
		for (i in 0...MAX_MAIN_COL)
			main_col[i] = Std.random(map.num_col);


		size = Std.int((map.sec_width > map.sec_height ? map.sec_width : map.sec_height)/8);
		size = (size == 0 ? 1 : size);


		/* branch off rows */
		for (i in 0...MAX_MAIN_ROW) {
			r = main_row[i];

			/* draw main row */
			var start = map.SectionCenter(r, 0);
			var end = map.SectionCenter(r, map.num_col-1);
			
			rectfill(bmp, start.x, start.y-size, end.x, end.y+size, 0xFFFFFFFF);

			/* do the branches */
			from = Std.random(2);
			for (c in range(from, map.num_col, 2)) {
				var start = map.SectionCenter(r, c);

				way = Std.random(3);

				/* draw up */
				if ( r != 0 && (way == 0 || way == 2) ) {
					tor = Std.random(r);
					var end = map.SectionCenter(tor, c);
					rectfill(bmp, start.x-size, start.y, end.x+size, end.y, 0xFFFFFFFF);
				}

				/* draw down */
				if ( r != map.num_row-1 && (way == 1 || way == 2) ) {
					tor = RandNum(r, map.num_row-r);
					var end = map.SectionCenter(tor, c);
					rectfill(bmp, start.x-size, start.y, end.x+size, end.y, 0xFFFFFFFF);
				}
			}
		}


		/* branch off cols */
		for (i in 0...MAX_MAIN_COL) {
			c = main_col[i];

			/* draw main col */
			var start = map.SectionCenter(0, c);
			var end = map.SectionCenter(map.num_row-1, c);
			rectfill(bmp, start.x-size, start.y, end.x+size, end.y, 0xFFFFFFFF);


			/* do the branches */
			from = Std.random(2);
			for (r in range(from, map.num_row, 2)) {
				var start = map.SectionCenter(r, c);

				way = Std.random(3);

				/* draw left */
				if ( c != 0 && (way == 0 || way == 2) ) {
					toc = Std.random(c);
					var end = map.SectionCenter(r, toc);
                    rectfill(bmp, start.x, start.y-size, end.x, end.y+size, 0xFFFFFFFF);
				}

				/* draw right */
				if ( c != map.num_col-1 && (way == 1 || way == 2) ) {
					toc = RandNum(c, map.num_col-c);
					var end = map.SectionCenter(r, toc);
                    rectfill(bmp, start.x-size, start.y-size, end.x, end.y+size, 0xFFFFFFFF);
				}
			}
		}

		return bmp;
	}
}