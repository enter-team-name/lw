
package com.teamname.lw;

import com.teamname.lw.Main;
import com.teamname.lw.pathfinder.*;
import com.teamname.lw.input.*;

import de.polygonal.ds.Array2;
import de.polygonal.ds.HashSet;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class World {
	public var teams(default, never) = new Array<Team>();

	public var width(default, null) : Int;
	public var height(default, null) : Int;
	public var time(default, null) : Int;

	public var settings = new Settings();

	private var fighterSet : HashSet<Fighter>;
	private var fighterMap : Array2<Fighter>;

	private var walls : Array2<Bool>;
	private var wallBitmap : BitmapData;

	// This is mostly a placeholder
	public function new(bmp : BitmapData) {
		width = bmp.width;
		height = bmp.height;
		time = 0;

		fighterSet = new HashSet<Fighter>(1024);
		fighterMap = new Array2<Fighter>(width, height);

		walls = new Array2<Bool>(width, height);
		wallBitmap = new BitmapData(width, height);

		// That's not gonna work
		// addTeam(new GradientPathfinder(width, height), TouchInput.create(Math.min(500 / bmp.height, 800 / bmp.width)), "Green", 0xFF00FF00);
		addTeam(new GradientPathfinder(width, height), KeyboardInput.createWASD(), "Green", 0xFF00FF00);
		addTeam(new GradientPathfinder(width, height), KeyboardInput.createArrows(), "Blue", 0xFF0000FF);
		//teams[0].advantage = 1024;

		updateWallsFromBitmap(0, 0, bmp);

		for (t in teams) {
			t.pathfinder.setTarget(width >> 1, height >> 1, 0);
			addRandomFighters(t, 1500);
		}
	}

	public inline function addTeam(pathfinder : Pathfinder, input : InputMethod, name : String, color : Int) {
		teams.push(new Team(this, pathfinder, input, name, color));
	}

	public function tick() {
		// Also a placeholder
		/*if (time % 2 == 0) {
			var angle = Math.PI * time / 500;
			var x = Std.int(width / 2 - 75 * Math.sin(angle));
			var y1 = Std.int(height / 2 + 75 * Math.cos(angle));
			var y2 = Std.int(height / 2 - 75 * Math.cos(angle));
			teams[0].pathfinder.setTarget(x, y1, 2);
			teams[1].pathfinder.setTarget(x, y2, 2);
		}*/

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

	public inline function fighterCount() : Int {
		return fighterSet.size();
	}

	public inline function averageArmySize() : Float {
		return fighterSet.size() / teams.length;
	}

	public inline function armySize(t : Team) : Float {
		var res = 0;
		for (f in fighterSet)
			if (f.team == t)
				res++;
		return res;
	}

	private function addRandomFighters(team : Team, count : Int = 1) {
		while (count > 0) {
			var x = Std.random(width);
			var y = Std.random(height);
			if (!isWall(x, y)) {
				var f = new Fighter(x, y, team, Fighter.MAX_HEALTH - 1);
				addFighter(f);
				count--;
			}
		}
	}

	public function isWall(x : Int, y : Int) : Bool {
		if (x < 0 || x >= width || y < 0 || y >= height) return true;
		return walls.get(x, y);
	}

	public function updateWalls(x : Int, y : Int, w : Int, h : Int, pred : Int -> Int -> Bool -> Bool) {
		for (i in x...x + w) {
			for (j in y...y + h) {
				var value = pred(i, j, walls.get(i, j));
				walls.set(i, j, value);
				if (value) wallBitmap.setPixel(i, j, 0xFF000000);
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
				if (value) wallBitmap.setPixel(i, j, 0xFF000000);
			}
		}
		for (t in teams) {
			t.pathfinder.onWallsUpdate(x, y, bmp.width, bmp.height, walls);
		}
	}

	public function getBitmap(debugTeam : Int = -1, ?extra : Dynamic) : BitmapData {
		var res = new BitmapData(width, height);
		if (debugTeam == -1)
			res.draw(wallBitmap);
		else
			res.draw(teams[debugTeam].pathfinder.getDebugBitmap(extra));

		for (t in teams) {
			var pf = t.pathfinder;
			res.fillRect(new Rectangle(pf.targetX - 10, pf.targetY - 1, 20, 2), t.color);
			res.fillRect(new Rectangle(pf.targetX - 1, pf.targetY - 10, 2, 20), t.color);
		}

		for (f in fighterSet) {
			var k = f.health / Fighter.MAX_HEALTH;
			var color = f.team.color;

			var r = (color >> 16) & 0xFF;
			var g = (color >> 8) & 0xFF;
			var b = color & 0xFF;

			r = Std.int(r * k);
			g = Std.int(g * k);
			b = Std.int(b * k);

			color = 0xFF000000 | (r << 16) | (g << 8) | b;
			res.setPixel(f.x, f.y, color);
		}

		return res;
	}
}