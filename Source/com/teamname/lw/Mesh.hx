
package com.teamname.lw;

import haxe.ds.Vector;

import de.polygonal.ds.DLL; // Doubly Linked List

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class Mesh<T> {
	var zoneList(default, null) = new DLL<MeshZone<T>>();
	var zoneTable(default, null) = new Array<Array<MeshZone<T>>>();

	public function new() {
	}

	public function addZone(z : MeshZone<T>) {
		for (i in z.x...z.x + z.size)
			for (j in z.y...z.y + z.size)
				if (zoneTable.length > i && zoneTable[i].length > j && zoneTable[i][j] != null)
					throw "Mesh zones can't intersect!";

		for (i in zoneTable.length...z.x + z.size) zoneTable[i] = new Array<MeshZone<T>>();

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
		if (x < 0 || y < 0 || x >= zoneTable.length || y >= zoneTable[x].length)
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

	public inline function iterator() {
		return zoneList.iterator();
	}

	// public inline function reverseIterator() {
	// 	// TODO
	// }

	public function toImage() : BitmapData {
		var res = new BitmapData(zoneTable.length, Utils.max([for (col in zoneTable) col.length]), true /*transparent*/);
		for (z in zoneList) {
			var color = 0xFF000000 | Std.random(0xFFFFFF);
			res.fillRect(new Rectangle(z.x, z.y, z.size, z.size), color);
		}
		return res;
	}

	public static function createRectangularMesh<T>(w : Int, h : Int, x0 : Int = 0, y0 : Int = 0, ?defaultValue : T) {
		var res = new Mesh();
		for (j in y0...y0 + h)
			for (i in x0...x0 + w)
				res.addZone(new MeshZone(i, j, 0, defaultValue));

		for (x in x0...x0 + w) {
			for (y in y0...y0 + h) {
				var z = res.getZoneAt(x, y);

				z.links[Dir.DIR_NNE] = res.getZoneAt(x    , y - 1);
				z.links[Dir.DIR_NE]  = res.getZoneAt(x + 1, y - 1);
				z.links[Dir.DIR_ENE] = res.getZoneAt(x + 1, y    );
				z.links[Dir.DIR_ESE] = res.getZoneAt(x + 1, y    );
				z.links[Dir.DIR_SE]  = res.getZoneAt(x + 1, y + 1);
				z.links[Dir.DIR_SSE] = res.getZoneAt(x    , y + 1);
				z.links[Dir.DIR_SSW] = res.getZoneAt(x    , y + 1);
				z.links[Dir.DIR_SW]  = res.getZoneAt(x - 1, y + 1);
				z.links[Dir.DIR_WSW] = res.getZoneAt(x - 1, y    );
				z.links[Dir.DIR_WNW] = res.getZoneAt(x - 1, y    );
				z.links[Dir.DIR_NW]  = res.getZoneAt(x - 1, y - 1);
				z.links[Dir.DIR_NNW] = res.getZoneAt(x    , y - 1);
			}
		}
		return res;
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