
package com.teamname.lw.mesh;

import haxe.ds.Vector;

class MeshZone<T> {
	public var links(default, never) = new Vector<MeshZone<T>>(12);
	public var value(default, default) : T;
	public var x(default, null) : Int;
	public var y(default, null) : Int;
	public var sizeLog(default, null) : Int;
	public var size(get, null) : Int;

	public function new(x : Int, y : Int, sizeLog : Int, ?value : T) {
		if (x < 0 || y < 0) throw "Coordinates must be non-negative";
		if (sizeLog < 0) throw "sizeLog must be non-negative";
		this.x = x;
		this.y = y;
		this.sizeLog = sizeLog;
		this.value = value;
	}

	public function get_size() : Int {
		return 1 << sizeLog;
	}

	public function copy() : MeshZone<T> {
		return new MeshZone<T>(x, y, sizeLog, value);
	}

	public inline function keyPoints() : Array<Int> {
		if (sizeLog == 0) return [0];
		if (sizeLog == 1) return [0, size - 1];
		return [0, 1 << (sizeLog - 1) - 1, 1 << (sizeLog - 1), size - 1];
	}
}