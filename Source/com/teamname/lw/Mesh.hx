
package com.teamname.lw;

import haxe.ds.Vector;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.Assets;

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
		if (nw == null || nw.sizeLog != sizeLog ||
			ne == null || ne.sizeLog != sizeLog ||
			sw == null || sw.sizeLog != sizeLog ||
			se == null || se.sizeLog != sizeLog)
			return false;

		var nwl = nw.links;
		var nel = ne.links;
		var swl = sw.links;
		var sel = se.links;

		// Each zone should have at most one neighbor in each cardinal direction
		// Sorry, but that's twice faster :(
		if (nwl[Dir.DIR_NNW] != nwl[Dir.DIR_NNE] || nwl[Dir.DIR_ENE] != nwl[Dir.DIR_ESE] ||
			nwl[Dir.DIR_SSE] != nwl[Dir.DIR_SSW] || nwl[Dir.DIR_WSW] != nwl[Dir.DIR_WNW] ||
			nel[Dir.DIR_NNW] != nel[Dir.DIR_NNE] || nel[Dir.DIR_ENE] != nel[Dir.DIR_ESE] ||
			nel[Dir.DIR_SSE] != nel[Dir.DIR_SSW] || nel[Dir.DIR_WSW] != nel[Dir.DIR_WNW] ||
			swl[Dir.DIR_NNW] != swl[Dir.DIR_NNE] || swl[Dir.DIR_ENE] != swl[Dir.DIR_ESE] ||
			swl[Dir.DIR_SSE] != swl[Dir.DIR_SSW] || swl[Dir.DIR_WSW] != swl[Dir.DIR_WNW] ||
			sel[Dir.DIR_NNW] != sel[Dir.DIR_NNE] || sel[Dir.DIR_ENE] != sel[Dir.DIR_ESE] ||
			sel[Dir.DIR_SSE] != sel[Dir.DIR_SSW] || sel[Dir.DIR_WSW] != sel[Dir.DIR_WNW])
			return false;

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
						var t = nzl[i];
						if (t != null) {
							var u = t.links;
							for (j in 0...12) {
								var z = u[j];
								if (z == nw || z == ne || z == sw || z == se)
									u[j] = newZone;
							}
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

	public function addMeshFromMap(map_name : String, ?defaultValue : T) {
		var bitmapData = Assets.getBitmapData("maps/" + map_name + ".png");
		var w = Std.int(bitmapData.rect.width);
		var h = Std.int(bitmapData.rect.height);
		var arr = bitmapData.getVector(bitmapData.rect);
		trace(w,h);
		for (i in 0...w) {
			for (j in 0...h) {
				var r = (arr[j * w + i] & 0xFF0000) >> 16;
				var g = (arr[j * w + i] & 0xFF00) >> 8;
				var b = arr[j * w + i] & 0xFF;
				if(6*r + 3*g + b > 315)
					addZone(new MeshZone(i, j, 0, defaultValue));
			}
		}

		var dxs = Dir.xOffsets.map(function (d) return Std.int(d / 2));
		var dys = Dir.yOffsets.map(function (d) return Std.int(d / 2));

		for (i in 0...w) {
			//trace(i);
			for (j in 0...h) {
				var t = getZoneAt(i, j);
				if (t != null) {
					var z = t.links;
					for (k in 0...12) {
						var dx = dxs[k];
						var dy = dys[k];

						if (0 <= i + dx && i + dx < w && 0 <= j + dy && j + dy < h)
							z[k] = getZoneAt(i + dx, j + dy);
					}
				}
			}
		}
	}

	public function addRectangularMesh(x : Int, y : Int, w : Int, h : Int, ?defaultValue : T) {
		for (i in x...x + w) {
			//trace(i);
			for (j in y...y + h)
				addZone(new MeshZone(i, j, 0, defaultValue));
		}

		var dxs = Dir.xOffsets.map(function (d) return Std.int(d / 2));
		var dys = Dir.yOffsets.map(function (d) return Std.int(d / 2));

		for (i in 0...w) {
			//trace(i);
			for (j in 0...h) {
				var zl = getZoneAt(x + i, y + j).links;

				for (k in 0...12) {
					var dx = dxs[k];
					var dy = dys[k];

					if (0 <= i + dx && i + dx < w && 0 <= j + dy && j + dy < h)
						zl[k] = getZoneAt(x + i + dx, y + j + dy);
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
