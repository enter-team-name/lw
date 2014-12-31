/*
* One big, solid quad that takes up most of the map.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;

class BigQuad {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var vert = [];

		/* left side of map */
		vert[0] = RandNum(2, map.sec_width );
		vert[1] = RandNum(2, map.height - 3);

		/* top side of map */
		vert[2] = RandNum(map.sec_width + 1, map.width - 3 );
		vert[3] = RandNum(2				   , map.sec_height);

		/* right side of map */
		vert[4] = RandNum(map.width-map.sec_width , map.width  - 3);
		vert[5] = RandNum(map.sec_height + 1	  , map.height - 3);

		/* bottom side of map */
		vert[6] = RandNum(map.sec_width + 1			 , map.width - map.sec_width - 1);
		vert[7] = RandNum(map.height - map.sec_height, map.height - 3				);

		var bmp = new BitmapData(map.width, map.height);
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;

		g.lineStyle(0,0x000000);
		g.beginFill(0x000000);
		g.moveTo(vert[0], vert[1]);
		g.lineTo(vert[2], vert[3]);
		g.lineTo(vert[4], vert[5]);
		g.lineTo(vert[6], vert[7]);
		g.lineTo(vert[0], vert[1]);
		g.endFill();

		bmp.draw(sprite);
		return bmp;
	}
}