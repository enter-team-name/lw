
package com.teamname.lw;

import com.teamname.lw.pathfinder.*;

import de.polygonal.ds.Array2;
import de.polygonal.ds.HashSet;

import openfl.display.BitmapData;

class World {
	public var armyPathfinders(default, null) = new Array<Pathfinder>();

	public var width(default, null) : Int;
	public var height(default, null) : Int;

	public var time(default, null) : Int;

	private var fighterSet(null, null) : HashSet<Fighter>;
	private var fighterMap(null, null) : Array2<Fighter>;

	public var cursorX : Int = 10;
	public var cursorY : Int = 10;

	public function new(bmp : BitmapData) {
		// This is mostly a placeholder
		width = bmp.width;
		height = bmp.height;
		time = 0;
		fighterSet = new HashSet<Fighter>(512);
		fighterMap = new Array2<Fighter>(width, height);

		armyPathfinders.push(new GradientPathfinder());

		for (p in armyPathfinders)
			p.loadMap(bmp);

		addFighters(0, 100, 1000);
	}

	// public function tick() {
	// 	// Also a placeholder
	// 	if (time % 2 == 0) {
	// 		var angle = Math.PI * time / 500;
	// 		var x = Std.int(width / 2 - 75 * Math.sin(angle));
	// 		var y = Std.int(height / 2 + 75 * Math.cos(angle));
	// 		for (p in armyPathfinders)
	// 			p.setTarget(x, y, 2);
	// 	}

	// 	for (p in armyPathfinders)
	// 		p.tick(time);

	// 	for (f in fighterSet) {
	// 		var p = armyPathfinders[f.team];
	// 		f.move(this, p);
	// 	}
	// 	time++;
	// }

	public function tick() {
		if (time % 2 == 0) {
			for (p in armyPathfinders)
				p.setTarget(cursorX, cursorY, 2);
		}

		for (p in armyPathfinders)
			p.tick(time);

		for (f in fighterSet) {
			var p = armyPathfinders[f.team];
			f.move(this, p);
		}
		time++;
	}

	public function moveCursor(x : Int, y : Int, delta : Int) {
		cursorX = x;
		cursorY = y;
		for (p in armyPathfinders)
			p.setTarget(x, y, delta);
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

	private function addFighters(team : Int, hp : Int, count : Int = 1) {
		for (i in 0...count) {
			var x = Std.random(width);
			var y = Std.random(height);
			var f = new Fighter(x, y, team, hp);
			addFighter(f);
		}
	}

	public function getBitmap(debugTeam : Int = -1) : BitmapData {
		var bmp = if (debugTeam == -1)
			new BitmapData(width, height, true /*transparent*/)
		else
			armyPathfinders[debugTeam].getDebugBitmap();

		for (f in fighterSet) {
			bmp.setPixel(f.x    , f.y    , 0xFF00FF00);
		}

		return bmp;
	}
}