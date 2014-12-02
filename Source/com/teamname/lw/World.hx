
package com.teamname.lw;

class World {
	public var mesh : Mesh<Int>;

	public function new() {
		mesh = new Mesh<Int>(128, 128);
		mesh.addRectangularMesh(0, 0, 128, 128);
		mesh.merge(4);
	}
}