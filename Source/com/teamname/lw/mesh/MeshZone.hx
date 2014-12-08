
package com.teamname.lw.mesh;

import haxe.ds.Vector;

import de.polygonal.ds.Hashable;

class MeshZone<T> implements Hashable {
	public static inline var MAX_SIZE_LOG = 32;

	public var links(default, never) = new Vector<MeshZone<T>>(12);
	public var value(default, default) : T;
	public var x(default, null) : Int;
	public var y(default, null) : Int;
	public var sizeLog(default, null) : Int;
	public var size(get, null) : Int;

	/**
	 * A unique, unsigned 32-bit integer key.<br/>
	 * A hash table transforms this key into an index of an array element by using a hash function.<br/>
	 * <warn>This value should never be changed by the user.</warn>
	 */
	public var key : Int = Std.random(0xFFFFFF);

	public function new(x : Int, y : Int, sizeLog : Int, ?value : T) {
		#if debug
		if (x < 0 || y < 0) throw "Coordinates must be non-negative";
		if (sizeLog < 0) throw "sizeLog must be non-negative";
		if (sizeLog >= MAX_SIZE_LOG) throw "Zone is too big";
		var size = 1 << sizeLog;
		if (x % size != 0 || y % size != 0) throw "Coordinates must be divisible by size";
		#end
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

	public inline function fillLinks(x10, x11, x00, x01,
		                             x09,           x02,
		                             x08,           x03,
		                             x07, x06, x05, x04) {
		var l = links;
		l[0]  = x00;
		l[1]  = x01;
		l[2]  = x02;
		l[3]  = x03;
		l[4]  = x04;
		l[5]  = x05;
		l[6]  = x06;
		l[7]  = x07;
		l[8]  = x08;
		l[9]  = x09;
		l[10] = x10;
		l[11] = x11;
	}
}