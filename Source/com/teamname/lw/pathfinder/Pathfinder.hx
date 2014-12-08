
package com.teamname.lw.pathfinder;

import de.polygonal.ds.Array2;

import openfl.display.BitmapData;

interface Pathfinder {
	public var targetX(default, null) : Int;
	public var targetY(default, null) : Int;
	public function setTarget(x : Int, y : Int, dist : Int) : Void;
	public function getMoveDirection(x : Int, y : Int, time : Int) : Dir;
	public function onWallsUpdate(x : Int, y : Int, w : Int, h : Int, walls : Array2<Bool>) : Void;
	public function tick(time : Int) : Void;
	public function getDebugBitmap(extra : Dynamic) : BitmapData;
}