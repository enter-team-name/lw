package com.teamname.lw;

import com.teamname.lw.input.InputMethod;
import com.teamname.lw.pathfinder.Pathfinder;

class Team {
	public var world(default, null) : World;
	public var pathfinder(default, null) : Pathfinder;
	public var input(default, null) : InputMethod;

	public var name(default, null) : String;
	public var color(default, null) : Int;

	// Original LW :  0 |      2  | 4 || x
	// This version:  1 | sqrt(2) | 2 || 2**(x/4)
	public var advantage(default, default) : Float;

	public var attack(default, null) : Int;
	public var defense(default, null) : Int;
	public var newHealth(default, null) : Int;

	public function new(world, pathfinder, input, name, color) {
		this.world = world;
		this.pathfinder = pathfinder;
		this.input = input;

		this.name = name;
		this.color = color;
		this.advantage = 1;
	}

	public function tick(time : Int) {
		pathfinder.tick(time);
		input.tick();

		var dist = Std.int(Math.max(Math.abs(input.dx), Math.abs(input.dy)));
		if (time % 13 == 0)
			dist++;
		if (dist != 0)
			pathfinder.setTarget(pathfinder.targetX + input.dx, pathfinder.targetY + input.dy, dist);


		var coef = world.armySize(this) / world.averageArmySize() - 1;
		coef = Math.min(coef, 1);

		coef *= Math.abs(world.settings.winnerHelp) * world.settings.winnerHelp;

		if (coef < 0) coef /= 2;
		coef += 1;

		attack = Std.int(coef * world.settings.fighterAttack * advantage);
		if (attack >= Fighter.MAX_HEALTH)
			attack = Fighter.MAX_HEALTH - 1;
		if (attack < 1)
			attack = 1;

		defense = Std.int(coef * world.settings.fighterDefense * advantage);
		if (defense >= Fighter.MAX_HEALTH)
			defense = Fighter.MAX_HEALTH - 1;
		if (defense < 1)
			defense = 1;

		newHealth = Std.int(coef * world.settings.fighterNewHealth * advantage);
		if (newHealth >= Fighter.MAX_HEALTH)
			newHealth = Fighter.MAX_HEALTH - 1;
		if (newHealth < 1)
			newHealth = 1;

		//trace('$name: coef=$coef, atk=$attack, def=$defense, hp=$newHealth');
	}
}