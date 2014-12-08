package com.teamname.lw;

import com.teamname.lw.pathfinder.*;

class Team {
	public var pathfinder(default, null) : Pathfinder;
	public var name(default, null) : String;
	public var color(default, null) : Int;

	public function new(pathfinder, name, color) {
		this.pathfinder = pathfinder;
		this.name = name;
		this.color = color;
	}

	public function tick(time : Int) {
		pathfinder.tick(time);
	}
}