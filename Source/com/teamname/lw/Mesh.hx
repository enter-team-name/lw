
package com.teamname.lw;

import haxe.ds.Vector;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

import com.teamname.lw.Utils;

class Mesh<T> {
	var width(default, null) : Int;
	var height(default, null) : Int;
	var zoneTable(default, null) : Array<Array<MeshZone<T>>>;

	public function new(w : Int, h : Int) {
		width = w;
		height = h;
		zoneTable = [for (i in 0...w) [for (j in 0...h) null]];
	}

	public function addZone(z : MeshZone<T>) {
		if (z.x + z.size > width || z.y + z.size > height)
			throw "Zone out of bounds";

		zoneTable[z.x][z.y] = z;
	}

	public function removeZone(z : MeshZone<T>) : Bool {
		if (zoneTable[z.x][z.y] == z) {
			zoneTable[z.x][z.y] = null;
			return true;
		}
		return false;
	}

	public inline function getZoneAt(x : Int, y : Int) {
		if (x < 0 || y < 0 || x >= width || y >= height)
			return null;
		else
			return zoneTable[x][y];
	}

	public function toImage() : BitmapData {
		var res = new BitmapData(width, height, true /*transparent*/);
		for (i in 0...width) {
			for (j in 0...height) {
				var z = getZoneAt(i, j);
				if (z == null) continue;
				var color = 0xFF000000 | Std.random(0xFFFFFF);
				res.fillRect(new Rectangle(z.x, z.y, z.size, z.size), color);
			}
		}
		return res;
	}

	private function shouldMerge(x, y, sizeLog, nw : MeshZone<T>, ne : MeshZone<T>, sw : MeshZone<T>, se : MeshZone<T>) : Bool {
		for (z in [nw, ne, sw, se])
			if (z == null || z.sizeLog != sizeLog)
				return false;

		// Each zone should have at most one neighbor in each cardinal direction
		for (z in [nw, ne, sw, se]) {
			var zl = z.links;
			for (dir in 1...5)
				if (zl[(3 * dir) % 12] != zl[(3 * dir - 1) % 12])
					return false;
		}

		var nwl = nw.links;
		var nel = ne.links;
		var swl = sw.links;
		var sel = se.links;

		// There should be zones diagonally adjecent to the new zone
		// Not sure why this is neccessary, but the original code checks it
		if (nwl[Dir.DIR_NW] == null || nel[Dir.DIR_NE] == null &&
			swl[Dir.DIR_SW] == null || sel[Dir.DIR_SE] == null)
			return false;

		// Zones should be properly connected to one another
		// (this is supposed to look like a table)
		if (                          nwl[Dir.DIR_ESE] != ne || nwl[Dir.DIR_SSE] != sw || nwl[Dir.DIR_SE]  != se ||
			nel[Dir.DIR_WSW] != nw ||                           nel[Dir.DIR_SW]  != sw || nel[Dir.DIR_SSW] != se ||
			swl[Dir.DIR_NNE] != nw || swl[Dir.DIR_NE]  != ne ||                           swl[Dir.DIR_ENE] != se ||
			sel[Dir.DIR_NW]  != nw || sel[Dir.DIR_NNW] != ne || sel[Dir.DIR_WNW] != sw                          )
			return false;

		// Not sure how this can be wrong, but let's check it just in case
		var size = 1 << sizeLog;
		if (nw.x != x        || nw.y != y        ||
			ne.x != x + size || ne.y != y        ||
			sw.x != x        || sw.y != y + size ||
			se.x != x + size || se.y != y + size)
			return false;

		return true;
	}

	private function mergeOnce(sizeLog : Int) : Bool {
		var size = 1 << sizeLog;
		var mergedSomething = false;
		for (x in new Range(0, width, 2 * size)) {
			trace(sizeLog, x);
			for (y in new Range(0, height, 2 * size)) {
				//trace(sizeLog, x, y);

				var nw = getZoneAt(x       , y       );
				var ne = getZoneAt(x + size, y       );
				var sw = getZoneAt(x       , y + size);
				var se = getZoneAt(x + size, y + size);

				if (shouldMerge(x, y, sizeLog, nw, ne, sw, se)) {
					var newZone = new MeshZone(x, y, sizeLog + 1, nw.value);

					var nwl = nw.links;
					var nel = ne.links;
					var swl = sw.links;
					var sel = se.links;
					var nzl = newZone.links;

					for (i in 0...3 ) nzl[i] = nel[i];
					for (i in 3...6 ) nzl[i] = sel[i];
					for (i in 6...9 ) nzl[i] = swl[i];
					for (i in 9...12) nzl[i] = nwl[i];

					for (i in 0...12) {
						var u = nzl[i].links;
						for (j in 0...12) {
							var z = u[j];
							if (z == nw || z == ne || z == sw || z == se)
								u[j] = newZone;
						}
					}

					removeZone(nw);
					removeZone(ne);
					removeZone(sw);
					removeZone(se);
					addZone(newZone);
					mergedSomething = true;
				}
			}
		}
		return mergedSomething;
	}

	public function merge(maxSizeLog : Int = 100) {
		for (i in 0...maxSizeLog) {
			if (!mergeOnce(i)) return;
		}
	}

	public function addRectangularMesh(x : Int, y : Int, w : Int, h : Int, ?defaultValue : T) {
		for (i in x...x + w) {
			//trace(i);
			for (j in y...y + h)
				addZone(new MeshZone(i, j, 0, defaultValue));
		}

		for (i in 0...w) {
			//trace(i);
			for (j in 0...h) {
				var z = getZoneAt(x + i, y + j);

				for (k in 0...12) {
					var d : Dir = k;
					var dx = Std.int(d.xOffset() / 2);
					var dy = Std.int(d.yOffset() / 2);
					if (i == 0 && j == 0) trace(k, d, dx, dy);

					if (0 <= i + dx && i + dx < w && 0 <= j + dy && j + dy < h)
						z.links[k] = getZoneAt(x + i + dx, y + j + dy);
				}
			}
		}
	}
}

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

	public function get_size() {
		return 1 << sizeLog;
	}
}
