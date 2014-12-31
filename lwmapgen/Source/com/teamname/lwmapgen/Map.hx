package com.teamname.lwmapgen;

import com.teamname.lwmapgen.Main;
import com.teamname.lwmapgen.generator.GeneratorInterface;
import com.teamname.lwmapgen.Utils.*;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

class Dot {
	public var x : Int;
	public var y : Int;

	public function new(x : Int, y : Int) {
		this.x = x;
		this.y = y;
	}
}

class Map {
	public var width(default, null) : Int;
	public var height(default, null) : Int;
	public var num_row(default, null) : Int;
	public var num_col(default, null) : Int;
	public var sec_width(default, null) : Float;
	public var sec_height(default, null) : Float;
	
	public var background : Int = 0;
	public var bitmap(default, null) : BitmapData;

	private var generatorInterface : GeneratorInterface = new GeneratorInterface();
	private var map_size : Array<Array<Int>> = [
		[128, 95 ],		/* 0 */
		[160, 120],		/* 1 */
		[256, 190],		/* 2 */
		[320, 240],		/* 3 */
		[512, 380],		/* 4 */
		[640, 480]];	/* 5 */

	private var map_grid_size : Array<Array<Int>> = [
		[2, 3],		/* 0 */
		[4, 6],		/* 1 */
		[6, 9],		/* 2 */
		[8, 12],	/* 3 */
		[10, 15],	/* 4 */
		[12, 18],	/* 5 */
		[14, 21],	/* 6 */
		[16, 24],	/* 7 */
		[18, 26]];	/* 8 */

	public function new() { }

	public function generate(?size : Int = -1, ?gridSize : Int = -1, ?genMethodId : Int = -1) {
		if (size == -1)
			size = Std.random(map_size.length);

		if (gridSize == -1)
			gridSize = Std.random(map_grid_size.length);

		if (genMethodId == -1)
			genMethodId = Std.random(generatorInterface.count());

		this.width  = map_size[size][0];
		this.height = map_size[size][1];

		this.num_row = map_grid_size[gridSize][0];
		this.num_col = map_grid_size[gridSize][1];


		this.sec_width  = this.width  / this.num_col;
		this.sec_height = this.height / this.num_row;
		
		this.background = 0;

		this.bitmap = generatorInterface.call(genMethodId);
		// Draw outline. This must be before this /\, but that's not so bad, or maybe even better.
		var sprite : Sprite = new Sprite();
		var g = sprite.graphics;
		g.lineStyle(1, 0x000000);
		g.drawRect(0, 0, this.width - 1, this.height - 1);
		this.bitmap.draw(sprite);
	}

	public function Offset(r : Int, c : Int) : Dot {
		return new Dot(Std.int(c * this.sec_width),
						Std.int(r * this.sec_height));
	}

	public function RandPointSection(pad : Int) : Dot {
		return new Dot(RandNum(pad, this.sec_width - pad),
						RandNum(pad, this.sec_height - pad));
	}

	public function RandPointSectionOffset(r : Int, c : Int, pad : Int) : Dot {
		var offset = Offset(r, c);
		return new Dot(RandNum(pad, this.sec_width - pad) + offset.x,
						RandNum(pad, this.sec_height - pad) + offset.y);
	}

	public function SectionCenter(r : Int, c : Int) : Dot {
		var offset = Offset(r, c);
		return new Dot( Std.int(this.sec_width/2.0)+offset.x,
						Std.int(this.sec_height/2.0)+offset.y);
	}
}