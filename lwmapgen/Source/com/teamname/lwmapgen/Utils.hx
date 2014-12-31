package com.teamname.lwmapgen;

class Range {
	var i:Int;
	var from:Int;
	var to:Int;
	var step:Int;

	public function new(from : Int, ?to : Int, ?step : Int) {
		if(step == 0)
			throw "Range step must not be zero";

		if (to == null) {
			i = this.from = 0;
			this.to = from;
		}
		else {
			this.from = from;
			this.to = to;
			if (step == null)
				this.step = 1;
			else
				this.step = step;
			i = from;
		}
	}

	public function hasNext() {
		return (step > 0) ? i < to : i > to;
	}

	public function next() {
		return((i += step) - step);
	}
}

class Utils {
	public static function range(from : Int, ?to : Int, ?step : Int) {
		return new Range(from, to, step);
	}

	public static function RandNum(from : Dynamic, to : Dynamic) : Int {
		return Std.random(Std.int(to)-Std.int(from)+1)+Std.int(from);
	}
}