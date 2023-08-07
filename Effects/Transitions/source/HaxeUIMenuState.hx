package;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;

using flixel.util.FlxStringUtil;

class HaxeUIMenuState extends FlxTransitionableState
{
	final isStateA:Bool;
	var mainUI:MainUI;
	
	public function new (isStateA = true)
	{
		super();
		this.isStateA = isStateA;
	}
	
	override function create()
	{
		add(mainUI = new MainUI());
		
		FlxG.camera.bgColor = isStateA ? 0xFFff0000 : 0xFF0000ff;
		mainUI.stateName.text = isStateA ? "State A" : "State B";
		mainUI.start.onClick = (_)->
		{
			mainUI.setData();
			transOut = FlxTransitionableState.defaultTransOut;
			FlxG.switchState(new HaxeUIMenuState(!isStateA));
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

@:build(haxe.ui.ComponentBuilder.build("assets/xml/haxe-ui.xml"))
class MainUI extends haxe.ui.containers.Box
{
	static inline var defaultColor:FlxColor = 0xFF000000;
	
	public var initComplete = false;
	public var onInitComplete = new FlxSignal();
	
	override function onReady()
	{
		super.onReady();
		
		if (FlxTransitionableState.defaultTransIn != null)
		{
			final inData = FlxTransitionableState.defaultTransIn;
			durationIn.pos = inData.duration;
			directionIn.selectedItem = Direction.fromPoint(inData.direction);
			typeIn.selectedItem = FlxStringUtil.toTitleCase(cast inData.type);
			tileIn.selectedItem = TileType.fromData(inData.tileData);
			colorIn.selectedItem = inData.color.rgb;
		}
		else
			colorIn.selectedItem = defaultColor.rgb;
		
		if (FlxTransitionableState.defaultTransOut != null)
		{
			final outData = FlxTransitionableState.defaultTransOut;
			durationOut.pos = outData.duration;
			directionOut.selectedItem = Direction.fromPoint(outData.direction);
			typeOut.selectedItem = FlxStringUtil.toTitleCase(cast outData.type);
			tileOut.selectedItem = TileType.fromData(outData.tileData);
			colorOut.selectedItem = outData.color.rgb;
		}
		else
			colorOut.selectedItem = defaultColor.rgb;
		
		initComplete = true;
		onInitComplete.dispatch();
	}
	
	public function setData()
	{
		if (FlxTransitionableState.defaultTransIn == null)
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, defaultColor, 1.0, FlxPoint.get(), TileData.diamond);
		
		if (FlxTransitionableState.defaultTransOut == null)
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, defaultColor, 1.0, FlxPoint.get(), TileData.diamond);
		
		final inData = FlxTransitionableState.defaultTransIn;
		inData.duration = durationIn.pos;
		Direction.setPoint(directionIn.selectedItem.text, inData.direction);
		inData.type = typeIn.selectedItem.value;
		inData.tileData = TileData.fromType(tileIn.selectedItem.text);
		inData.color = 0xFF000000 | colorIn.selectedItem;
		
		final outData = FlxTransitionableState.defaultTransOut;
		outData.duration = durationOut.pos;
		Direction.setPoint(directionOut.selectedItem.text, outData.direction);
		outData.type = typeOut.selectedItem.value;
		outData.tileData = TileData.fromType(tileOut.selectedItem.text);
		outData.color = 0xFF000000 | colorOut.selectedItem;
	}
}

enum abstract TileType(String) from String
{
	var DIAMOND = "Diamond";
	var CIRCLE = "Circle";
	var SQUARE = "Square";
	
	public function toData()
	{
		return switch(this:TileType)
		{
			case DIAMOND: TileData.diamond;
			case CIRCLE: TileData.circle;
			case SQUARE: TileData.square;
			case type: throw 'Invalid type: $type';
		}
	}
	
	public static inline function fromData(data:TileData)
	{
		return data.toType();
	}
}

abstract TileData(TransitionTileData) to TransitionTileData from TransitionTileData
{
	public static inline var DIAMOND_ASSET = 'flixel/images/transitions/diamond.png';
	public static inline var CIRCLE_ASSET = 'flixel/images/transitions/circle.png';
	public static inline var SQUARE_ASSET = 'flixel/images/transitions/square.png';
	
	public static var diamond = { asset:DIAMOND_ASSET, width:32, height:32 };
	public static var circle = { asset:CIRCLE_ASSET, width:32, height:32 };
	public static var square = { asset:SQUARE_ASSET, width:32, height:32 };
	
	public static inline function fromType(type:TileType)
	{
		return type.toData();
	}
	
	public function toType()
	{
		return switch(this.asset)
		{
			case DIAMOND_ASSET: TileType.DIAMOND;
			case CIRCLE_ASSET: TileType.CIRCLE;
			case SQUARE_ASSET: TileType.SQUARE;
			case asset: throw 'Invalid asset: $asset';
		}
	}
}

enum abstract Direction(String) from String
{
	var NONE = "None";
	var DOWN = "Down";
	var DOWN_LEFT = "Down-Left";
	var DOWN_RIGHT = "Down-Right";
	var UP = "Up";
	var UP_LEFT = "Up-Left";
	var UP_RIGHT = "Up-Right";
	var RIGHT = "Right";
	var LEFT = "Left";
	
	public function getPoint(p:FlxPoint)
	{
		return switch(this:Direction)
		{
			case NONE      : p.set( 0,  0);
			case DOWN      : p.set( 0,  1);
			case DOWN_LEFT : p.set(-1,  1);
			case DOWN_RIGHT: p.set( 1,  1);
			case UP        : p.set( 0, -1);
			case UP_LEFT   : p.set(-1, -1);
			case UP_RIGHT  : p.set( 1, -1);
			case RIGHT     : p.set( 1,  0);
			case LEFT      : p.set(-1,  0);
		}
	}
	
	public static function setPoint(direction:Direction, p:FlxPoint)
	{
		direction.getPoint(p);
	}
	
	public static function fromPoint(p:FlxPoint)
	{
		if(p.x == 0 && p.y == 0) return NONE;
		if(p.x == 0 && p.y >  0) return DOWN;
		if(p.x <  0 && p.y >  0) return DOWN_LEFT;
		if(p.x >  0 && p.y >  0) return DOWN_RIGHT;
		if(p.x == 0 && p.y <  0) return UP;
		if(p.x <  0 && p.y <  0) return UP_LEFT;
		if(p.x >  0 && p.y <  0) return UP_RIGHT;
		if(p.x >  0 && p.y == 0) return RIGHT;
		if(p.x <  0 && p.y == 0) return LEFT;
		throw "invalid point: " + p;
	}
}