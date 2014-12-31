/*
* Random bubbles.
*
* start with a wall-filled field - then erase a circle,
* then fill a smaller one inside it - repeat
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;

class Bubbles {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height, false, 0xFF000000);
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;

		var size : Int,
			outradius : Int, inradius : Int, midradius : Int,
			bubblesx : Int, bubblesy : Int, /* number of bubbles in a row or column */
			numbubbles : Int;

		/*
		* outer is the main bubble
		* inner is the black dot in the bubble
		* what's the middle??
		*/

		size = Std.int(map.sec_width > map.sec_height ? map.sec_width : map.sec_height);
		outradius = RandNum(size/3, size);
		inradius  = RandNum(outradius/1.5, outradius*(7.0/8.0));

		midradius = Std.int((outradius + inradius) / 2);
		midradius = (midradius == 0 ? 1 : midradius);


		bubblesx = Std.int(map.sec_width  / midradius);
		bubblesy = Std.int(map.sec_height / midradius);

		numbubbles = (bubblesx * bubblesy);
		numbubbles = (numbubbles == 0 ? 1 : numbubbles);

		for (r in 0...map.num_row) {
			for (c in 0...map.num_col) {
				for (b in 0...numbubbles) {
					var center = map.RandPointSectionOffset(r, c, 0);

					/*
					* center.x *= (center.x / bubblesx);
					* center.y *= (center.y / bubblesy);
					*/

					g.beginFill(0xFFFFFF);
					g.drawCircle(center.x, center.y, outradius);
					g.endFill();
					g.beginFill(0x000000);
					g.drawCircle(center.x, center.y, inradius);
					g.endFill();
				}
			}
		}

		bmp.draw(sprite);
		return bmp;
	}
}