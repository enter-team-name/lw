package com.teamname.lw;

import de.polygonal.ds.M;

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
		return i < to;
	}

	public function next() {
		return((i += step) - step);
	}
}

class Utils {
	public static function max(it : Iterable<Int>) : Int {
		var res : Null<Int> = null;
		for (x in it) {
			if (res == null || res < x) res = x;
		}
		return res;
	}

	public static function min(it : Iterable<Int>) : Int {
		var res : Null<Int> = null;
		for (x in it) {
			if (res == null || res > x) res = x;
		}
		return res;
	}

	public static function any(it : Iterable<Bool>) : Bool {
		for (x in it) {
			if (x) return true;
		}
		return false;
	}

	public static function all(it : Iterable<Bool>) : Bool {
		for (x in it) {
			if (!x) return false;
		}
		return true;
	}
}