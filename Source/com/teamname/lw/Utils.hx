package com.teamname.lw;

import de.polygonal.ds.M;

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