/*
* Randomly shaped hole.
*/

package com.teamname.lwmapgen.generator;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.generator.RandPoly;

import openfl.display.BitmapData;

class Hole {
	public function new() { }

	public function generate() : BitmapData {
		var map = Main.instance.map;
		map.background = 1;
		var randPoly = new RandPoly();
		return randPoly.generate();
	}
}