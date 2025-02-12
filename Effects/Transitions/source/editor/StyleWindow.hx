package editor;

#if FLX_DEBUG
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.system.debug.interaction.tools.Tool;
import flixel.system.debug.interaction.Interaction;
import flixel.system.debug.watch.Watch;
import flixel.system.debug.watch.WatchEntry;
import flixel.system.debug.watch.WatchEntryData;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import haxe.ui.backend.ComponentBase;
import haxe.ui.core.Component;
import haxe.ui.styles.Style;
import haxe.ui.util.Variant;

using flixel.util.FlxStringUtil;
using StringTools;

@:bitmap("assets/images/debug/ui.png")
private class ButtonIcon extends openfl.display.BitmapData {}

@:bitmap("assets/images/debugger/cursorCross.png")
private class Cursor extends openfl.display.BitmapData {}


class UIStyleTool extends Tool
{
	var parentComponent:Component;
	var window:StyleWindow;
	public function new(parent:Component)
	{
		parentComponent = parent;
		super();
	}
	
	override function init(brain:Interaction):Tool
	{
		super.init(brain);
		
		_name = "View HaxeUI info";
		setButton(ButtonIcon);
		setCursor(new Cursor(0, 0), -5, -5);
		button.toggleMode = true;
		
		window = new StyleWindow();
		FlxG.debugger.windows.add(window, ButtonIcon);
		
		return this;
	}
	
	override function update():Void
	{
		FlxG.watch.addQuick('style', 'active: ${isActive()}, jPressed:${_brain.pointerJustPressed}, pressed: ${_brain.pointerPressed}');
		if (isActive() && _brain.pointerJustPressed)
		{
			final rect = FlxRect.get(_brain.flixelPointer.x, _brain.flixelPointer.y, 1, 1);
			final items = _brain.getItemsWithinState(FlxG.state, rect);
			for (item in items)
			{
				final component = findComponent(parentComponent, item);
				if (component != null)
				{
					window.show(component);
					break;
				}
			}
			rect.put();
		}
	}
}

function findComponent(parent:ComponentBase, object:FlxObject)
{
	for (child in parent.childComponents)
	{
		if (child is FlxSpriteGroup)//
		{
			for(childObj in (cast child:FlxSpriteGroup).group)
			{
				if (object == childObj)
					return child;
			}
		}
		
		if (child.childComponents != null)
		{
			final component = findComponent(child, object);
			if (component != null)
				return component;
		}
	}
	return null;
}

// function findObject(component:ComponentBase)
// {
// 	if (component is FlxSpriteGroup)//
// 		{
// 			for(childObj in (cast child:FlxSpriteGroup).group)
// 			{
// 				if (object == childObj)
// 					return child;
// 			}
// 		}
		
// 		if (child.childComponents != null)
// 		{
// 			final component = findComponent(child, object);
// 			if (component != null)
// 				return component;
// 		}
// 	}
// 	return null;
// }

private function forEachField(obj:Any, f:(String, Null<Any>)->Void)
{
	for (field in Reflect.fields(obj))
		f(field, Reflect.field(obj, field));
}

private function nonNullFields(obj:Any)
{
	var output = "";
	forEachField(obj, function (field, value)
	{
		if (value != null)
			output += '\n\t$field:$value';
	});
	return '{$output\n}';
}

@:bitmap("assets/images/debug/up.png")
private class UpIcon extends openfl.display.BitmapData {}

@:bitmap("assets/images/debug/tree.png")
private class TreeIcon extends openfl.display.BitmapData {}

@:bitmap("assets/images/debug/list.png")
private class ListIcon extends openfl.display.BitmapData {}

@:bitmap("assets/images/debug/add.png")
private class AddIcon extends openfl.display.BitmapData {}

class StyleWindow extends WatchBase<StyleEntry>
{
	static final listIcon = new ListIcon(0, 0);
	static final treeIcon = new TreeIcon(0, 0);
	
	
	static final exclude = ["filter"];
	
	var target:Null<Component> = null;
	var upButton:FlxSystemButton = null;
	var treeListButton:FlxSystemButton = null;
	var addButton:FlxSystemButton = null;
	var treeView:TreeView = null;
	
	public function new ()
	{
		super(createEntry, "Style", new ButtonIcon(0, 0));
		minSize.x = 200;
		minSize.y = 150;
		
		treeView = new TreeView();
		treeView.x = entriesContainer.x;
		treeView.y = entriesContainer.y;
		addChild(treeView);
		treeView.onDoubleClick.add(show);
		treeView.onSelect.add((selected)->debugSelect(selected != null ? selected : target));
		
		upButton = new FlxSystemButton(new UpIcon(0, 0), showParent);
		upButton.y = 2;
		upButton.enabled = false;
		addChild(upButton);
		
		treeListButton = new FlxSystemButton(new TreeIcon(0, 0), toggleTree);
		treeListButton.toggled = false;
		treeListButton.y = upButton.y;
		treeListButton.enabled = false;
		addChild(treeListButton);
		
		addButton = new FlxSystemButton(new AddIcon(0, 0), clickAdd);
		addButton.enabled = false;
		addButton.y = upButton.y;
		addButton.enabled = false;
		addChild(addButton);
		
		updateSize();
		x = (FlxG.stage.stageWidth - width) / 2;
		
		toggleTree();
	}
	
