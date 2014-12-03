
package com.teamname.lw;

class World {
	public var mesh : Mesh<Void>;

	public function new() {
		mesh = new Mesh<Void>(1000, 1000);//TODO: fix sizes
		mesh.addMeshFromMap("puckman");
		mesh.merge(6);
	}
}