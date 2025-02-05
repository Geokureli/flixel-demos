package;

import flixel.FlxGame;
import haxe.ui.Toolkit;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		Toolkit.init();
		Toolkit.autoScale = false;
		Toolkit.theme = "retro-block";
		
		addChild(new FlxGame(640, 480, MenuState));
	}
}
