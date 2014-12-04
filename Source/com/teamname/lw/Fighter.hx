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
	static inline var FIGHTER_MOVE_DIR =
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

	public static inline var FIGHTER_MOVE_X_REF =
  		[0, 1, 1, 1, 1, 0, 0, -1, -1, -1, -1, 0];

	public static inline var FIGHTER_MOVE_Y_REF =
		[-1, -1, 0, 0, 1, 1, 1, 1, 0, 0, -1, -1];

	// public static var FIGHTER_MOVE_OFFSET_ASM = new Vector<Vector<Int>> [NB_SENS_MOVE][NB_DIRS * NB_TRY_MOVE];
	// public static var FIGHTER_MOVE_XY_ASM = new Vector<Vector<Int>> [NB_SENS_MOVE][NB_DIRS * NB_TRY_MOVE];

	// public static var FIGHTER_MOVE_OFFSET = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];
	// public var FIGHTER_MOVE_X = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];
	// public var FIGHTER_MOVE_Y = new Vector<Vector<Vector<Int>>> [NB_SENS_MOVE][NB_DIRS][NB_TRY_MOVE];


	public function new(x : Int, y : Int, team : Int, health : Int) {
		this.x = x;
		this.y = y;
		this.health = health;
		this.team = team;
	}
}