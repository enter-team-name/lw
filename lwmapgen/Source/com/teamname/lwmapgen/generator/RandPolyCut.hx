/*
* Do rand_poly then cut lines across it.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.generator.Cut;

import openfl.display.BitmapData;

class RandPolyCut {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height);
		var cut = new Cut();
		var randPoly = new RandPoly();
		return cut.generate(randPoly.generate());
	}
}