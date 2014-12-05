
package com.teamname.lw;

import com.teamname.lw.pathfinder.*;

import openfl.display.BitmapData;

class World {
	public var armyPathfinders(default, null) = new Array<Pathfinder>();
	public var width(default, null) : Int;
	public var height(default, null) : Int;
	public var time(default, null) : Int;

	public function new(bmp : BitmapData) {
		// This is mostly a placeholder
		width = bmp.width;
		height = bmp.height;
		time = 0;

		armyPathfinders.push(new GradientPathfinder());

		for (p in armyPathfinders)
			p.loadMap(bmp);

	}

	public function tick() {
		// Also a placeholder
		if (time % 2 == 0) {
			var angle = Math.PI * time / 1000;
			var x = Std.int(width / 2 - 75 * Math.sin(angle));
			var y = Std.int(height / 2 + 75 * Math.cos(angle));
			for (p in armyPathfinders)
				p.setTarget(x, y, 1);
		}

		for (p in armyPathfinders)
			p.tick(time);
		time++;
	}
}