package components;

import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;
import flixel.util.FlxColor;

@:build(haxe.ui.macros.ComponentMacros.build("assets/xml/transition-view.xml"))
class TransitionView extends haxe.ui.containers.Frame
{
	static inline var defaultColor:FlxColor = 0xFF000000;
	
	public function new()
	{
		super();
	}
	
	override function onReady()
	{
		super.onReady();
		colorPicker.selectedItem = defaultColor.rgb;
	}
	
	public function setData(data:TransitionData)
	{
		duration.pos = data.duration;
		direction.selectedItem = Direction.fromPoint(data.direction);
		type.selectedItem = FlxStringUtil.toTitleCase(cast data.type);
		tile.selectedItem = TileType.fromData(data.tileData);
		colorPicker.selectedItem = data.color.rgb;
	}
	
	public function getData(data:Null<TransitionData>):TransitionData
	{
		if (data == null)
			data = new TransitionData(FADE, defaultColor, 1.0, FlxPoint.get(), TileData.diamond);
		
		data.duration = duration.pos;
		Direction.setPoint(direction.selectedItem.text, data.direction);
		data.type = type.selectedItem.value;
		data.tileData = TileData.fromType(tile.selectedItem.text);
		data.color = 0xFF000000 | colorPicker.selectedItem;
		return data;
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