
package com.teamname.lw.mesh;

import com.teamname.lw.Utils;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

using com.teamname.lw.macro.MeshMacros;

class Mesh<T> {
	public var width(default, null) : Int;
	public var height(default, null) : Int;
	public var defaultValue(default, default) : T;

	public function new(w : Int, h : Int, ?defaultValue : T, ?zones : Iterable<MeshZone<T>>) {
		width = w;
		height = h;
		this.defaultValue = defaultValue;
		if (zones != null)
			for (z in zones) addZone(z);
	}

	// Preferebly z.links[dir] should appear after z for most z
	public function directionalIterator(dir : Dir = Dir.DIR_SE) : Iterator<MeshZone<T>> {
		throw "This method should be implemented in subclasses";
	}

	public inline function iterator() : Iterator<MeshZone<T>>  {
		return directionalIterator(Dir.DIR_SE);
	}

	private function addZone(z : MeshZone<T>) {
		throw "This method should be implemented in subclasses";
	}

	private function removeZone(z : MeshZone<T>) : Bool {
		throw "This method should be implemented in subclasses";
	}

	public function getZone(x : Int, y : Int) : MeshZone<T> {
		for (z in this) {
			if (z.x <= x && x < z.x + z.size && z.y <= y && y < z.y + z.size)
				return z;
		}
		return null;
	}

	public function getZoneByKeyPoint(x : Int, y : Int) : MeshZone<T> {
		return getZone(x, y);
	}

	public function toBitmap(borderColor : Int = 0xFF0000FF, fillColor : Int = 0xFFFFFFFF) : BitmapData {
		var res = new BitmapData(width, height, true /*transparent*/);
		for (z in this) {
			var rect = new Rectangle(z.x, z.y, z.size, z.size);
			res.fillRect(rect, borderColor);
			rect.inflate(-1, -1);
			res.fillRect(rect, fillColor);
		}
		return res;
	}

