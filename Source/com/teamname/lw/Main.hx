package com.teamname.lw;

import com.teamname.lw.mesh.*;

import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.MouseEvent;

import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Text;

import Math;

class Main extends Sprite {
	public static var instance : Main;

	var world : World;
	var bitmap : Bitmap;
	var lastX : Int;
	var lastY : Int;
	var selectedId : Int = 0;

	var maps : Array<Array<String>> = [["lwtabgen", "*The NEW* genuine LW map"], ["4zones", "4 zones"], ["sgdb", "91700 SGDB"], ["portable", "Allo"], ["alstar1", "Alstar - Alstar's map"], ["boa", "An elephant inside a boa"], ["aquarium", "Aquarium"], ["bonoball", "Ballons"], ["haricot", "Bean"], ["velo", "Bike"], ["spagueti", "Bolognese"], ["007", "Bond, James Bond"], ["garcon", "Boy"], ["papillon", "Butterfly"], ["echlune", "Climb and grab it"], ["clown", "Clown"], ["net1", "Complex"], ["ordino", "Computer"], ["crown", "Crown"], ["fils", "Emberlificoted"], ["poisson", "Fish"], ["donuts", "Five donuts"], ["flo1", "Florence's map"], ["sol", "G"], ["fille", "Girl"], ["glasses", "Glasses"], ["bestiole", "Happy spider"], ["echange", "Highway"], ["muehle", "Jan - Aim at it"], ["bubbles", "Jan - Bubbles"], ["darkone1", "Jan - Dark One 1"], ["darkone2", "Jan - Dark One 2"], ["darkone3", "Jan - Dark One 3"], ["darkone4", "Jan - Dark One 4"], ["8", "Jan - Eight houses"], ["hi", "Jan - Fight in the middle"], ["quaders", "Jan - Quaders"], ["rolz", "Jan - Railroad"], ["h", "Jan - The great H"], ["tag", "Jan - Three blocks"], ["2d", "Kasper - 2d"], ["3d", "Kasper - 3d"], ["ac", "Kasper - Ac"], ["anaglyph1", "Kasper - Anaglyph 1"], ["anaglyph2", "Kasper - Anaglyph 2"], ["charming", "Kasper - Anaglyph 2 (charming)"], ["around", "Kasper - Around"], ["big", "Kasper - Big 1"], ["paper", "Kasper - Big 2"], ["bigm", "Kasper - bigm"], ["blemmya", "Kasper - Blemmya"], ["card", "Kasper - card"], ["metation", "Kasper - Carpe Diem"], ["chess", "Kasper - Chess"], ["circle", "Kasper - Circle"], ["confuse", "Kasper - confuse"], ["egg", "Kasper - Egg"], ["eyes", "Kasper - Eyes"], ["clean", "Kasper - Green"], ["honey", "Kasper - Honey"], ["honeymoon", "Kasper - Honeymoon"], ["jabberwocky", "Kasper - jabberwocky"], ["bored", "Kasper - Labyrinth 1"], ["dirt", "Kasper - Labyrinth 2"], ["garden", "Kasper - Labyrinth 3"], ["labyrint", "Kasper - Labyrinth 4"], ["logo", "Kasper - Logo"], ["lw", "Kasper - Logo 2"], ["lost", "Kasper - Lost"], ["papercut", "Kasper - Papercut"], ["pastel", "Kasper - Pastel"], ["puckman", "Kasper - Puckman"], ["rect", "Kasper - Rectangle 1"], ["rectangle", "Kasper - Rectangle 2"], ["place", "Kasper - Retro"], ["rough", "Kasper - Rough"], ["skull", "Kasper - Skull 1"], ["skullbig", "Kasper - Skull 2"], ["slimy", "Kasper - Slimy"], ["smile", "Kasper - Smile"], ["circlus", "Kasper - Space 1"], ["tiles", "Kasper - Space 2"], ["3x3", "Kasper - Tick Tack Toe"], ["underground", "Kasper - Underground"], ["watch", "Kasper - Watch"], ["feuille", "Leaf"], ["lwtabto4", "LW3 - Bricks"], ["lwtabto2", "LW3 - Circles"], ["lwtab004", "LW3 - Circles and pipes"], ["lwtabtru", "LW3 - Dots and curves"], ["lwtabvid", "LW3 - Empty"], ["lwtabdrt", "LW3 - Geometric"], ["lwtabmic", "LW3 - Mickey Mouse"], ["lwtab005", "LW3 - Puzzle"], ["lwtab006", "LW3 - Puzzle for kids"], ["lwtab003", "LW3 - Random islands"], ["lwtabses", "LW3 - S like snake"], ["lwtab002", "LW3 - Small rectangles"], ["lwtab009", "LW3 - Symetric walls (double)"], ["lwtab008", "LW3 - Symetric walls (half)"], ["lwtabtom", "LW3 - The old genuine LW map"], ["lwtabrec", "LW3 - Thin walls"], ["lwtabbar", "LW3 - Weird walls"], ["213", "Mathematics are easy"], ["coeurs", "Mmmmmmmmm"], ["mouse1", "Mouse - 1"], ["musique", "Music"], ["coccinel", "Nice bug"], ["penta", "Pentaminos"], ["pigface", "Pig face"], ["chinois", "Ping"], ["tuyaux", "Pipes"], ["platform", "Platforms"], ["net2", "Pools and pipes"], ["carres", "Random rectangles"], ["rene02", "Rene - 02"], ["rene03", "Rene - 03"], ["rene04", "Rene - 04"], ["marionet", "Run, run!"], ["derivsol", "Sailing"], ["peur", "Scared"], ["biere", "Serieux destroy!"], ["chenille", "maps/Slow slow....png"], ["cornet3b", "Sluuuuurp"], ["sonnesystem", "Solar System"], ["carreaux", "Squarish stuff"], ["etoile", "Star"], ["strike", "Strike"], ["pieuvre", "Tentacles"], ["tilt", "Tilt"], ["tipi", "Tipi"], ["titanic", "Titanic"], ["policier", "Triiiiiit"], ["trumpet", "Trumpet"], ["tulipes", "Tulips"], ["village", "Village"], ["void", "Void"], ["liqwar", "What's the name of the game?"], ["lapin", "What's up doc?"], ["666", "Whose number is that?"], ["volet", "Window"], ["world1", "World 1"], ["world2", "World 2"], ["world3", "World 3"], ["world4", "World 4"], ["centrik", "You are sleeping"], ["z", "Z"]];

