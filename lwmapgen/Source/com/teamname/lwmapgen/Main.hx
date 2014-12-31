package com.teamname.lwmapgen;

import com.teamname.lwmapgen.generator.*;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.MouseEvent;

import haxe.Timer;

import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;

import Math;

class Main extends Sprite {
	public static var instance : Main;

	var bitmap : Bitmap;
	public var map : com.teamname.lwmapgen.Map = new com.teamname.lwmapgen.Map();

	var maxImageHeight : Int = 500;
	var maxImageWidth : Int = 800;

	var func = [
		[ "Random", "Pick random generating algorithm." ],
		[ "BigQuad", "One big, solid quad that takes up most of the map." ],
		[ "Boxes", "A bunch of boxes of the same size." ],
		[ "Bubbles", "Random bubbles." ],
		[ "Circles", "Random circles." ],
		[ "Circuit", "A map that looks like a circuit board." ],
		[ "Hole", "Randomly shaped hole." ],
		[ "Lines", "A grid of random lines." ],
		[ "RandBox", "Random boxes." ],
		[ "RandPoly", "One big, solid, random polygon that takes up most of the map." ],
		[ "RandPolyCut", "Do RandPoly then cut lines across it." ],
		[ "Street", "A map that looks like a bunch of streets." ],
		[ "Worms", "Random little worms." ]];
	
	var map_size = ['Random', '128x95', '160x120', '256x190', '320x240', '512x380', '640x480'];
	var grid_size = ['Random', '2x3', '4x6', '6x9', '8x12', '10x15', '12x18', '14x21', '16x24', '18x26'];

	var selectedFuncId = 0;
	var selectedMapSizeId = 0;
	var selectedGridSizeId = 0;

	public function new() {
		if (instance != null) throw "Main is a singleton!";
		instance = this;
		super();
		trace("Hello World!");

		UIBuilder.init();
		drawGUI();
	}

	public function generateNewMap(?e : MouseEvent = null) {
		map.generate(	selectedMapSizeId - 1,
						selectedGridSizeId - 1,
						selectedFuncId - 1);
		bitmap.scaleX = bitmap.scaleY = Math.min(maxImageHeight / map.height, maxImageWidth / map.width);
		bitmap.bitmapData = map.bitmap;
	}

	public function updateLabels(?e : MouseEvent = null) {
		UIBuilder.getAs('algoText', Text).text = func[selectedFuncId][0];
		UIBuilder.getAs('algoDescText', Text).text = func[selectedFuncId][1];
		UIBuilder.getAs('mapSizeDescText', Text).text = map_size[selectedMapSizeId];
		UIBuilder.getAs('gridSizeDescText', Text).text = grid_size[selectedGridSizeId];
	}

	public function drawGUI() {
		// Sorry for this...
		var newMapButton = UIBuilder.create(Button, {
			id : 'newMapButton',
			left : 10,
			top  : maxImageHeight,
			text : 'Generate new map',
			onPress: generateNewMap});
		addChild(newMapButton);

		var algoText = UIBuilder.create(Text, {
			id : 'algoText',
			left : 10,
			top  : maxImageHeight + 20});
		addChild(algoText);

		var algoDescText = UIBuilder.create(Text, {
			id : 'algoDescText',
			left : 150,
			top  : maxImageHeight + 20});
		addChild(algoDescText);

		var algoLeftButton = UIBuilder.create(Button, {
			id : 'algoLeftButton',
			left : 100,
			top  : maxImageHeight + 20,
			text : '<',
			onPress: function(e : MouseEvent) {
				selectedFuncId -= 1;
				selectedFuncId += func.length;
				selectedFuncId %= func.length;
				updateLabels();
		}});
		addChild(algoLeftButton);

		var algoRightButton = UIBuilder.create(Button, {
			id : 'algoRightButton',
			left : 110,
			top  : maxImageHeight + 20,
			text : '>',
			onPress: function(e : MouseEvent) {
				selectedFuncId += 1;
				selectedFuncId %= func.length;
				updateLabels();
		}});
		addChild(algoRightButton);

		var mapSizeText = UIBuilder.create(Text, {
			id : 'mapSizeText',
			left : 10,
			text : 'Map Size',
			top  : maxImageHeight + 40});
		addChild(mapSizeText);

		var mapSizeDescText = UIBuilder.create(Text, {
			id : 'mapSizeDescText',
			left : 150,
			top  : maxImageHeight + 40});
		addChild(mapSizeDescText);

		var mapSizeLeftButton = UIBuilder.create(Button, {
			id : 'mapSizeLeftButton',
			left : 100,
			top  : maxImageHeight + 40,
			text : '<',
			onPress: function(e : MouseEvent) {
				selectedMapSizeId -= 1;
				selectedMapSizeId += map_size.length;
				selectedMapSizeId %= map_size.length;
				updateLabels();
		}});
		addChild(mapSizeLeftButton);

		var mapSizeRightButton = UIBuilder.create(Button, {
			id : 'mapSizeRightButton',
			left : 110,
			top  : maxImageHeight + 40,
			text : '>',
			onPress: function(e : MouseEvent) {
				selectedMapSizeId += 1;
				selectedMapSizeId %= map_size.length;
				updateLabels();
		}});
		addChild(mapSizeRightButton);

		var gridSizeText = UIBuilder.create(Text, {
			id : 'gridSizeText',
			left : 10,
			text : 'Grid Size',
			top  : maxImageHeight + 60});
		addChild(gridSizeText);

		var gridSizeDescText = UIBuilder.create(Text, {
			id : 'gridSizeDescText',
			left : 150,
			top  : maxImageHeight + 60});
		addChild(gridSizeDescText);

		var gridSizeLeftButton = UIBuilder.create(Button, {
			id : 'gridSizeLeftButton',
			left : 100,
			top  : maxImageHeight + 60,
			text : '<',
			onPress: function(e : MouseEvent) {
				selectedGridSizeId -= 1;
				selectedGridSizeId += grid_size.length;
				selectedGridSizeId %= grid_size.length;
				updateLabels();
		}});
		addChild(gridSizeLeftButton);

		var gridSizeRightButton = UIBuilder.create(Button, {
			id : 'gridSizeRightButton',
			left : 110,
			top  : maxImageHeight + 60,
			text : '>',
			onPress: function(e : MouseEvent) {
				selectedGridSizeId += 1;
				selectedGridSizeId %= grid_size.length;
				updateLabels();
		}});
		addChild(gridSizeRightButton);

		bitmap = new Bitmap();
		addChild(bitmap);

		updateLabels();
		generateNewMap();
	}
}