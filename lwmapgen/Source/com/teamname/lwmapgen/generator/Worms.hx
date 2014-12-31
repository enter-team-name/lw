/*
* Random little worms.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import Math;

class Worms {
	public function new() { }

	private function filled(bmp : BitmapData, centerx : Int, centery : Int, rad : Int, startdeg : Int, col : UInt, seg : Int) : Int {
		var deg : Int,
			check_degrees : Int;

		/*
		* int seg is the current segment - if this is the first segment of a
		* worm (seg = 0) check 360 degrees around it instead of just 180
		*/

		if (0 == seg)
			check_degrees = 180;
		else
			check_degrees = 90;

		for (deg in range(startdeg-check_degrees, startdeg+check_degrees, 5))
			if ( bmp.getPixel(Std.int(centerx+(rad*Math.cos(Math.PI*deg/180))), Std.int(centery+(rad*Math.sin(Math.PI*deg/180)))) == col )
				return 1;

		return 0;
	}

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height);
		
		var centerx : Int, centery : Int,
			radius : Int, segments : Int,
			degree : Int, change : Int;

		/* 5-15 */
		radius = Std.random(10)+5;
		segments = Std.random(10)+5;


		for (r in 0...map.num_row) {
			for (c in 0...map.num_col) {
				var center = map.RandPointSectionOffset(r, c, 0);

				degree = Std.random(360);

				for (segs in 0...segments) {
					/* -15 to 14 */
					change = Std.random(30)-15;
					degree += change;

					center.x += Std.int(radius*Math.cos(Math.PI*degree/180));
					center.y += Std.int(radius*Math.sin(Math.PI*degree/180));

					if (filled(bmp, center.x, center.y, radius+1, degree, 0x000000, segs) == 0) {
						var sprite : Sprite = new Sprite();
						var g = sprite.graphics;
						g.beginFill(0x000000);
						g.drawCircle(center.x, center.y, radius);
						g.endFill();
						bmp.draw(sprite);
					}
					else
						/* encountered another worm, stopping... */
						break;
				}
			}
		}

		return bmp;
	}
}