	private function shouldMerge(x : Int, y : Int, sizeLog : Int, nw : MeshZone<T>, ne : MeshZone<T>, sw : MeshZone<T>, se : MeshZone<T>) : Bool {
		for (z in [nw, ne, sw, se]) {
			if (z == null || z.sizeLog != sizeLog)
				return false;

			// Each zone should have at most one neighbor in each cardinal direction
			var zl = z.links;
			if (zl[Dir.DIR_NNW] != zl[Dir.DIR_NNE] || zl[Dir.DIR_ENE] != zl[Dir.DIR_ESE] ||
				zl[Dir.DIR_SSE] != zl[Dir.DIR_SSW] || zl[Dir.DIR_WSW] != zl[Dir.DIR_WNW])
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

	private function merge4Zones(x : Int, y : Int, sizeLog : Int, nw : MeshZone<T>, ne : MeshZone<T>, sw : MeshZone<T>, se : MeshZone<T>) {
		var newZone = new MeshZone<T>(x, y, sizeLog + 1, defaultValue);

		var nwl = nw.links;
		var nel = ne.links;
		var swl = sw.links;
		var sel = se.links;
		var nzl = newZone.links;


		nzl.fill(nwl[10], nwl[11], nel[0] , nel[1] ,
		         nwl[9] ,                   nel[2] ,
		         swl[8] ,                   sel[2] ,
		         swl[7] , swl[6] , sel[5] , sel[4] );

		for (t in nzl) {
			if (t != null) {
				var tl = t.links;
				for (j in 0...12) {
					var z = tl[j];
					if (z == nw || z == ne || z == sw || z == se)
						tl[j] = newZone;
				}
			}
		}

		removeZone(nw);
		removeZone(ne);
		removeZone(sw);
		removeZone(se);
		addZone(newZone);
	}

	public function mergeIteration(sizeLog : Int) : Bool {
		var size = 1 << sizeLog;
		var mergedSomething = false;
		for (x in new Range(0, width, 2 * size)) {
			trace(sizeLog, x);
			for (y in new Range(0, height, 2 * size)) {
				//trace(sizeLog, x, y);

				var nw = getZoneByKeyPoint(x       , y       );
				var ne = getZoneByKeyPoint(x + size, y       );
				var sw = getZoneByKeyPoint(x       , y + size);
				var se = getZoneByKeyPoint(x + size, y + size);

				if (shouldMerge(x, y, sizeLog, nw, ne, sw, se)) {
					merge4Zones(x, y, sizeLog, nw, ne, sw, se);
					mergedSomething = true;
				}
			}
		}
		return mergedSomething;
	}

	public function mergeAll(maxSizeLog : Int = 100) {
		for (i in 0...maxSizeLog + 1) {
			if (!mergeIteration(i)) return;
		}
	}

	public function splitZone(z : MeshZone<T>) {
		for (z1 in z.links) {
			// No infinite recursion because z.size is strictly increasing, and is bounded by mesh size
			if (z1.sizeLog > z.sizeLog) splitZone(z1);
		}

		var size = 1 << (z.sizeLog - 1);
		var nw = new MeshZone<T>(z.x       , z.y       , z.sizeLog - 1, z.value);
		var ne = new MeshZone<T>(z.x + size, z.y       , z.sizeLog - 1, z.value);
		var sw = new MeshZone<T>(z.x       , z.y + size, z.sizeLog - 1, z.value);
		var se = new MeshZone<T>(z.x + size, z.y + size, z.sizeLog - 1, z.value);

		var zl = z.links;
		var nwl = nw.links;
		var nel = ne.links;
		var swl = sw.links;
		var sel = se.links;

		nwl.fill(zl[10], zl[11], zl[11], zl[1] ,
		         zl[9] ,                 ne    ,
		         zl[9] ,                 ne    ,
		         zl[8] , sw    , sw    , se    );

		nel.fill(zl[11], zl[0] , zl[0] , zl[1] ,
		         nw    ,                 zl[2] ,
		         nw    ,                 zl[2] ,
		         sw    , se    , se    , zl[3] );
		
		swl.fill(zl[9] , nw    , nw    , ne    ,
		         zl[8] ,                 se    ,
		         zl[8] ,                 se    ,
		         zl[7] , zl[6] , zl[6] , zl[5] );

		sel.fill(nw    , ne    , ne    , zl[2] ,
		         sw    ,                 zl[3] ,
		         sw    ,                 zl[3] ,
		         zl[6] , zl[5] , zl[5] , zl[4] );

		removeZone(z);
		addZone(nw);
		addZone(ne);
		addZone(sw);
		addZone(se);

		for (z1 in zl) {
			fixLinks(z1);
		}
	}

	private function fixLinks(z : MeshZone<T>) {
		var w = z.x;
		var e = z.x + z.size - 1;
		var n = z.y;
		var s = z.y + z.size - 1;
		z.links.fill(getNextCellZone(w, n, -1, -1), getNextCellZone(w, n,  0, -1), getNextCellZone(e, n,  0, -1), getNextCellZone(e, n,  1, -1),
		             getNextCellZone(w, n, -1,  0),                                                               getNextCellZone(e, n,  1,  0),
		             getNextCellZone(w, s, -1,  0),                                                               getNextCellZone(e, s,  1,  0),
		             getNextCellZone(w, s, -1,  1), getNextCellZone(w, s,  0,  1), getNextCellZone(e, s,  0,  1), getNextCellZone(e, s,  1,  1));
	}

	// TODO Portals
	private inline function getNextCellX(x : Int, y : Int, dx : Int, dy : Int) {
		return x + dx;
	}

	// TODO Portals
	private inline function getNextCellY(x : Int, y : Int, dx : Int, dy : Int) {
		return y + dy;
	}

	private inline function getNextCellZone(x : Int, y : Int, dx : Int, dy : Int) {
		return getZoneByKeyPoint(getNextCellX(x, y, dx, dy), getNextCellY(x, y, dx, dy));
	}

	public function addRectangle(x : Int, y : Int, w : Int, h : Int, ?pred : Int -> Int -> Bool) {
		for (i in 0...w) {
			//trace(i);
			for (j in 0...h)
				if (pred == null || pred(i, j))
					addZone(new MeshZone<T>(x + i, y + j, 0, defaultValue));
		}

		for (i in 0...w) {
			trace(i);
			for (j in 0...h) {
				if (pred == null || pred(i, j)) {
					var zl = getZoneByKeyPoint(x + i, y + j).links;
	
					for (k in 0...12) {
						var dx = Dir.xOffsets[k];
						var dy = Dir.yOffsets[k];
	
						if (0 <= i + dx && i + dx < w && 0 <= j + dy && j + dy < h && (pred == null || pred(i + dx, j + dy)))
							zl[k] = getZoneByKeyPoint(x + i + dx, y + j + dy);
					}
				}
			}
		}
	}

	public function addBitmap(bmp : BitmapData, x : Int = 0, y : Int = 0, ?pred : Int -> Bool) {
		if (pred == null) {
			pred = function(c) {
				var r = (c >> 16) & 0xFF;
				var g = (c >> 8) & 0xFF;
				var b = c & 0xFF;
				return 6 * r + 3 * g + b > 315;
			};
		}
		addRectangle(x, y, bmp.width, bmp.height, function(x, y) {
			return pred(bmp.getPixel(x, y));
		});
	}
}