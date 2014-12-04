package com.teamname.lw;

@:enum
abstract Dir(Int) from Int to Int {
	var DIR_NNE = 0;
	var DIR_NE = 1;
	var DIR_ENE = 2;
	var DIR_ESE = 3;
	var DIR_SE = 4;
	var DIR_SSE = 5;
	var DIR_SSW = 6;
	var DIR_SW = 7;
	var DIR_WSW = 8;
	var DIR_WNW = 9;
	var DIR_NW = 10;
	var DIR_NNW = 11;

	public static var xOffsets = [ 1,  2,  2,  2,  2,  1, -1, -2, -2, -2, -2, -1];
	public static var yOffsets = [-2, -2, -1,  1,  2,  2,  2,  2,  1, -1, -2, -2];

	public inline function xOffset() {
		return xOffsets[this];
	}

	public inline function yOffset() {
		return yOffsets[this];
	}
}