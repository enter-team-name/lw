
package com.teamname.lw.macro;

import com.teamname.lw.mesh.*;

import haxe.ds.Vector;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class MeshMacros {
	macro static function fill<T>(zl : ExprOf<Vector<MeshZone<T>>>, extra : Array<Expr>) {
		if (extra.length != 12) throw "Must pass exactly 12 arguments";
		var map = [10, 11,  0,  1,
		            9,          2,
		            8,          3,
		            7,  6,  5,  4];
		var exprs = [macro var zl = $zl];

		for (i in 0...12) {
			switch (extra[i].expr) {
				case EConst(CIdent("_")):
				default:
					exprs.push(macro zl[$v{map[i]}] = ${extra[i]});
			}
		}

		var res = {
			expr : ExprDef.EBlock(exprs),
			pos : zl.pos
		}
		//trace(ExprTools.toString(res));
		return res;
	}
}