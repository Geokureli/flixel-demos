package;

import flixel.util.FlxSignal;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.util.FlxColor;
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
			mainUI.active = false;
			FlxG.switchState(new HaxeUIMenuState(!isStateA));
		}
		
		super.create();
	}
	
	override function transitionIn()
	{
		if (transIn != null)
			mainUI.active = false;
		
		super.transitionIn();
	}
	
	override function finishTransIn()
	{
		super.finishTransIn();
		mainUI.active = true;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

@:build(haxe.ui.ComponentBuilder.build("assets/xml/haxe-ui.xml"))
class MainUI extends haxe.ui.containers.Box
{
	static inline var defaultColor:FlxColor = 0xFF000000;
	
	public var initComplete = new FlxSignal();
	
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
		
		initComplete.dispatch();
	}
	
	public function setData()
	{
		if (FlxTransitionableState.defaultTransIn == null)
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, defaultColor, 1.0, FlxPoint.get(), TileType.diamond);
		
		if (FlxTransitionableState.defaultTransOut == null)
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, defaultColor, 1.0, FlxPoint.get(), TileType.diamond);
		
		final inData = FlxTransitionableState.defaultTransIn;
		inData.duration = durationIn.pos;
		Direction.setPoint(directionIn.selectedItem.text, inData.direction);
		inData.type = typeIn.selectedItem.value;
		inData.tileData = TileType.getDataFromString(tileIn.selectedItem.text);
		inData.color = 0xFF000000 | colorIn.selectedItem;
		
		final outData = FlxTransitionableState.defaultTransOut;
		outData.duration = durationOut.pos;
		Direction.setPoint(directionOut.selectedItem.text, outData.direction);
		outData.type = typeOut.selectedItem.value;
		outData.tileData = TileType.getDataFromString(tileOut.selectedItem.text);
		outData.color = 0xFF000000 | colorOut.selectedItem;
	}
}

enum abstract TileType(String) from String
{
	var DIAMOND = "Diamond";
	var CIRCLE = "Circle";
	var SQUARE = "Square";
	
	public function getData()
	{
		if (diamond == null)
			init();
		
		return switch(this:TileType)
		{
			case DIAMOND: diamond;
			case CIRCLE: circle;
			case SQUARE: square;
		}
	}
	
	public static var diamond:TileData;
	public static var circle:TileData;
	public static var square:TileData;
	
	public static function init()
	{
		diamond = TileData.fromClass(GraphicTransTileDiamond);
		circle = TileData.fromClass(GraphicTransTileCircle);
		square = TileData.fromClass(GraphicTransTileSquare);
	}
	
	public static function fromString(data:String):TileType
	{
		return data;
	}
	
	public static function getDataFromString(data:String):TileData
	{
		return fromString(data).getData();
	}
	
	public static function fromData(data:TileData)
	{
		if (diamond == null)
			init();
		
		if (data == diamond) return DIAMOND;
		if (data == circle) return CIRCLE;
		if (data == square) return SQUARE;
		
		throw "Invalid data: " + data;
	}
}

abstract TileData(TransitionTileData) to TransitionTileData from TransitionTileData
{
	inline public function new(graphic:FlxGraphic, width:Int, height:Int, ?frameRate:Int)
	{
		this = { asset:graphic, width:width, height:height };
		if (frameRate != null)
			this.frameRate = frameRate;
	}
	
	public static function fromClass(graphicClass:Class<openfl.display.BitmapData>)
	{
		final graphic = FlxGraphic.fromClass(graphicClass);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		return new TileData(graphic, 32, 32);
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