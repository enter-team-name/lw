
package com.teamname.lw.mesh;

import haxe.ds.Vector;

import de.polygonal.ds.Array2;

class WriteOptimizedMesh<T> extends Mesh<T> {
	private var zones(null, null) : Array2<MeshZone<T>>;
	private var keyPoints(null, null) : Array2<MeshZone<T>>;

	public function new(w : Int, h : Int, ?defaultValue : T, ?zones : Iterable<MeshZone<T>>) {
		this.zones = new Array2<MeshZone<T>>(w, h);
		this.keyPoints = new Array2<MeshZone<T>>(w, h);

		super(w, h, defaultValue, zones);
	}

	public static function fromMesh<T>(m : Mesh<T>) {
		return new WriteOptimizedMesh<T>(m.width, m.height, m.defaultValue, m);
	}
	
	public inline override function directionalIterator(dir : Dir = Dir.DIR_SE) : Iterator<MeshZone<T>> {
		return Lambda.filter(zones, function(x) return x != null).iterator();
	}

	private override function addZone(z : MeshZone<T>) {
		zones.set(z.x, z.y, z);
		if (z.sizeLog == 0) {
			keyPoints.set(z.x, z.y, z);
		}
		else {
			var kp = z.keyPoints();
			for (dx in kp)
				for (dy in kp)
					keyPoints.set(z.x + dx, z.y + dy, z);
		}
	}

	private inline override function removeZone(z : MeshZone<T>) : Bool {
		if (zones.get(z.x, z.y) == z) {
			zones.set(z.x, z.y, null);
			if (z.sizeLog == 0) {
				keyPoints.set(z.x, z.y, null);
			}
			else {
				var kp = z.keyPoints();
				for (dx in kp)
					for (dy in kp)
						keyPoints.set(z.x + dx, z.y + dy, null);
			}
			return true;
		}
		return false;
	}

	public inline override function getZoneByKeyPoint(x : Int, y : Int) : MeshZone<T> {
		return if (0 <= x && x < width && 0 <= y && y < height)
			keyPoints.get(x, y);
		else
			null;
	}
}