	function createEntry(name:String, data:WatchEntryData)
	{
		final entry = new StyleEntry(name, data);
		entry.onSubmit.add(onSubmit);
		return entry;
	}
	
	function onSubmit(field:String, value:Any)
	{
		if (target == null)
			throw "Unexpected null target";
		
		Reflect.setField(target.customStyle, field, value);
		target.invalidateComponentStyle(true, true);
	}
	
	public function show(component:Component)
	{
		clear();
		target = component;
		
		for (field in getSortedFields(component.style))
			addEntry(field, FUNCTION(()->Reflect.field(component.style, field)), false);
		
		treeView.show(component);
		
		update();
		updateSize();
		
		upButton.enabled = true;
		treeListButton.enabled = true;
		toggleTree();
		
		debugSelect(target);
	}
	
	function debugSelect(component:Component)
	{
		final selectedDebugItems = FlxG.game.debugger.interaction.selectedItems;
		selectedDebugItems.clear();
		selectedDebugItems.add(Lambda.find(component.members, (m)->m is FlxObject));
	}
	
	function toggleTree()
	{
		_title.text = target == null ? "HaxeUI" : target.cssName.capitalizeFirstLetters();
		
		if (treeListButton.toggled)
		{
			treeListButton.changeIcon(treeIcon);
			_title.appendText(' Tree');
			treeView.visible = true;
			entriesContainer.visible = false;
			addButton.enabled = true;
		}
		else
		{
			treeListButton.changeIcon(listIcon);
			_title.appendText(' Style');
			treeView.visible = false;
			entriesContainer.visible = true;
			addButton.enabled = false;
		}
	}
	
	public function clickAdd()
	{
		
	}
	
	public function showParent()
	{
		show(target.parentComponent);
	}
	
	function getSortedFields(style:Style):Array<String>
	{
		final fields = [];
		var insertion = 0;
		for (field in Reflect.fields(style))
		{
			if (exclude.contains(field) == false)
			{
				final value = Reflect.field(style, field);
				if (value == null)
					fields.push(field);
				else
					fields.insert(insertion++, field);
			}
		}
		return fields;
	}
	
	override function update():Void
	{
		if (treeListButton.toggled == false)
		{
			// update style
			super.update();
		}
	}
	
	override function updateSize()
	{
		super.updateSize();
		
		treeView.setScrollSize(getMarginWidth(), getMarginHeight());
		upButton.x = _width - upButton.width - 2;
		treeListButton.x = upButton.x - treeListButton.width - 5;
	}
}

class StyleEntry extends WatchEntry
{
	public final onSubmit = new FlxTypedSignal<(String, Any)->Void>();
	
	public function new (name:String, data:WatchEntryData)
	{
		super(name, data);
		
		if (displayName == null)
			throw 'Unexpected null displayName';
	}
	
	override function canEdit(data:WatchEntryData)
	{
		final value = getValue();
		return !(value is VariantType);
	}
	
	override function updateValue()
	{
		// this optimization is no longer needed
		// if (valueText.text == "")
		forceUpdateValue();
	}
	
	function forceUpdateValue()
	{
		super.updateValue();
		if (!valueText.isEditing)
		{
			defaultFormat.color = (valueText.text == "null") ? 0x888888 : 0xFFFFFF;
			valueText.defaultTextFormat = defaultFormat;
		}
	}
	
	override function getFormattedValue():String
	{
		final value:Any = getVariantValue();
		
		if(value is String)
		{
			final string:String = cast value;
			if (isPath.match(string))
				return "[...]/" + string.split("/").pop();
		}
		
		if (displayName.toLowerCase().endsWith("color"))
		{
			if (value is Int)
				return (cast value:FlxColor).toWebString();
		}
		
		return Std.string(WatchEntry.formatValue(value));
	}
	
	static final isPath = ~/(\w+\/)+(\w+?\.\w+)$/;
	function getVariantValue():Any
	{
		final value:Any = getValue();
		if (value is haxe.ui.util.VariantType)
		{
			return switch(cast value:VariantType)
			{
				case VT_Array     (v): v;
				case VT_Bool      (v): v;
				case VT_Component (v): v;
				case VT_Date      (v): v;
				case VT_DataSource(v): v;
				case VT_Float     (v): v;
				case VT_Int       (v): v;
				case VT_String    (v): v;
				case VT_ImageData(image):
					image;
			}
		}
		return value;
	}
	
	override function submitValue(value:Dynamic)
	{
		switch (data)
		{
			case FUNCTION(_):
				onSubmit.dispatch(displayName, value);
				forceUpdateValue();
			case unexpected:
				throw 'Unexpected entry type: $unexpected';
		}
	}
	
	override function destroy()
	{
		super.destroy();
		onSubmit.removeAll();
	}
}
#end