
package com.teamname.lw;

import openfl.display.BitmapData;
import openfl.Assets;

class World {
	public var mesh : Mesh<Void>;

	public function new() {
		var map_name = "big";
		var bitmapData = Assets.getBitmapData("maps/" + map_name + ".png");
		var w = Std.int(bitmapData.rect.width);
		var h = Std.int(bitmapData.rect.height);
		mesh = new Mesh<Void>(w, h);
		mesh.addMeshFromMap(map_name);
		mesh.merge(6);
	}
}