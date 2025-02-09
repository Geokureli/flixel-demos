package;

import components.MainView;
import flixel.FlxG;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import haxe.ui.Toolkit;


class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();
		
		Toolkit.init();
		Toolkit.autoScale = false;
		Toolkit.theme = "retro-block";
		
		
		addChild(new flixel.FlxGame(640, 480, MenuState));
		
	}
}

class MenuState extends FlxTransitionableState
{
	final isStateA:Bool;
	var mainUI:MainView;
	
	public function new (isStateA = true)
	{
		super();
		this.isStateA = isStateA;
	}
	
	override function create()
	{
		add(mainUI = new MainView());
		
		FlxG.camera.bgColor = isStateA ? 0xFFff0000 : 0xFF0000ff;
		mainUI.stateName.text = isStateA ? "State A" : "State B";
		mainUI.start.onClick = (_)->
		{
			mainUI.setData();
			transOut = FlxTransitionableState.defaultTransOut;
			FlxG.switchState(()->new MenuState(!isStateA));
		}
		
		// persistentUpdate = true;
		// persistentDraw = true;
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
	
	override function transitionIn()
	{
		// copied from super so we can delay start until mainUI is ready
		if (transIn != null && transIn.type != NONE)
		{
			if (FlxTransitionableState.skipNextTransIn)
			{
				FlxTransitionableState.skipNextTransIn = false;
				if (finishTransIn != null)
				{
					finishTransIn();
				}
				return;
			}
			
			var _trans = createTransition(transIn);
			
			_trans.setStatus(FULL);
			openSubState(_trans);
			
			_trans.finishCallback = finishTransIn;
			
			// delay start for ui
			// mainUI.hidden = true;
			// if (mainUI.initComplete)
				_trans.start(OUT);
			// else
			// 	mainUI.onInitComplete.addOnce(()->_trans.start(OUT));
		}
	}
	
	// override function finishTransIn()
	// {
	// 	mainUI.fadeIn();
	// }
	
	// override function transitionOut(?onExit:()->Void)
	// {
	// 	mainUI.fadeOut(()->onUIFadeOutComplete(onExit));
	// }
	
	function onUIFadeOutComplete(onExit:()->Void)
	{
		super.transitionOut(onExit);
	}
}