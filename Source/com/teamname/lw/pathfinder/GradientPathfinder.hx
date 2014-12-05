package com.teamname.lw.pathfinder;

import com.teamname.lw.mesh.*;

import de.polygonal.ds.M;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class GradientPathfinder implements Pathfinder {
	private static inline var MAX_DIST = 1000000;

	private var mesh : Mesh<Int>;
	private var targetX : Int;
	private var targetY : Int;
	private var targetZone : MeshZone<Int>;
	private var targetGrad = MAX_DIST;
	private var meshBitmap : BitmapData;

	public function new() {
	}

	public function loadMap(bmp : BitmapData) : Void {
		mesh = new WriteOptimizedMesh<Int>(bmp.width, bmp.height, 0);
		mesh.addBitmap(bmp);
		mesh.mergeAll(8);
		mesh = ReadOptimizedMesh.fromMesh(mesh);
	}

	public function setTarget(x : Int, y : Int, dist : Int) : Void {
		targetX = x;
		targetY = y;
		targetZone = mesh.getZone(x, y);
		targetGrad += dist;
		if (targetZone != null) targetZone.value = targetGrad;
	}

	public function tick(time : Int) : Void {
		var dir = (time * 7) % 12;
		trace(dir);
		for (z in mesh.directionalIterator(dir)) {
			var next = z.links[dir];
			if (next != null) next.value = M.max(next.value, z.value - z.size);
		}
	}

	public function getDebugBitmap() : BitmapData {
		var res = new BitmapData(mesh.width, mesh.height, true /*transparent*/);
		for (z in mesh) {
			var dist = targetGrad - z.value;
			var color = 0xFFFF0000 + (0x000001 - 0x010000) * Std.int(Math.log(dist / 100 + 1) * 128);
			var rect = new Rectangle(z.x, z.y, z.size, z.size);
			res.fillRect(rect, color);
		}
		res.fillRect(new Rectangle(targetX - 10, targetY - 1, 20, 2), 0xFF000000);
		res.fillRect(new Rectangle(targetX - 1, targetY - 10, 2, 20), 0xFF000000);
		return res;
	}

	public function getMoveDirection(x : Int, y : Int, time : Int) : Dir {
		var zone = mesh.getZone(x, y);

		if (zone == null) return Dir.DIR_SE;

		if (zone == targetZone) {
			var dx = (targetX > x ? 1 : 0) - (targetX < x ? 1 : 0);
			var dy = (targetY > y ? 1 : 0) - (targetY < y ? 1 : 0);
			var s = Std.random(2) == 1;
			return switch [dx, dy] {
				case [-1, -1]: Dir.DIR_NW;
				case [-1,  0]: s ? Dir.DIR_NNW : Dir.DIR_NNE;
				case [-1,  1]: Dir.DIR_SW;
				case [ 0, -1]: s ? Dir.DIR_WNW : Dir.DIR_WSW;
				case [ 0,  1]: s ? Dir.DIR_ENE : Dir.DIR_ESE;
				case [ 1, -1]: Dir.DIR_NE;
				case [ 1,  0]: s ? Dir.DIR_SSW : Dir.DIR_SSE;
				case [ 1,  1]: Dir.DIR_NW;
				case [ _,  _]: Std.int(time / 6) % 12;
			}
		}
		else {
			var start = Std.int(time / 6) % 12;
			var step = Std.random(2) == 1 ? 1 : 11;

			var bestDir = -1;
			var bestGrad = 0;

			var zl = zone.links;
			var dir = start;
			do {
				var zone1 = zl[dir];
				if (zone1 != null && zone1.value > bestGrad) {
					bestGrad = zone1.value;
					bestDir = dir;
				}

				dir = (dir + step) % 12;
			} while (dir != start);

			if (bestDir != -1) return bestDir;
		}

		return Std.random(12);
	}
}