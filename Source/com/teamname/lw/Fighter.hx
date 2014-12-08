package com.teamname.lw;

import com.teamname.lw.pathfinder.Pathfinder;
import com.teamname.lw.Utils;

import haxe.ds.Vector;

import de.polygonal.ds.Hashable;

class Fighter implements Hashable {
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

		for (i in 0...5) {
			var newX = x + dirs[i].xOffset();
			var newY = y + dirs[i].yOffset();
			f[i] = w.getFighter(newX, newY);
			if (f[i] == null) {
				w.moveFighter(this, newX, newY);
				return;
			}
		}

		for (i in 0...3) {
			var newX = x + dirs[i].xOffset();
			var newY = y + dirs[i].yOffset();
			if (f[i].team != this.team) {
				// TODO : Attack!
				return;
			}
		}

		/*for (i in 0...1)*/ {
			var newX = x + mainDir.xOffset();
			var newY = y + mainDir.yOffset();
			// TODO : HEAL
			return;
		}
	}

	

	// /*------------------------------------------------------------------*/
	// public function move_fighters () {
	// 	int attack[NB_TEAMS], defense[NB_TEAMS], new_health[NB_TEAMS];
	// 	int i, dir, team, coef;
	// 	FIGHTER *f;
	// 	PLACE *p, *p0, *p1, *p2, *p3, *p4;
	// 	int *move_offset, *move_x, *move_y;
	// 	int sens, start, table;
	// 	var cpu_influence = [0, 0, 0, 0, 0, 0];
	// 	int temp = 0;

	// 	sens = 0;

	// 	for (i in 0...NB_TEAMS)
	// 		if (CURRENT_CURSOR[i].control_type == CONFIG_CONTROL_TYPE_CPU
	// 			&& CURRENT_CURSOR[i].active)
	// 			cpu_influence[CURRENT_CURSOR[i].team] =
	// 				LW_CONFIG_CURRENT_RULES.cpu_advantage;

	// 	for (i in 0...PLAYING_TEAMS) {
	// 		coef = ACTIVE_FIGHTERS[i] * PLAYING_TEAMS - CURRENT_ARMY_SIZE;
	// 		coef *= 256;
	// 		coef /= CURRENT_ARMY_SIZE;
	// 		if (coef > 256)
	// 			coef = 256;

	// 		coef *=
	// 			(LW_CONFIG_CURRENT_RULES.number_influence -
	// 			8) * (LW_CONFIG_CURRENT_RULES.number_influence - 8);
	// 		coef /= 64;
	// 		if (LW_CONFIG_CURRENT_RULES.number_influence < 8)
	// 			coef = -coef;
	// 		if (coef < 0)
	// 			coef /= 2;
	// 		coef += 256;

	// 		attack[i] = (coef *
	// 			fsqrt (fsqrt (1 << (LW_CONFIG_CURRENT_RULES.fighter_attack
	// 			+ cpu_influence[i])))) / (256 * 8);
	// 		if (attack[i] >= MAX_FIGHTER_HEALTH)
	// 			attack[i] = MAX_FIGHTER_HEALTH - 1;
	// 		if (attack[i] < 1)
	// 			attack[i] = 1;

	// 		defense[i] = (coef *
	// 			fsqrt (fsqrt
	// 			(1 <<
	// 			(LW_CONFIG_CURRENT_RULES.fighter_defense +
	// 			cpu_influence[i])))) / (256 * 256);
	// 		if (defense[i] >= MAX_FIGHTER_HEALTH)
	// 			defense[i] = MAX_FIGHTER_HEALTH - 1;
	// 		if (defense[i] < 1)
	// 			defense[i] = 1;

	// 		new_health[i] = (coef *
	// 			fsqrt (fsqrt
	// 			(1 <<
	// 			(LW_CONFIG_CURRENT_RULES.fighter_new_health +
	// 			cpu_influence[i])))) / (256 * 4);
	// 		if (new_health[i] >= MAX_FIGHTER_HEALTH)
	// 			new_health[i] = MAX_FIGHTER_HEALTH - 1;
	// 		if (new_health[i] < 1)
	// 			new_health[i] = 1;

	// 		ACTIVE_FIGHTERS[i] = 0;
	// 	}
	// 	start = (GLOBAL_CLOCK / 6) % NB_DIRS;
	// 	table = (GLOBAL_CLOCK / 3) % 2;
	// 	f = CURRENT_ARMY;

	// 	temp = 0;
	// 	for (i in 0...CURRENT_ARMY_SIZE) {
	// 		team = f.team;
	// 		ACTIVE_FIGHTERS[team]++;
	// 		start =  (start + 1) if (start < NB_DIRS - 1) else 0;

	// 		p = CURRENT_AREA + (f.y * CURRENT_AREA_W + f.x);

	// 		if (p.mesh.info[team].update.time >= 0) {
	// 			p.mesh.info[team].state.dir =
	// 				get_close_dir (p.mesh, f, team, (sens++) % 2, start);
	// 		}
	// 		else if ((-p.mesh.info[team].update.time) < GLOBAL_CLOCK) {
	// 			p.mesh.info[team].state.dir =
	// 				get_main_dir (p.mesh, team, (sens++) % 2, start);
	// 			p.mesh.info[team].update.time = -GLOBAL_CLOCK;
	// 		}

	// 		dir = p.mesh.info[team].state.dir;

	// 		move_offset = FIGHTER_MOVE_OFFSET[table][dir];
	// 		move_x = FIGHTER_MOVE_X[table][dir];
	// 		move_y = FIGHTER_MOVE_Y[table][dir];

	// 		if (((p0 = p + move_offset[0]).mesh) && (!p0.fighter)) {
	// 			erase_fighter (f);
	// 			p0.fighter = f;
	// 			p.fighter = NULL;
	// 			f.x += move_x[0];
	// 			f.y += move_y[0];
	// 			disp_fighter (f);
	// 		}
	// 		else if (((p1 = p + move_offset[1]).mesh) && (!p1.fighter)) {
	// 			erase_fighter (f);
	// 			p1.fighter = f;
	// 			p.fighter = NULL;
	// 			f.x += move_x[1];
	// 			f.y += move_y[1];
	// 			disp_fighter (f);
	// 		}
	// 		else if (((p2 = p + move_offset[2]).mesh) && (!p2.fighter)) {
	// 			erase_fighter (f);
	// 			p2.fighter = f;
	// 			p.fighter = NULL;
	// 			f.x += move_x[2];
	// 			f.y += move_y[2];
	// 			disp_fighter (f);
	// 		}
	// 		else if (((p3 = p + move_offset[3]).mesh) && (!p3.fighter)) {
	// 			erase_fighter (f);
	// 			p3.fighter = f;
	// 			p.fighter = NULL;
	// 			f.x += move_x[3];
	// 			f.y += move_y[3];
	// 			disp_fighter (f);
	// 		}
	// 		else if (((p4 = p + move_offset[4]).mesh) && (!p4.fighter)) {
	// 			erase_fighter (f);
	// 			p4.fighter = f;
	// 			p.fighter = NULL;
	// 			f.x += move_x[4];
	// 			f.y += move_y[4];
	// 			disp_fighter (f);
	// 		}
	// 		else if (p0.mesh && p0.fighter && p0.fighter.team != team) {
	// 			p0.fighter.health -= attack[team];
	// 			if (p0.fighter.health < 0) {
	// 				while (p0.fighter.health < 0)
	// 					p0.fighter.health += new_health[team];
	// 				p0.fighter.team = team;
	// 			}
	// 			disp_fighter (p0.fighter);
	// 		}
	// 		else if (p1.mesh && p1.fighter && p1.fighter.team != team) {
	// 			p1.fighter.health -= attack[team]
	// 				>> SIDE_ATTACK_FACTOR;
	// 			if (p1.fighter.health < 0) {
	// 				while (p1.fighter.health < 0)
	// 					p1.fighter.health +=
	// 						new_health[team];
	// 				p1.fighter.team = team;
	// 			}
	// 			disp_fighter (p1.fighter);
	// 		}
	// 		else if (p2.mesh && p2.fighter && p2.fighter.team != team) {
	// 			p2.fighter.health -= attack[team]
	// 				>> SIDE_ATTACK_FACTOR;
	// 			if (p2.fighter.health < 0) {
	// 				while (p2.fighter.health < 0)
	// 					p2.fighter.health +=
	// 						new_health[team];
	// 				p2.fighter.team = team;
	// 			}
	// 			disp_fighter (p2.fighter);
	// 		}
	// 		else if (p0.mesh && p0.fighter && p0.fighter.team == team) {
	// 			p0.fighter.health +=
	// 				defense[team];
	// 			if (p0.fighter.health >= MAX_FIGHTER_HEALTH)
	// 				p0.fighter.health =
	// 					MAX_FIGHTER_HEALTH - 1;
	// 			disp_fighter (p0.fighter);
	// 		}
	// 		f++;
	// 	}
	// }
}
