package com.teamname.lw.pathfinder;

import com.teamname.lw.mesh.*;

import de.polygonal.ds.Array2;
import de.polygonal.ds.M;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class GradientPathfinder implements Pathfinder {
	private static inline var MAX_DIST = 1000000;

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	public var targetX(default, null) : Int;
	public var targetY(default, null) : Int;

	private var mesh : Mesh<Int>;
	private var targetZone : MeshZone<Int>;
	private var targetGrad : Int = MAX_DIST;

	private var running = false;

	public function new(width : Int, height : Int) {
		mesh = new WriteOptimizedMesh<Int>(width, height, 0);
	}

	public function onWallsUpdate(x : Int, y : Int, w : Int, h : Int, walls : Array2<Bool>) : Void {
		mesh.onWallsUpdate(x, y, w, h, walls);
	}

	public function setTarget(x : Int, y : Int, dist : Int) : Void {
		//trace('setTarget($x, $y, $dist)');
		targetX = x;
		targetY = y;
		targetZone = mesh.getZone(x, y);
		targetGrad += dist;
		if (targetZone != null) targetZone.value = targetGrad;
	}

	public function tick(time : Int) : Void {
		if (!running) {
			mesh = ReadOptimizedMesh.fromMesh(mesh);
			running = true;
		}

		var dir = (time * 7) % 12;
		//trace(dir);
		for (z in mesh.directionalIterator(dir)) {
			var next = z.links[dir];
			if (next != null) next.value = M.max(next.value, z.value - z.size);
		}
	}

	public function getDebugBitmap(randomColors : Bool) : BitmapData {
		var res = new BitmapData(mesh.width, mesh.height, true /*transparent*/);
		for (z in mesh) {
			var color;
			if (randomColors) {
				// No keyboards were harmed in the generating of these pseudo-random coefficients
				color = 0xFF000000 + (234523 * z.x + 126712 * z.y + 5641235 * z.sizeLog) % 0x1000000;
			} else {
				var dist = targetGrad - z.value;
				var scaled = Std.int(Math.log(dist / 100 + 1) * 128);
				if (scaled < 0) trace("OMG, negative distances!");
				if (scaled > 255) scaled = 255;
				color = 0xFFFF0000 + (0x000001 - 0x010000) * scaled;
			}
			var rect = new Rectangle(z.x, z.y, z.size, z.size);
			res.fillRect(rect, color);
		}
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