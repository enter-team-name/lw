package com.teamname.lw;

import com.teamname.lw.Utils;
import haxe.ds.Vector;

class Fighter<T> {
	var x(default, null) : Int;
	var y(default, null) : Int;
	var health(default, null) : Int;
	var team(default, null) : Int;
	var last_dir(default, null) : Int;

	public static inline var SIDE_ATTACK_FACTOR = 4;

	public static inline var NB_SENS_MOVE = 2;
	public static inline var NB_TRY_MOVE = 5;
	public static inline var NB_LOCAL_DIRS = 16;

	public static var LOCAL_DIR = new Vector<Int>(NB_LOCAL_DIRS * 2);

	// static int FIGHTER_MOVE_DIR[NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE] =
	public static var FIGHTER_MOVE_DIR : Vector<Vector<Vector<Int>>> =
	[[	[DIR_NNE, DIR_NE , DIR_NW , DIR_ENE, DIR_WNW],
		[DIR_NE , DIR_ENE, DIR_NNE, DIR_SE , DIR_NW ],
		[DIR_ENE, DIR_NE , DIR_SE , DIR_NNE, DIR_SSE],
		[DIR_ESE, DIR_SE , DIR_NE , DIR_SSE, DIR_NNE],
		[DIR_SE , DIR_SSE, DIR_ESE, DIR_SW , DIR_NE ],
		[DIR_SSE, DIR_SE , DIR_SW , DIR_ESE, DIR_WSW],
		[DIR_SSW, DIR_SW , DIR_SE , DIR_WSW, DIR_ESE],
		[DIR_SW , DIR_WSW, DIR_SSW, DIR_NW , DIR_SE ],
		[DIR_WSW, DIR_SW , DIR_NW , DIR_SSW, DIR_NNW],
		[DIR_WNW, DIR_NW , DIR_SW , DIR_NNW, DIR_SSE],
		[DIR_NW , DIR_NNW, DIR_WNW, DIR_NE , DIR_SW ],
		[DIR_NNW, DIR_NW , DIR_NE , DIR_WNW, DIR_ENE]],

	[	[DIR_NNE, DIR_NE , DIR_NW , DIR_ENE, DIR_WNW],
		[DIR_NE , DIR_NNE, DIR_ENE, DIR_NW , DIR_SE ],
		[DIR_ENE, DIR_NE , DIR_SE , DIR_NNE, DIR_SSE],
		[DIR_ESE, DIR_SE , DIR_NE , DIR_SSE, DIR_NNE],
		[DIR_SE , DIR_ESE, DIR_SSE, DIR_NE , DIR_SW ],
		[DIR_SSE, DIR_SE , DIR_SW , DIR_ESE, DIR_WSW],
		[DIR_SSW, DIR_SW , DIR_SE , DIR_WSW, DIR_ESE],
		[DIR_SW , DIR_SSW, DIR_WSW, DIR_SE , DIR_NW ],
		[DIR_WSW, DIR_SW , DIR_NW , DIR_SSW, DIR_NNW],
		[DIR_WNW, DIR_NW , DIR_SW , DIR_NNW, DIR_SSE],
		[DIR_NW , DIR_WNW, DIR_NNW, DIR_SW , DIR_NE ],
		[DIR_NNW, DIR_NW , DIR_NE , DIR_WNW, DIR_ENE]]];

	public static inline var FIGHTER_MOVE_X_REF : Vector<Int> =
  		[0, 1, 1, 1, 1, 0, 0, -1, -1, -1, -1, 0];

	public static inline var FIGHTER_MOVE_Y_REF : Vector<Int> =
		[-1, -1, 0, 0, 1, 1, 1, 1, 0, 0, -1, -1];

	public static var FIGHTER_MOVE_OFFSET_ASM = new Vector<Vector<Int>> [NB_SENS_MOVE][NB_DIRS * NB_TRY_MOVE];
	public static var FIGHTER_MOVE_XY_ASM = new Vector<Vector<Int>> [NB_SENS_MOVE][NB_DIRS * NB_TRY_MOVE];

