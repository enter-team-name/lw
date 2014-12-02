
package com.teamname.lw;

class World {
	public var mesh : Mesh<Int>;

	public function new() {
		mesh = new Mesh<Int>(512, 256);
		mesh.addRectangularMesh(0, 0, 512, 256);
		mesh.merge(6);
	}
}