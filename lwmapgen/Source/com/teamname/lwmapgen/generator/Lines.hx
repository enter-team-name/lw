/*
* A grid of random lines.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.generator.Cut;

import openfl.display.BitmapData;

class Lines {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		var bmp = new BitmapData(map.width, map.height, false, 0x000000);
		var cut = new Cut();
		return cut.generate(bmp);
	}
}