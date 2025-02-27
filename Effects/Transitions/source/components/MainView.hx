package components;

// import editor.StyleWindow;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState.defaultTransIn;
import flixel.addons.transition.FlxTransitionableState.defaultTransOut;
import flixel.util.FlxSignal;


@:build(haxe.ui.ComponentBuilder.build("assets/xml/main-view.xml"))
class MainView extends haxe.ui.containers.Box
{
	public var initComplete = false;
	public var onInitComplete = new FlxSignal();
	
	override function onReady()
	{
		super.onReady();
		
		if (defaultTransIn != null)
			viewIn.setData(defaultTransIn);
		
		if (defaultTransOut != null)
			viewOut.setData(defaultTransOut);
		
		initComplete = true;
		onInitComplete.dispatch();
		
		// #if FLX_DEBUG
		// final tool = new UIStyleTool(this);
		// FlxG.debugger.tools.add(tool);
		// FlxG.signals.preStateSwitch.addOnce(()->FlxG.debugger.tools.remove(tool));
		
		// // for (i in 0...20)
		// // 	FlxG.watch.addQuick('$i', i);
		// #end
	}
	
	public function setData()
	{
		defaultTransIn = viewIn.getData(defaultTransIn);
		defaultTransOut = viewOut.getData(defaultTransOut);
	}
}