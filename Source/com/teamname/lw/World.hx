
package com.teamname.lw;

class World {
	public var mesh : Mesh<Void>;

	public function new() {
		mesh = new Mesh<Void>(512, 2048);
		mesh.addRectangularMesh(0, 0, 512, 2048);
		mesh.merge(6);
	}
}