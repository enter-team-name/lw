package com.teamname.lwmapgen.generator;

import openfl.display.BitmapData;
import com.teamname.lwmapgen.generator.*;

class GeneratorInterface {
	var generators : Array<Dynamic> = [];

	public function new() {
		generators = [
			new BigQuad(),
			new Boxes(),
			new Bubbles(),
			new Circles(),
			new Circuit(),
			new Hole(),
			new Lines(),
			new RandBox(),
			new RandPoly(),
			new RandPolyCut(),
			new Street(),
			new Worms() ];
	}

	public function call(id : Int) : BitmapData {
		return generators[id].generate();
	}

	public function count() : Int {
		return generators.length;
	}
}