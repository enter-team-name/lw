
package com.teamname.lw.pathfinder;

import openfl.display.BitmapData;

interface Pathfinder {
	public function setTarget(x : Int, y : Int, dist : Int) : Void;
	public function getMoveDirection(x : Int, y : Int) : Int;
	public function loadMap(bmp : BitmapData) : Void;
	public function tick(time : Int) : Void;
	public function getDebugBitmap() : BitmapData;
}