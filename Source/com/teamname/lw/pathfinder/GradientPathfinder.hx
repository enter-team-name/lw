package com.teamname.lw.pathfinder;

import com.teamname.lw.mesh.*;

import de.polygonal.ds.M;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class GradientPathfinder implements Pathfinder {
	private static var DEFAULT_GRADIENT       (default, never) = 0x7FFFFFFF;
	private static var DEFAULT_TARGET_GRADIENT(default, never) = 0x70000000;

	private var mesh : Mesh<Int>;
	private var targetX : Int;
	private var targetY : Int;
	private var targetZone : MeshZone<Int>;
	private var targetGrad = DEFAULT_TARGET_GRADIENT;
	private var meshBitmap : BitmapData;

	public function new() {
	}

	public function loadMap(bmp : BitmapData) : Void {
		mesh = new WriteOptimizedMesh<Int>(bmp.width, bmp.height, DEFAULT_GRADIENT);
		mesh.addBitmap(bmp);
		mesh.mergeAll(8);
		mesh = ReadOptimizedMesh.fromMesh(mesh);
	}

	public function setTarget(x : Int, y : Int, dist : Int) : Void {
		targetX = x;
		targetY = y;
		targetZone = mesh.getZone(x, y);
		targetGrad -= dist;
		if (targetZone != null) targetZone.value = targetGrad;
	}

	public function tick(time : Int) : Void {
		var dir = (time * 7) % 12;
		trace(dir);
		for (z in mesh.directionalIterator(dir)) {
			var next = z.links[dir];
			if (next != null) next.value = M.min(next.value, z.value + z.size);
		}
	}

	public function getDebugBitmap() : BitmapData {
		var res = new BitmapData(mesh.width, mesh.height, true /*transparent*/);
		for (z in mesh) {
			var dist = z.value - targetGrad;
			var color = 0xFFFF0000 + (0x000001 - 0x010000) * Std.int(Math.log(dist / 100 + 1) * 128);
			var rect = new Rectangle(z.x, z.y, z.size, z.size);
			res.fillRect(rect, color);
		}
		res.fillRect(new Rectangle(targetX - 10, targetY - 1, 20, 2), 0xFF000000);
		res.fillRect(new Rectangle(targetX - 1, targetY - 10, 2, 20), 0xFF000000);
		return res;
	}

	public function getMoveDirection(x : Int, y : Int) : Int {
		throw "TODO";
	}
}