	public function new() {
		if (instance != null) throw "Main is a singleton!";
		instance = this;
		super();
		trace("Hello World!");

		UIBuilder.init();
		drawButtonsAndSelector();
	}

	public function startDebugMode(e : MouseEvent) {
		UIBuilder.getAs('startButton', Button).free();
		removeChild(UIBuilder.getAs('startButton', Button));
		UIBuilder.getAs('leftButton', Button).free();
		removeChild(UIBuilder.getAs('leftButton', Button));
		UIBuilder.getAs('rightButton', Button).free();
		removeChild(UIBuilder.getAs('rightButton', Button));
		UIBuilder.getAs('counterText', Text).free();
		removeChild(UIBuilder.getAs('counterText', Text));
		UIBuilder.getAs('nameText', Text).free();
		removeChild(UIBuilder.getAs('nameText', Text));
		removeChild(bitmap);

		var bitmapData = Assets.getBitmapData("maps/" + maps[selectedId][0] + ".png");
		world = new World(bitmapData);

		bitmap.scaleX = bitmap.scaleY = Math.min(550 / bitmapData.height, 900 / bitmapData.width);
		addChild(bitmap);

		addEventListener(Event.ENTER_FRAME, tick);
		//addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);

		var stopButton = UIBuilder.create(Button, {
			id : 'stopButton',
			left : 10,
			top  : bitmapData.height*bitmap.scaleY + 10,
			text : 'Stop debug mode',
			onPress: stopDebugMode});
		addChild(stopButton);	
	}

	public function stopDebugMode(e : MouseEvent) {
		UIBuilder.getAs('stopButton', Button).free();
		removeChild(UIBuilder.getAs('stopButton', Button));

		removeEventListener(Event.ENTER_FRAME, tick);
		//removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		
		removeChild(bitmap);

		drawButtonsAndSelector();
	}

	public function drawButtonsAndSelector() {
		var startButton = UIBuilder.create(Button, {
			id : 'startButton',
			left : 10,
			top  : 500,
			text : 'Start debug mode',
			onPress: startDebugMode});
		addChild(startButton);

		var leftButton = UIBuilder.create(Button, {
			id : 'leftButton',
			left : 150,
			top  : 500,
			text : '<',
			onPress: function(e : MouseEvent) {
				selectedId -= 1;
				selectedId += maps.length;
				selectedId %= maps.length;
				updateLabelsAndBitmap();
		}});
		addChild(leftButton);

		var rightButton = UIBuilder.create(Button, {
			id : 'rightButton',
			left : 170,
			top  : 500,
			text : '>',
			onPress: function(e : MouseEvent) {
				selectedId += 1;
				selectedId %= maps.length;
				updateLabelsAndBitmap();
		}});
		addChild(rightButton);

		var counterText = UIBuilder.create(Text, {
			id : 'counterText',
			left : 190,
			top  : 500});
		addChild(counterText);

		var nameText = UIBuilder.create(Text, {
			id : 'nameText',
			left : 300,
			top  : 500});
		addChild(nameText);

		bitmap = new Bitmap();
		addChild(bitmap);

		updateLabelsAndBitmap();
	}

	public function updateLabelsAndBitmap() {
		var bitmapData = Assets.getBitmapData("maps/" + maps[selectedId][0] + ".png");
		bitmap.bitmapData = bitmapData;
		bitmap.scaleX = bitmap.scaleY = Math.min(480 / bitmapData.height, 700 / bitmapData.width);
		UIBuilder.getAs('nameText', Text).text = maps[selectedId][1];
		UIBuilder.getAs('counterText', Text).text = (selectedId + 1) + "";
	}

	public function tick(e : Event) {
		world.tick();
		bitmap.bitmapData = world.getBitmap();
		//bitmap.bitmapData = world.getBitmap(0, false);
	}
}