
package com.teamname.lw.mesh;

import com.teamname.lw.macro.UnrollLoopMacros.*;
import com.teamname.lw.Utils.*;

import de.polygonal.ds.Array2;
import de.polygonal.ds.HashSet;
import de.polygonal.ds.M;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Mesh<T> {
	public var width(default, null) : Int;
	public var height(default, null) : Int;
	public var defaultValue(default, default) : T;

	public function new(w : Int, h : Int, ?defaultValue : T, ?zones : Iterable<MeshZone<T>>) {
		width = w;
		height = h;
		this.defaultValue = defaultValue;
		if (zones == null)
			initZones();
		else
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
		for (i in 0...MeshZone.MAX_SIZE_LOG) {
			var mask = (-1) << i;
			var z = getZoneByTopLeft(x & mask, y & mask);
			if (z != null) return z;
		}
		return null;
	}

	public function getZoneByTopLeft(x : Int, y : Int) : MeshZone<T> {
		return getZoneByKeyPoint(x, y);
	}

	public function getZoneByKeyPoint(x : Int, y : Int) : MeshZone<T> {
		throw "This method should be implemented in subclasses";
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

	private function initZones() {
		// Boundary of remaining area (w n inclusive, e s exclusive)
		// At each iteration all 4 values are divisible by size
		var w = 0;
		var e = width;
		var n = 0;
		var s = height;

		for (sizeLog in 0...MeshZone.MAX_SIZE_LOG) {
			var size = 1 << sizeLog;

			do {
				for (i in range(n, s, size))
					addZone(new MeshZone<T>(w, i, sizeLog, defaultValue));
				w += size;
			} while (w % (2 * size) != 0 && w < e);
			if (w >= e) break;

			do {
				for (i in range(n, s, size))
					addZone(new MeshZone<T>(e - size, i, sizeLog, defaultValue));
				e -= size;
			} while (e % (2 * size) != 0 && w < e);
			if (w >= e) break;

			do {
				for (i in range(w, e, size))
					addZone(new MeshZone<T>(i, n, sizeLog, defaultValue));
				n += size;
			} while (n % (2 * size) != 0 && n < s);
			if (n >= s) break;

			do {
				for (i in range(w, e, size))
					addZone(new MeshZone<T>(i, s - size, sizeLog, defaultValue));
				s -= size;
			} while (s % (2 * size) != 0 && n < s);
			if (n >= s) break;
		}

		for (z in this)
			fixLinks(z);
	}

	private function tryMerge(x : Int, y : Int, sizeLog : Int, nw : MeshZone<T>, ne : MeshZone<T>, sw : MeshZone<T>, se : MeshZone<T>) : Bool {
		unrollFor(for (z in [nw, ne, sw, se]) {
			if (z == null || z.sizeLog != sizeLog)
				return false;
		});
		
		// Each zone should have at most one neighbor in each outfacing cardinal direction
		var size = 1 << sizeLog;
		if (getZoneByKeyPoint(x +     size    , y            - 1) != getZoneByKeyPoint(x + 2 * size - 1, y            - 1) ||
			getZoneByKeyPoint(x + 2 * size    , y               ) != getZoneByKeyPoint(x + 2 * size    , y +     size - 1) ||
			getZoneByKeyPoint(x + 2 * size    , y +     size    ) != getZoneByKeyPoint(x + 2 * size    , y + 2 * size - 1) ||
			getZoneByKeyPoint(x + 2 * size - 1, y + 2 * size    ) != getZoneByKeyPoint(x +     size    , y + 2 * size    ) ||
			getZoneByKeyPoint(x +     size - 1, y + 2 * size    ) != getZoneByKeyPoint(x               , y + 2 * size    ) ||
			getZoneByKeyPoint(x +          - 1, y + 2 * size - 1) != getZoneByKeyPoint(x            - 1, y +     size    ) ||
			getZoneByKeyPoint(x +          - 1, y +     size - 1) != getZoneByKeyPoint(x            - 1, y               ) ||
			getZoneByKeyPoint(x               , y            - 1) != getZoneByKeyPoint(x +     size - 1, y            - 1))
			return false;

		var newSize = 2 * size;
		// There should be zones diagonally adjecent to the new zone
		// Not sure why this is neccessary, but the original code checks it
		if (getZoneByKeyPoint(x           - 1, y           - 1) == null ||
			getZoneByKeyPoint(x + newSize + 1, y           - 1) == null ||
			getZoneByKeyPoint(x           - 1, y + newSize + 1) == null ||
			getZoneByKeyPoint(x + newSize + 1, y + newSize + 1) == null)
			return false;

		unrollFor(for (z in [nw, ne, sw, se]) {
			removeZone(z);
		});
		addZone(new MeshZone<T>(x, y, sizeLog + 1, defaultValue));
		return true;
	}

	private function splitZone(z : MeshZone<T>, dirty : HashSet<MeshZone<T>>) {
		//trace('splitZone(${z.x}, ${z.y})');

		var w = getZoneByKeyPoint(z.x - 1, z.y);
		var e = getZoneByKeyPoint(z.x + z.size, z.y);
		var n = getZoneByKeyPoint(z.x, z.y - 1);
		var s = getZoneByKeyPoint(z.x, z.y + z.size);

		unrollFor(for (z1 in [w, e, n, s]) {
			// No infinite recursion because z.size is strictly increasing, and is bounded by mesh size
			if (z1 != null && z1.sizeLog > z.sizeLog)
				splitZone(z1, dirty);
		});

		var size = 1 << (z.sizeLog - 1);
		var nw = new MeshZone<T>(z.x       , z.y       , z.sizeLog - 1, z.value);
		var ne = new MeshZone<T>(z.x + size, z.y       , z.sizeLog - 1, z.value);
		var sw = new MeshZone<T>(z.x       , z.y + size, z.sizeLog - 1, z.value);
		var se = new MeshZone<T>(z.x + size, z.y + size, z.sizeLog - 1, z.value);

		removeZone(z);
		unrollFor(for (z1 in [nw, ne, sw, se]) {
			addZone(z1);
			dirty.set(z1);
		});
		//trace('/splitZone(${z.x}, ${z.y})');
	}

	private function fixLinks(z : MeshZone<T>) {
		//trace('fix(${z.x}, ${z.y})');
		var w = z.x;
		var e = z.x + z.size - 1;
		var n = z.y;
		var s = z.y + z.size - 1;
		z.fillLinks(getZoneByKeyPoint(w - 1, n - 1), getZoneByKeyPoint(w    , n - 1), getZoneByKeyPoint(e    , n - 1), getZoneByKeyPoint(e + 1, n - 1),
		            getZoneByKeyPoint(w - 1, n    ),                                                                   getZoneByKeyPoint(e + 1, n    ),
		            getZoneByKeyPoint(w - 1, s    ),                                                                   getZoneByKeyPoint(e + 1, s    ),
		            getZoneByKeyPoint(w - 1, s + 1), getZoneByKeyPoint(w    , s + 1), getZoneByKeyPoint(e    , s + 1), getZoneByKeyPoint(e + 1, s + 1));
	}

	public function onWallsUpdate(x : Int, y : Int, w : Int, h : Int, walls : Array2<Bool>) {
		var dirty = new HashSet<MeshZone<T>>(512);
		trace("onWallsUpdate");

		// Step 1: remove
		for (i in x...x + w) {
			for (j in y...y + h) {
				if (!walls.get(i, j)) continue;
				var z = getZone(i, j);
				while (z != null && z.sizeLog > 0) {
					for (z1 in z.links) {
						if (z1 != null) {
							dirty.set(z1);
						}
					}
					splitZone(z, dirty);
					z = getZone(i, j);
				}
				if (z != null)
					removeZone(z);
			}
		}

		// Step 2: add
		for (i in x...x + w) {
			for (j in y...y + h) {
				if (!walls.get(i, j) && getZone(i, j) == null)
					addZone(new MeshZone<T>(i, j, 0, defaultValue));
			}
		}

		// Step 3: merge
		for (sizeLog in 0...MeshZone.MAX_SIZE_LOG + 10) {
			var size = 1 << sizeLog;
			var mergedSomething = false;

			var mask = (-1) << (sizeLog + 1);
			var startX = 2 * size + ((x - 1) & mask); // First number >= x divisible by 2 * size
			var startY = 2 * size + ((y - 1) & mask); // First number >= y divisible by 2 * size

			trace(size, startX, startY);
			for (i in range(startX, x + w, 2 * size)) {
				for (j in range(startY, y + h, 2 * size)) {
					var nw = getZoneByTopLeft(i       , j       );
					var ne = getZoneByTopLeft(i + size, j       );
					var sw = getZoneByTopLeft(i       , j + size);
					var se = getZoneByTopLeft(i + size, j + size);

					if (tryMerge(i, j, sizeLog, nw, ne, sw, se)) {
						mergedSomething = true;
					}
				}
			}


			if (!mergedSomething) break;
		}

		// Step 4: fix links
		for (i in x - 1...x + w + 1) {
			for (j in y - 1...y + h + 1) {
				var z = getZoneByKeyPoint(i, j);
				if (z != null) dirty.set(z);
			}
		}

		for (z in dirty) {
			if (getZoneByTopLeft(z.x, z.y) == z) // if still exists
				fixLinks(z);
		}

		// Step 5: reapply portals
	}
}