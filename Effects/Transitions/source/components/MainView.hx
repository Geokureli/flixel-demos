package components;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxStringUtil;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;


@:build(haxe.ui.ComponentBuilder.build("assets/xml/main-view.xml"))
class MainView extends haxe.ui.containers.Box
{
	public var initComplete = false;
	public var onInitComplete = new FlxSignal();
	
	override function onReady()
	{
		super.onReady();
		
		if (FlxTransitionableState.defaultTransIn != null)
			viewIn.setData(FlxTransitionableState.defaultTransIn);
		
		if (FlxTransitionableState.defaultTransOut != null)
			viewOut.setData(FlxTransitionableState.defaultTransOut);
		
		initComplete = true;
		onInitComplete.dispatch();
	}
	
	public function setData()
	{
		FlxTransitionableState.defaultTransIn = viewIn.getData(FlxTransitionableState.defaultTransIn);
		FlxTransitionableState.defaultTransOut = viewOut.getData(FlxTransitionableState.defaultTransOut);
	}
}