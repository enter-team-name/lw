package com.teamname.lw;

import com.teamname.lw.macro.UnrollLoopMacros.*;
import com.teamname.lw.pathfinder.Pathfinder;
import com.teamname.lw.Utils;

import haxe.ds.Vector;

import de.polygonal.ds.Hashable;

class Fighter implements Hashable {
	public static inline var MAX_HEALTH = 16384;

	public var x(default, default) : Int;
	public var y(default, default) : Int;
	public var health(default, null) : Int;
	public var team(default, null) : Team;
	public var last_dir(default, null) : Int;

	/**
	 * A unique, unsigned 32-bit integer key.<br/>
	 * A hash table transforms this key into an index of an array element by using a hash function.<br/>
	 * <warn>This value should never be changed by the user.</warn>
	 */
	public var key : Int = Std.random(0xFFFFFF);

	public static inline var SIDE_ATTACK_FACTOR = 4;

	 public static var FIGHTER_MOVE_DIR : Array<Array<Array<Dir>>> =
	[[	[Dir.DIR_NNE, Dir.DIR_NE , Dir.DIR_NW , Dir.DIR_ENE, Dir.DIR_WNW],
		[Dir.DIR_NE , Dir.DIR_ENE, Dir.DIR_NNE, Dir.DIR_SE , Dir.DIR_NW ],
		[Dir.DIR_ENE, Dir.DIR_NE , Dir.DIR_SE , Dir.DIR_NNE, Dir.DIR_SSE],
		[Dir.DIR_ESE, Dir.DIR_SE , Dir.DIR_NE , Dir.DIR_SSE, Dir.DIR_NNE],
		[Dir.DIR_SE , Dir.DIR_SSE, Dir.DIR_ESE, Dir.DIR_SW , Dir.DIR_NE ],
		[Dir.DIR_SSE, Dir.DIR_SE , Dir.DIR_SW , Dir.DIR_ESE, Dir.DIR_WSW],
		[Dir.DIR_SSW, Dir.DIR_SW , Dir.DIR_SE , Dir.DIR_WSW, Dir.DIR_ESE],
		[Dir.DIR_SW , Dir.DIR_WSW, Dir.DIR_SSW, Dir.DIR_NW , Dir.DIR_SE ],
		[Dir.DIR_WSW, Dir.DIR_SW , Dir.DIR_NW , Dir.DIR_SSW, Dir.DIR_NNW],
		[Dir.DIR_WNW, Dir.DIR_NW , Dir.DIR_SW , Dir.DIR_NNW, Dir.DIR_SSE],
		[Dir.DIR_NW , Dir.DIR_NNW, Dir.DIR_WNW, Dir.DIR_NE , Dir.DIR_SW ],
		[Dir.DIR_NNW, Dir.DIR_NW , Dir.DIR_NE , Dir.DIR_WNW, Dir.DIR_ENE]],

	[	[Dir.DIR_NNE, Dir.DIR_NE , Dir.DIR_NW , Dir.DIR_ENE, Dir.DIR_WNW],
		[Dir.DIR_NE , Dir.DIR_NNE, Dir.DIR_ENE, Dir.DIR_NW , Dir.DIR_SE ],
		[Dir.DIR_ENE, Dir.DIR_NE , Dir.DIR_SE , Dir.DIR_NNE, Dir.DIR_SSE],
		[Dir.DIR_ESE, Dir.DIR_SE , Dir.DIR_NE , Dir.DIR_SSE, Dir.DIR_NNE],
		[Dir.DIR_SE , Dir.DIR_ESE, Dir.DIR_SSE, Dir.DIR_NE , Dir.DIR_SW ],
		[Dir.DIR_SSE, Dir.DIR_SE , Dir.DIR_SW , Dir.DIR_ESE, Dir.DIR_WSW],
		[Dir.DIR_SSW, Dir.DIR_SW , Dir.DIR_SE , Dir.DIR_WSW, Dir.DIR_ESE],
		[Dir.DIR_SW , Dir.DIR_SSW, Dir.DIR_WSW, Dir.DIR_SE , Dir.DIR_NW ],
		[Dir.DIR_WSW, Dir.DIR_SW , Dir.DIR_NW , Dir.DIR_SSW, Dir.DIR_NNW],
		[Dir.DIR_WNW, Dir.DIR_NW , Dir.DIR_SW , Dir.DIR_NNW, Dir.DIR_SSE],
		[Dir.DIR_NW , Dir.DIR_WNW, Dir.DIR_NNW, Dir.DIR_SW , Dir.DIR_NE ],
		[Dir.DIR_NNW, Dir.DIR_NW , Dir.DIR_NE , Dir.DIR_WNW, Dir.DIR_ENE]]];

	// public static var FIGHTER_MOVE_OFFSET = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];
	// public static var FIGHTER_MOVE_X = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];
	// public static var FIGHTER_MOVE_Y = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];

	public function new(x : Int, y : Int, team : Team, health : Int) {
		this.x = x;
		this.y = y;
		this.health = health;
		this.team = team;
	}

	public function move(w : World) {
		var p = team.pathfinder;
		var t = w.time;
		var mainDir = p.getMoveDirection(x, y, t);

		var start = Std.int(t / 6) % 12;
		var table = Std.int(t / 3) % 2;

		var dirs = FIGHTER_MOVE_DIR[table][mainDir];
		var f = new Vector<Fighter>(5);

		unrollFor(for (i in 0...5) {
			var newX = x + dirs[i].xOffset();
			var newY = y + dirs[i].yOffset();
			f[i] = w.getFighter(newX, newY);
			if (f[i] == null && !w.isWall(newX, newY)) {
				w.moveFighter(this, newX, newY);
				return;
			}
		});

		unrollFor(for (i in 0...3) {
			var fighter = f[i];
			if (fighter != null && fighter.team != team) {
				fighter.health -= (i == 0) ? team.attack : team.attack >> SIDE_ATTACK_FACTOR;
				if (fighter.health < 0) {
					// Not sure why is this loop here...
					while (fighter.health < 0)
						fighter.health += team.newHealth;
					fighter.team = team;
				}
				return;
			}
		});

		unrollFor(for (i in 0...1) {
			var fighter = f[i];
			if (fighter != null && fighter.team == team) {
				fighter.health += team.defense;
				if (fighter.health >= MAX_HEALTH)
					fighter.health = MAX_HEALTH - 1;
				return;
			}
		});
	}
}
