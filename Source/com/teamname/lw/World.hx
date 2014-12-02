
package com.teamname.lw;

class World {
	public var mesh : Mesh<Int>;

	public function new() {
		mesh = Mesh.createRectangularMesh(128, 128);
	}
}