	public static var FIGHTER_MOVE_OFFSET = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];
	public static var FIGHTER_MOVE_X = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];
	public static var FIGHTER_MOVE_Y = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];


	public function new(x : Int, y : Int, team : Int, health : Int) {
		this.x = x;
		this.y = y;
		this.health = health;
		this.team = team;
	}

	public function init_move_fighters() : Void {
		var i : Int, j : Int, k : Int, dir : Int;

		for (k in 0...NB_SENS_MOVE)
			for (i in 0...NB_DIRS)
				for (j in 0...NB_TRY_MOVE) {
					dir = FIGHTER_MOVE_DIR[k][i][j];
					FIGHTER_MOVE_X[k][i][j] = FIGHTER_MOVE_X_REF[dir];
					FIGHTER_MOVE_Y[k][i][j] = FIGHTER_MOVE_Y_REF[dir];

					FIGHTER_MOVE_OFFSET[k][i][j] = 0;
					if (FIGHTER_MOVE_X[k][i][j] == 1)
						++(FIGHTER_MOVE_OFFSET[k][i][j]);
					if (FIGHTER_MOVE_X[k][i][j] == -1)
						--(FIGHTER_MOVE_OFFSET[k][i][j]);
					if (FIGHTER_MOVE_Y[k][i][j] == 1)
						FIGHTER_MOVE_OFFSET[k][i][j] += CURRENT_AREA_W;
					if (FIGHTER_MOVE_Y[k][i][j] == -1)
						FIGHTER_MOVE_OFFSET[k][i][j] -= CURRENT_AREA_W;

					FIGHTER_MOVE_OFFSET_ASM[k][i * NB_TRY_MOVE + j] =
						FIGHTER_MOVE_OFFSET[k][i][j];
					FIGHTER_MOVE_XY_ASM[k][i * NB_TRY_MOVE + j] =
						FIGHTER_MOVE_Y[k][i][j] * 65536 + FIGHTER_MOVE_X[k][i][j];
		}

		// Lol, where are CURRENT_ARMY_SIZE from?
		for (i in 0...CURRENT_ARMY_SIZE)
			disp_fighter (CURRENT_ARMY + i);

		/*
		* note:
		* NB_LOCAL_DIRS is 16 but it's true that 12 is enough.
		* However, I find it safer to reserve 16 slots, since
		* this way all the combinations of 1,2,4 and 8 can
		* be handled correctly - even if some are impossible.
		* And it has the advantage to avoid confusion with
		* the 12 directions represented by NB_DIRS.
		*/
		for (i in 1...NB_LOCAL_DIRS+1) {
			for (j in 0...2) {
				k = -1;
				switch (i) {
					case 1:
						k = DIR_NNW if j else DIR_NNE;
					case 3:
						k = DIR_NE;
					case 2:
						k = DIR_ENE if j else DIR_ESE;
					case 6:
						k = DIR_SE;
					case 4:
						k = DIR_SSE if j else DIR_SSW;
					case 12:
						k = DIR_SW;
					case 8:
						k = DIR_WSW if j else DIR_WNW;
					case 9:
						k = DIR_NW;
				}
				LOCAL_DIR[(i - 1) * 2 + j] = k;
			}
		}
	}

	public function get_main_dir(mesh : Mesh, team : Int, sens : Int, start : Int) : Void {
		var i : Int, dir : Int, dist : Int;
		MESH *mesh2;

		dist = AREA_START_GRADIENT;
		dir = -1;
		i = start;

		if (sens) {
			do {
				if ((mesh2 = mesh.link[i]))
					if (mesh2.info[team].state.grad < dist) {
						dir = i;
						dist = mesh2.info[team].state.grad;
					}
				i = (i + 1) if (i < NB_DIRS - 1) else 0;
			} while (i != start);
		}
		else {
			do {
				if ((mesh2 = mesh.link[i]))
					if (mesh2.info[team].state.grad < dist) {
						dir = i;
						dist = mesh2.info[team].state.grad;
					}
				i = (i - 1) if (i > 0) else (NB_DIRS - 1);
			} while (i != start);
		}

		if (dir >= 0)
			return dir;
		else
			return (GLOBAL_CLOCK % NB_TEAMS);
	}

	public static function get_close_dir (MESH * mesh, FIGHTER * f, team : Int, sens : Int, start : Int) : Int {
		var cursor_x : Int, cursor_y : Int, fighter_x : Int, fighter_y : Int;
		var code_dir = 0, dir : Int;

		fighter_x = f.x;
		fighter_y = f.y;
		cursor_x = mesh.info[team].update.cursor.x;
		cursor_y = mesh.info[team].update.cursor.y;

		if (cursor_y < fighter_y)
			code_dir += 1;
		if (cursor_x > fighter_x)
			code_dir += 2;
		if (cursor_y > fighter_y)
			code_dir += 4;
		if (cursor_x < fighter_x)
			code_dir += 8;

		if (code_dir)
			dir = LOCAL_DIR[(code_dir - 1) * 2 + (1 if sens else 0)];
		else
			dir = start;

		return dir;
	}

	/*------------------------------------------------------------------*/
	public function move_fighters () {
		int attack[NB_TEAMS], defense[NB_TEAMS], new_health[NB_TEAMS];
		int i, dir, team, coef;
		FIGHTER *f;
		PLACE *p, *p0, *p1, *p2, *p3, *p4;
		int *move_offset, *move_x, *move_y;
		int sens, start, table;
		var cpu_influence = [0, 0, 0, 0, 0, 0];
		int temp = 0;

		sens = 0;

		for (i in 0...NB_TEAMS)
			if (CURRENT_CURSOR[i].control_type == CONFIG_CONTROL_TYPE_CPU
				&& CURRENT_CURSOR[i].active)
				cpu_influence[CURRENT_CURSOR[i].team] =
					LW_CONFIG_CURRENT_RULES.cpu_advantage;

		for (i in 0...PLAYING_TEAMS) {
			coef = ACTIVE_FIGHTERS[i] * PLAYING_TEAMS - CURRENT_ARMY_SIZE;
			coef *= 256;
			coef /= CURRENT_ARMY_SIZE;
			if (coef > 256)
				coef = 256;

			coef *=
				(LW_CONFIG_CURRENT_RULES.number_influence -
				8) * (LW_CONFIG_CURRENT_RULES.number_influence - 8);
			coef /= 64;
			if (LW_CONFIG_CURRENT_RULES.number_influence < 8)
				coef = -coef;
			if (coef < 0)
				coef /= 2;
			coef += 256;

			attack[i] = (coef *
				fsqrt (fsqrt (1 << (LW_CONFIG_CURRENT_RULES.fighter_attack
				+ cpu_influence[i])))) / (256 * 8);
			if (attack[i] >= MAX_FIGHTER_HEALTH)
				attack[i] = MAX_FIGHTER_HEALTH - 1;
			if (attack[i] < 1)
				attack[i] = 1;

			defense[i] = (coef *
				fsqrt (fsqrt
				(1 <<
				(LW_CONFIG_CURRENT_RULES.fighter_defense +
				cpu_influence[i])))) / (256 * 256);
			if (defense[i] >= MAX_FIGHTER_HEALTH)
				defense[i] = MAX_FIGHTER_HEALTH - 1;
			if (defense[i] < 1)
				defense[i] = 1;

			new_health[i] = (coef *
				fsqrt (fsqrt
				(1 <<
				(LW_CONFIG_CURRENT_RULES.fighter_new_health +
				cpu_influence[i])))) / (256 * 4);
			if (new_health[i] >= MAX_FIGHTER_HEALTH)
				new_health[i] = MAX_FIGHTER_HEALTH - 1;
			if (new_health[i] < 1)
				new_health[i] = 1;

			ACTIVE_FIGHTERS[i] = 0;
		}
		start = (GLOBAL_CLOCK / 6) % NB_DIRS;
		table = (GLOBAL_CLOCK / 3) % 2;
		f = CURRENT_ARMY;

		temp = 0;
		for (i in 0...CURRENT_ARMY_SIZE) {
			team = f.team;
			ACTIVE_FIGHTERS[team]++;
			start =  (start + 1) if (start < NB_DIRS - 1) else 0;

			p = CURRENT_AREA + (f.y * CURRENT_AREA_W + f.x);

			if (p.mesh.info[team].update.time >= 0) {
				p.mesh.info[team].state.dir =
					get_close_dir (p.mesh, f, team, (sens++) % 2, start);
			}
			else if ((-p.mesh.info[team].update.time) < GLOBAL_CLOCK) {
				p.mesh.info[team].state.dir =
					get_main_dir (p.mesh, team, (sens++) % 2, start);
				p.mesh.info[team].update.time = -GLOBAL_CLOCK;
			}

			dir = p.mesh.info[team].state.dir;

			move_offset = FIGHTER_MOVE_OFFSET[table][dir];
			move_x = FIGHTER_MOVE_X[table][dir];
			move_y = FIGHTER_MOVE_Y[table][dir];

			if (((p0 = p + move_offset[0]).mesh) && (!p0.fighter)) {
				erase_fighter (f);
				p0.fighter = f;
				p.fighter = NULL;
				f.x += move_x[0];
				f.y += move_y[0];
				disp_fighter (f);
			}
			else if (((p1 = p + move_offset[1]).mesh) && (!p1.fighter)) {
				erase_fighter (f);
				p1.fighter = f;
				p.fighter = NULL;
				f.x += move_x[1];
				f.y += move_y[1];
				disp_fighter (f);
			}
			else if (((p2 = p + move_offset[2]).mesh) && (!p2.fighter)) {
				erase_fighter (f);
				p2.fighter = f;
				p.fighter = NULL;
				f.x += move_x[2];
				f.y += move_y[2];
				disp_fighter (f);
			}
			else if (((p3 = p + move_offset[3]).mesh) && (!p3.fighter)) {
				erase_fighter (f);
				p3.fighter = f;
				p.fighter = NULL;
				f.x += move_x[3];
				f.y += move_y[3];
				disp_fighter (f);
			}
			else if (((p4 = p + move_offset[4]).mesh) && (!p4.fighter)) {
				erase_fighter (f);
				p4.fighter = f;
				p.fighter = NULL;
				f.x += move_x[4];
				f.y += move_y[4];
				disp_fighter (f);
			}
			else if (p0.mesh && p0.fighter && p0.fighter.team != team) {
				p0.fighter.health -= attack[team];
				if (p0.fighter.health < 0) {
					while (p0.fighter.health < 0)
						p0.fighter.health += new_health[team];
					p0.fighter.team = team;
				}
				disp_fighter (p0.fighter);
			}
			else if (p1.mesh && p1.fighter && p1.fighter.team != team) {
				p1.fighter.health -= attack[team]
					>> SIDE_ATTACK_FACTOR;
				if (p1.fighter.health < 0) {
					while (p1.fighter.health < 0)
						p1.fighter.health +=
							new_health[team];
					p1.fighter.team = team;
				}
				disp_fighter (p1.fighter);
			}
			else if (p2.mesh && p2.fighter && p2.fighter.team != team) {
				p2.fighter.health -= attack[team]
					>> SIDE_ATTACK_FACTOR;
				if (p2.fighter.health < 0) {
					while (p2.fighter.health < 0)
						p2.fighter.health +=
							new_health[team];
					p2.fighter.team = team;
				}
				disp_fighter (p2.fighter);
			}
			else if (p0.mesh && p0.fighter && p0.fighter.team == team) {
				p0.fighter.health +=
					defense[team];
				if (p0.fighter.health >= MAX_FIGHTER_HEALTH)
					p0.fighter.health =
						MAX_FIGHTER_HEALTH - 1;
				disp_fighter (p0.fighter);
			}
			f++;
		}
	}
}
