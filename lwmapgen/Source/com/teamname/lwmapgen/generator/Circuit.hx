/*
* A map that looks like a circuit board.
*
* "Wells" are just big circles.
* "Pipes" are just lines that connect wells.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import haxe.ds.Vector;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import Math;

class Circuit {
	var size : Int;
	var count : Vector<Int>;
	var grid : Vector<Vector<Int>>;
	var bmp : BitmapData;
	var map : com.teamname.lwmapgen.Map;

	public function new() { }

	private function rectfill(bmpLocal : BitmapData, x1 : Int, y1 : Int, x2 : Int, y2 : Int, color : UInt) {
		bmpLocal.fillRect(new Rectangle(x1, y1, x2-x1, y2-y1), color);
	}

	/*
	* flip = 0 for front well connections
	* flip = 1 for back well connections
	*
	* its just makes the map look & play better
	*/

	private function draw_pipe(fromr : Int, fromc : Int, tor : Int, toc : Int, flip : Int) {
		if (fromc < toc) {
			/* up/down then across */
			if (flip == 0) {
				/* go up/down to reach target */
				var from = map.SectionCenter(fromr, fromc);
				var to   = map.SectionCenter(tor, fromc);
				rectfill(bmp, from.x-size, from.y, to.x+size, to.y, 0xFFFFFF);

				/* across some num of sections */
				var from = map.SectionCenter(tor, fromc);
				var to   = map.SectionCenter(tor, toc);
				rectfill(bmp, from.x, from.y-size, to.x, to.y+size, 0xFFFFFF);
			}
			/* across then up/down */
			else {
				/* across some num of sections */
				var from = map.SectionCenter(fromr, fromc);
				var to   = map.SectionCenter(fromr, toc);
				rectfill(bmp, from.x, from.y-size, to.x, to.y+size, 0xFFFFFF);

				/* go up/down to reach target */
				var from = map.SectionCenter(fromr, toc);
				var to   = map.SectionCenter(tor, toc);
				rectfill(bmp, from.x-size, from.y, to.x+size, to.y, 0xFFFFFF);
			}
		}
		else if (fromc > toc) {
			/* across then up/down */
			if (flip == 0) {
				/* across some num of sections */
				var from = map.SectionCenter(fromr, fromc);
				var to   = map.SectionCenter(fromr, toc);
				rectfill(bmp, from.x, from.y-size, to.x, to.y+size, 0xFFFFFF);

				/* go up/down to reach target */
				var from = map.SectionCenter(fromr, toc);
				var to   = map.SectionCenter(tor, toc);
				rectfill(bmp, from.x-size, from.y, to.x+size, to.y, 0xFFFFFF);
			}
			/* up/down then across */
			else {
				/* go up/down to reach target */
				var from = map.SectionCenter(fromr, fromc);
				var to   = map.SectionCenter(tor, fromc);
				rectfill(bmp, from.x-size, from.y, to.x+size, to.y, 0xFFFFFF);

				/* across some num of sections */
				var from = map.SectionCenter(tor, fromc);
				var to   = map.SectionCenter(tor, toc);
				rectfill(bmp, from.x, from.y-size, to.x, to.y+size, 0xFFFFFF);
			}
		}
		else {
			/* go up/down to reach target */
			var from = map.SectionCenter(fromr, fromc);
			var to   = map.SectionCenter(tor, toc);
			rectfill(bmp, from.x-size, from.y, to.x+size, to.y, 0xFFFFFF);
		}
	}

	/* connect all wells on in row */
	private function connect_rows() {
		var fromc : Int = -1, toc : Int = -1;

		for (r in 0...map.num_row) {
			/* can't connect if there's not 2 or more... */
			if (count[r] < 2)
				continue;

			/* find first c... */
			var c = 0;
			while (c < map.num_col) {
				if (grid[r][c] == 1) {
					fromc = c;
					break;
				}
				c++;
			}

			/* find last c... */
			c++;
			while (c < map.num_col) {
				if (grid[r][c] == 1)
					toc = c;
				c++;
			}

			draw_pipe(r, fromc, r, toc, 0);
		}
	}

	/* connect the first well on each row */
	/* TODO: I don't think this works 100% */

	private function connect_front() {
		var fromr : Int = -1, fromc : Int = -1, tor : Int = -1, toc : Int = -1;

		var r = 0;
		while (r < map.num_row) {
			if (count[r] == 0)
				continue;

			fromr = r;
			/* find first well */
			for (c in 0...map.num_col) {
				if (grid[fromr][c] == 1) {
					fromc = c;
					break;
				}
			}

			/* tor = -1; */
			/* find next row with a well */
			r++;
			while (r < map.num_row) {
				if (count[r] > 0) {
					tor = r;
					break;
				}
				r++;
			}
			/* there might be no other wells after from row */
			if (r == map.num_row)
				break;

			/* find first well on to row */
			for (c in 0...map.num_col) {
				if (grid[tor][c] == 1) {
					toc = c;
					break;
				}
			}

			draw_pipe(fromr, fromc, tor, toc, 0);
			r = tor;
		}
	}

	/* connect the last well on each row */
	/* TODO: I don't think this works 100% */

	private function connect_back() { 
		var fromr : Int = -1, fromc : Int = -1, tor : Int = -1, toc : Int = -1;

		var r = 0;
		while (r < map.num_row) {
			if (count[r] == 0)
				continue;

			fromr = r;
			/* find last well */ 
			for (c in range(map.num_col-1,-1,-1)) {
				if (grid[fromr][c] == 1) {
					fromc = c;
					break;
				}
			}

			/* tor = -1; */
			/* find next row with well */
			r++;
			while (r < map.num_row) {
				if (count[r] > 0) {
					tor = r;
					break;
				}
				r++;
			}
			/* there might not be another row after from row */
			if (r == map.num_row)
				break;

			/* find last well */ 
			for (c in range(map.num_col-1,-1,-1)) {
				if (grid[tor][c] == 1) {
					toc = c;
					break;
				}
			}

			draw_pipe(fromr, fromc, tor, toc, 1);
			r = tor;
		}
	}


	private function connect_mid() {
		var fromr : Int = -1, fromc : Int = -1, tor : Int = -1, toc : Int = -1,
			mid : Int, i : Int;

		var r = 0;
		while (r < map.num_row) {
			if (count[r] == 0)
				continue;

			fromr = r;

			/* find first middle well */
			mid = Std.int(count[fromr]/2);
			i = 0;
			for (c in 0...map.num_col) {
				if (grid[fromr][c] == 1) {
					fromc = c;
					if (i == mid)
						break;
					i++;
				}
			}


			/* tor = -1; */
			/* find to row */
			r++;
			while (r < map.num_row) {
				if (count[r] > 0) {
					tor = r;
					break;
				}
				r++;
			}
			/* there might not be another row after from row */
			if (r == map.num_row)
				break;

			/* find first middle well */
			mid = Std.int(count[tor]/2);
			i = 0;
			for (c in 0...map.num_col) {
				if (grid[tor][c] == 1) {
					toc = c;
					if (i == mid)
						break;
					i++;
				}
			}

			draw_pipe(fromr, fromc, tor, toc, 0);
			r = tor;
		}
	}

	public function generate() : BitmapData {
		map = Main.instance.map;
		bmp = new BitmapData(map.width, map.height, false, 0x000000);
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;

		grid  = new Vector<Vector<Int>>(map.num_row);
		for (i in 0...map.num_row)
			grid[i] = new Vector<Int>(map.num_col);

		count = new Vector<Int>(map.num_row);

		var do_cut : Int;
		var radius = Std.int((map.sec_width > map.sec_height ? map.sec_width : map.sec_height)/4.0);
		radius = (radius == 0 ? 1 : radius );

		size = Std.int((map.sec_width > map.sec_height ? map.sec_width : map.sec_height)/12.0);
		size = (size == 0 ? 1 : size);

		for (r in 0...map.num_row) {
			count[r] = 0;
			for (c in 0...map.num_col) {
				if ( (r == 0 || r == map.num_row-1)
						&& (c == 0 || c == map.num_col/2 || c == map.num_col-1) )
					do_cut = 1;
				else
					do_cut = Std.random(4);

				if (do_cut != 1) {
					grid[r][c] = 0;
					continue;
				}

				var center = map.SectionCenter(r, c);

				g.beginFill(0xFFFFFF);
				g.drawCircle(center.x, center.y, radius);
				g.endFill();

				grid[r][c] = 1;
				count[r] += 1;
			}
		}

		connect_rows();
		connect_front();
		connect_back();
		connect_mid();

		// redraw outline
		// TODO: once in a while if cuts off the edge.. 
		g.lineStyle(1, 0x000000);
		g.drawRect(0, 0, map.width - 1, map.height - 1);
		
		bmp.draw(sprite);
		return bmp;
	}
}