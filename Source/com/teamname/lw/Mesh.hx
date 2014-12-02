
package com.teamname.lw;

import haxe.ds.Vector;

import de.polygonal.ds.DLL; // Doubly Linked List

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Mesh<T> {
	var width(default, null) : Int;
	var height(default, null) : Int;
	var zoneList(default, null) = new DLL<MeshZone<T>>();
	var zoneTable(default, null) : Array<Array<MeshZone<T>>>;

	public function new(w : Int, h : Int) {
		width = w;
		height = h;
		zoneTable = [for (i in 0...w) [for (j in 0...h) null]];
	}

	public function addZone(z : MeshZone<T>) {
		if (z.x + z.size > width || z.y + z.size > height)
			throw "Zone out of bounds";

		for (i in z.x...z.x + z.size)
			for (j in z.y...z.y + z.size)
				if (zoneTable[i][j] != null)
					throw "Mesh zones can't intersect!";

		for (i in z.x...z.x + z.size)
			for (j in z.y...z.y + z.size)
				zoneTable[i][j] = z;

		zoneList.append(z);
	}

	public function removeZone(z : MeshZone<T>) : Bool {
		var res = zoneList.remove(z);
		if (res) {
			for (i in z.x...z.x + z.size)
				for (j in z.y...z.y + z.size)
					zoneTable[i][j] = null;
		}
		return res;
	}

	public inline function getZoneAt(x : Int, y : Int) {
		if (x < 0 || y < 0 || x >= width || y >= height)
			return null;
		else
			return zoneTable[x][y];
	}

	public function sortZones() {
		zoneList.sort(function (a, b) {
			if (a.y != b.y) return a.y - b.y;
			else return a.x - b.x;
		});
	}

	public inline function zoneCount() : Int {
		return zoneList.size();
	}

	public inline function iterator() {
		return zoneList.iterator();
	}

	// public inline function reverseIterator() {
	// 	// TODO
	// }

	public function toImage() : BitmapData {
		var res = new BitmapData(width, height, true /*transparent*/);
		for (z in zoneList) {
			var color = 0xFF000000 | Std.random(0xFFFFFF);
			res.fillRect(new Rectangle(z.x, z.y, z.size, z.size), color);
		}
		return res;
	}

	private function shouldMerge(x, y, sizeLog, nw : MeshZone<T>, ne : MeshZone<T>, sw : MeshZone<T>, se : MeshZone<T>) : Bool {
		for (z in [nw, ne, sw, se])
			if (z == null || z.sizeLog != sizeLog)
				return false;

		// Each zone should have at most one neighbor in each cardinal direction
		for (z in [nw, ne, sw, se])
			for (dir in 1...5)
				if (z.links[(3 * dir) % 12] != z.links[(3 * dir - 1) % 12])
					return false;

		// There should be zones diagonally adjecent to the new zone
		// Not sure why this is neccessary, but the original code checks it
		if (nw.links[Dir.DIR_NW] == null || ne.links[Dir.DIR_NE] == null &&
			sw.links[Dir.DIR_SW] == null || se.links[Dir.DIR_SE] == null)
			return false;

		// Zones should be properly connected to one another
		// (this is supposed to look like a table)
		if (                               nw.links[Dir.DIR_ESE] == ne && nw.links[Dir.DIR_SSE] == sw && nw.links[Dir.DIR_SE]  == se &&
			ne.links[Dir.DIR_WSW] == nw &&                                ne.links[Dir.DIR_SW]  == sw && ne.links[Dir.DIR_SSW] == se &&
			sw.links[Dir.DIR_NNE] == nw && sw.links[Dir.DIR_NE]  == ne &&                                sw.links[Dir.DIR_ENE] == se &&
			se.links[Dir.DIR_NW]  == nw && se.links[Dir.DIR_NNW] == ne && se.links[Dir.DIR_WNW] == sw                               )
			return false;

		// Not sure how this can be wrong, but let's check it just in case
		var size = 1 << sizeLog;
		if (nw.x != x        || nw.y != y        ||
			ne.x != x        || ne.y != y + size ||
			sw.x != x + size || sw.y != y        ||
			se.x != x + size || se.y != y + size)
			return false;

		return true;
	}

	private function mergeOnce(sizeLog : Int) : Bool {
		var size = 1 << sizeLog;
		var mergedAnything = false;
		for (i in 0...Std.int(width / size / 2)) {
			var x = i * 2 * size;
			for (j in 0...Std.int(height / size / 2)) {
				var y = j * 2 * size;
				trace(sizeLog, x, y);

				var nw = getZoneAt(x       , y       );
				var ne = getZoneAt(x       , y + size);
				var sw = getZoneAt(x + size, y       );
				var se = getZoneAt(x + size, y + size);

				if (shouldMerge(x, y, sizeLog, nw, ne, sw, se)) {
					var newZone = new MeshZone(x, y, sizeLog + 1, nw.value);

					for (i in 0...12)
						newZone.links[i] = [ne, se, sw, nw][Std.int(i / 3)];

					for (i in 0...12)
						for (j in 0...12)
							if ([nw, ne, sw, se].indexOf(newZone.links[i].links[j]) != -1)
								newZone.links[i].links[j] = newZone;

					removeZone(nw);
					removeZone(ne);
					removeZone(sw);
					removeZone(se);
					addZone(newZone);

					mergedAnything = true;
				}
			}
		}
		return mergedAnything;
	}

	public function merge(maxSizeLog : Int = 100) {
		for (i in 0...maxSizeLog) {
			if (!mergeOnce(i)) return;
		}
	}

	public function addRectangularMesh(x : Int, y : Int, w : Int, h : Int, ?defaultValue : T) {
		for (i in x...x + w)
			for (j in y...y + h)
				addZone(new MeshZone(i, j, 0, defaultValue));

		for (i in 0...w) {
			for (j in 0...h) {
				var z = getZoneAt(x + i, y + j);

				var f = function(dx, dy) {
					if (0 <= i + dx && i + dx < w &&
						0 <= j + dy && j + dy < h)
						return getZoneAt(x + i + dx, y + j + dy);
					else
						return null;
				}

				z.links[Dir.DIR_NNE] = f( 0, -1);
				z.links[Dir.DIR_NE]  = f( 1, -1);
				z.links[Dir.DIR_ENE] = f( 1,  0);
				z.links[Dir.DIR_ESE] = f( 1,  0);
				z.links[Dir.DIR_SE]  = f( 1,  1);
				z.links[Dir.DIR_SSE] = f( 0,  1);
				z.links[Dir.DIR_SSW] = f( 0,  1);
				z.links[Dir.DIR_SW]  = f(-1,  1);
				z.links[Dir.DIR_WSW] = f(-1,  0);
				z.links[Dir.DIR_WNW] = f(-1,  0);
				z.links[Dir.DIR_NW]  = f(-1, -1);
				z.links[Dir.DIR_NNW] = f( 0, -1);
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