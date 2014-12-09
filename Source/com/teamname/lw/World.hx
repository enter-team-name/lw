
package com.teamname.lw;

import com.teamname.lw.pathfinder.*;

import de.polygonal.ds.Array2;
import de.polygonal.ds.HashSet;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class World {
	public var teams(default, never) = new Array<Team>();

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	public var time(default, null) : Int;

	private var fighterSet : HashSet<Fighter>;
	private var fighterMap : Array2<Fighter>;

	private var walls : Array2<Bool>;

	public var maxFighterHealth : Int = 16384;

	public function new(bmp : BitmapData) {
		// This is mostly a placeholder
		width = bmp.width;
		height = bmp.height;
		time = 0;
		fighterSet = new HashSet<Fighter>(1024);
		fighterMap = new Array2<Fighter>(width, height);
		walls = new Array2<Bool>(width, height);

		teams.push(new Team(new GradientPathfinder(width, height), "Green", 0xFF00FF00));
		teams.push(new Team(new GradientPathfinder(width, height), "Blue", 0xFF0000FF));

		updateWallsFromBitmap(0, 0, bmp);

		addRandomFighters(teams[0], maxFighterHealth - 1, 300);
		addRandomFighters(teams[1], maxFighterHealth - 1, 300);
	}

	public function tick() {
		// Also a placeholder
		if (time % 2 == 0) {
			var angle = Math.PI * time / 500;
			var x = Std.int(width / 2 - 75 * Math.sin(angle));
			var y1 = Std.int(height / 2 + 75 * Math.cos(angle));
			var y2 = Std.int(height / 2 - 75 * Math.cos(angle));
			teams[0].pathfinder.setTarget(x, y1, 2);
			teams[1].pathfinder.setTarget(x, y2, 2);
		}

		for (t in teams)
			t.tick(time);

		for (f in fighterSet) {
			f.move(this);
		}
		time++;
	}

	public inline function addFighter(f : Fighter) {
		if (f.x < 0 || f.x >= width || f.y < 0 || f.y >= height) return;
		fighterMap.set(f.x, f.y, f);
		fighterSet.set(f);
	}

	public inline function moveFighter(f : Fighter, x : Int, y : Int) {
		if (f.x < 0 || f.x >= width || f.y < 0 || f.y >= height) return;
		fighterMap.set(f.x, f.y, null);
		f.x = x;
		f.y = y;
		if (f.x < 0 || f.x >= width || f.y < 0 || f.y >= height) return;
		fighterMap.set(f.x, f.y, f);
	}

	public inline function getFighter(x : Int, y : Int) : Fighter {
		if (x < 0 || x >= width || y < 0 || y >= height) return null;
		return fighterMap.get(x, y);
	}

	public inline function removeFighter(f : Fighter) : Bool {
		if (f.x < 0 || f.x >= width || f.y < 0 || f.y >= height) return false;
		fighterMap.set(f.x, f.y, null);
		return fighterSet.remove(f);
	}

	private function addRandomFighters(team : Team, hp : Int, count : Int = 1) {
		for (i in 0...count) {
			var x = Std.random(width);
			var y = Std.random(height);
			var f = new Fighter(x, y, team, hp);
			addFighter(f);
		}
	}

	public function isWall(x : Int, y : Int) : Bool {
		return walls.get(x, y);
	}

	public function updateWalls(x : Int, y : Int, w : Int, h : Int, pred : Int -> Int -> Bool -> Bool) {
		for (i in x...x + w) {
			for (j in y...y + h) {
				walls.set(i, j, pred(i, j, walls.get(i, j)));
			}
		}
		for (t in teams) {
			t.pathfinder.onWallsUpdate(x, y, w, h, walls);
		}
	}

	public function updateWallsFromBitmap(x : Int, y : Int, bmp : BitmapData) {
		for (i in 0...bmp.width) {
			for (j in 0...bmp.height) {
				var color = bmp.getPixel(i, j);
				var r = (color >> 16) & 0xFF;
				var g = (color >> 8) & 0xFF;
				var b = color & 0xFF;
				var value = 6 * r + 3 * g + b < 315;
				walls.set(x + i, y + j, value);
			}
		}
		for (t in teams) {
			t.pathfinder.onWallsUpdate(x, y, bmp.width, bmp.height, walls);
		}
	}

	public function getBitmap(debugTeam : Int = -1, ?extra : Dynamic) : BitmapData {
		var res = if (debugTeam == -1)
			new BitmapData(width, height, true /*transparent*/)
		else
			teams[debugTeam].pathfinder.getDebugBitmap(extra);

		for (t in teams) {
			var pf = t.pathfinder;
			res.fillRect(new Rectangle(pf.targetX - 10, pf.targetY - 1, 20, 2), t.color);
			res.fillRect(new Rectangle(pf.targetX - 1, pf.targetY - 10, 2, 20), t.color);
		}

		for (f in fighterSet) {
			var color = f.team.color;
			var r = Std.int(((color && 0xFF0000) >> 16) * f.health / maxFighterHealth);
			var g = Std.int(((color && 0x00FF00) >> 8) * f.health / maxFighterHealth);
			var b = Std.int((color && 0x0000FF) * f.health / maxFighterHealth);
			res.setPixel(f.x, f.y, r * 0x010000 + g * 0x000100 + b);
		}

		return res;
	}
}