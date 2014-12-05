
package com.teamname.lw.mesh;

import com.teamname.lw.ds.BST;

import de.polygonal.ds.Array2;
import de.polygonal.ds.Comparable;

class ReadOptimizedMesh<T> extends Mesh<T> {
	private var zoneTreeNE = new BST<MeshZone<T>>(function (a, b) {
		if (a.x + a.size != b.x + b.size) return b.x + b.size - a.x - a.size;
		else return a.y - b.y;
	});
	private var zoneTreeS = new BST<MeshZone<T>>(function (a, b) {
		if (a.y + a.size != b.y + b.size) return b.y + b.size - a.y - a.size;
		else return a.x - b.x;
	});
	private var zoneTreeNW = new BST<MeshZone<T>>(function (a, b) {
		if (a.x != b.x) return a.x - b.x;
		else return a.y - b.y;
	});
	private var zones(null, null) : Array2<MeshZone<T>>;


	public function new(w : Int, h : Int, ?defaultValue : T, ?zones : Iterable<MeshZone<T>>) {
		this.zones = new Array2<MeshZone<T>>(w, h);

		super(w, h, defaultValue, zones);
	}

	public static function fromMesh<T>(m : Mesh<T>) {
		return new ReadOptimizedMesh<T>(m.width, m.height, m.defaultValue, m);
	}

	public override function directionalIterator(dir : Dir = Dir.DIR_SE) : Iterator<MeshZone<T>> {
		switch (dir) {
			case Dir.DIR_NNE | Dir.DIR_NE | Dir.DIR_ENE | Dir.DIR_ESE:
				return zoneTreeNE.iterator();
			case Dir.DIR_SE | Dir.DIR_SSE | Dir.DIR_SSW | Dir.DIR_SW:
				return zoneTreeS.iterator();
			case Dir.DIR_WSW | Dir.DIR_WNW | Dir.DIR_NW | Dir.DIR_NNW:
				return zoneTreeNW.iterator();
		}
	}

	private override function addZone(z : MeshZone<T>) {
		for (i in z.x...z.x + z.size)
			for (j in z.y...z.y + z.size)
				zones.set(i, j, z);
		zoneTreeNE.insert(z);
		zoneTreeS.insert(z);
		zoneTreeNW.insert(z);
	}

	private override function removeZone(z : MeshZone<T>) : Bool {
		for (i in z.x...z.x + z.size)
			for (j in z.y...z.y + z.size)
				zones.set(i, j, null);
		zoneTreeNE.remove(z);
		zoneTreeS.remove(z);
		return zoneTreeNW.remove(z);
	}

	public inline override function getZone(x : Int, y : Int) : MeshZone<T> {
		return zones.get(x, y);
	}
}