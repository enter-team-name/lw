
package com.teamname.lw;

class Settings {
	// Original LW :  0     | 8    | 16   || x
	// This version:  -1    | 0    | 1    || x/8 - 1
	public var winnerHelp : Float = 0.0;

	// Original LW :  0     | 8    | 16   || x
	// This version:  1/8   | 1/2  | 2    || 2**(x/4 - 3)
	public var fighterAttack : Float = 4096;//0.5;

	// Original LW :  0     | 8    | 16   || x
	// This version:  1/256 | 1/64 | 1/16 || 2**(x/4 - 8)
	public var fighterDefense : Float = 128;//1/64;

	// Original LW :  0     | 8    | 16   || x
	// This version:  1/4   | 1    | 4    || 2**(x/4 - 2)
	public var fighterNewHealth : Float = 8192;//1.0;

	// Original LW :  0     | 2    | 4    || x
	// This version:  1     | √2   | 2    || 2**(x/4)
	public var cpuAdvantage : Float = 0.0;


	public function new() {

	}
}