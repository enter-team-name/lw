
package com.teamname.lw.input;

interface InputMethod {
	public var dx(default, null) : Int;
	public var dy(default, null) : Int;
	public function tick(?e : MouseEvent = null) : Void;
}