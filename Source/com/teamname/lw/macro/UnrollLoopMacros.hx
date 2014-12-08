
package com.teamname.lw.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

class UnrollLoopMacros {
	#if macro
	private static function parseIterable(e : Expr) : Array<Expr> {
		try {
			switch (e.expr) {
				case EBinop(OpInterval, left, right):
					//var t = cast(ExprTools.getValue(e), IntIterator);
					var range = ExprTools.getValue(left)...ExprTools.getValue(right);
					return [for (i in range) macro $v{i}];
				case ExprDef.EArrayDecl(values):
					return values;
				default:
			}
		} catch (_ : Dynamic) {
		}
		trace(e.expr);
		Context.error("Iterable constant expected, " + ExprTools.toString(e) + " found.", e.pos);
		return [];
	}

	/*private static function unroll(e : Expr, callback : Expr -> Expr -> Expr, ?initialExpr : Expr) : Expr {
		if (initialExpr == null) initialExpr = macro null;
		switch (e.expr) {
			case EFor(_.expr => EIn(_.expr => EConst(CIdent(variable)), iterable), body):
				var body = unroll(body, callback);
				var exprs = [for (i in parseIterable(iterable)) macro {var $variable = $i; $body;}];
				var res = initialExpr;
				for (expr in exprs) res = callback(res, expr);
				trace(ExprTools.toString(res));
				return res;
			default:
				return e;
		}
	}*/
	#end

	macro public static function unrollFor(e : Expr) : Expr {
		// return unroll(e, function(e1, e2) {
		// 	return macro {$e1; $e2;};
		// }, macro true);
		switch (e.expr) {
			case EFor(_.expr => EIn(_.expr => EConst(CIdent(variable)), iterable), body):
				var body = unrollFor(body);
				var exprs = [for (i in parseIterable(iterable)) macro {var $variable = $i; $body;}];
				var res = {
					expr : ExprDef.EBlock(exprs),
					pos : e.pos
				}
				trace(ExprTools.toString(res));
				return res;
			default:
				return e;
		}
	}

	/*macro public static function unrollAll(e : Expr) : Expr {
		return unroll(e, function(e1, e2) {
			return macro $e1 && $e2;
		}, macro true);
	}

	macro public static function unrollAny(e : Expr) : Expr {
		return unroll(e, function(e1, e2) {
			return macro $e1 || $e2;
		}, macro false);
	}

	macro public static function unrollSum(e : Expr) : Expr {
		return unroll(e, function(e1, e2) {
			return macro $e1 + $e2;
		}, macro 0);
	}*/
}