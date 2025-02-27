package editor;

import editor.ComponentTools;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.debug.DebuggerUtil;
import flixel.system.debug.ScrollSprite;
import flixel.system.debug.watch.Watch;
import flixel.system.ui.FlxSystemButton;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.ContextMenuEvent;
import openfl.geom.Point;
import openfl.text.TextFormat;
import openfl.text.TextField;
import haxe.ui.core.Component;

@:bitmap("assets/images/debug/expand.png")
private class ExpandIcon extends openfl.display.BitmapData {}

@:bitmap("assets/images/debug/collapse.png")
private class CollapseIcon extends openfl.display.BitmapData {}

@:bitmap("assets/images/debug/obj.png")
private class ObjectIcon extends openfl.display.BitmapData {}

private enum State
{
	CLICKED(entry:TreeEntry);
	DRAGGING(entry:TreeEntry);
	IDLE;
}

class TreeView extends ScrollSprite
{
	public var topEntry:TreeEntry;
	public var selected:TreeEntry;
	public final selection = new Sprite();
	public final hiliter = new Sprite();
	public final dropBetween = new Sprite();
	public final onHilite = new FlxTypedSignal<(Component)->Void>();
	public final onSelect = new FlxTypedSignal<(Component)->Void>();
	public final onDoubleClick = new FlxTypedSignal<(Component)->Void>();
	var lastClick = 0;
	
	var state = IDLE;
	
	public function new()
	{
		super();
		
		addChild(hiliter);
		addChild(selection);
		addChild(dropBetween);
	}
	
	function initEvents()
	{
		final stage = this.stage;
		
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.CLICK, onClick);
		function onRemove (_)
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.CLICK, onClick);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		}
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		
		FlxG.console.registerEnum(ComponentType);
		FlxG.console.registerFunction('addComponent', function (t:ComponentType)
		{
			if (t == LABEL)
				throw "Use addComponentLabel(text), instead";
			
			final component = ComponentTools.create(t);
			selected.addEntry(new TreeEntry(null, component, true));
		});
		FlxG.console.registerFunction('addComponentLabel', function (text:String)
		{
			final label = new haxe.ui.components.Label();
			label.text = text;
			selected.addEntry(new TreeEntry(null, label, true));
		});
		FlxG.console.registerFunction('addComponentLabelButton', function (text:String)
		{
			final label = new haxe.ui.components.Label();
			label.text = text;
			final button = new haxe.ui.components.Button();
			button.addComponent(label);
			selected.addEntry(new TreeEntry(null, button, true));
		});
	}
	
	public function show(target:Component)
	{
		if (topEntry != null)
		{
			topEntry.destroy();
			removeChild(topEntry);
		}
		else
		{
			initEvents();
		}
		
		topEntry = new TreeEntry(null, target, false);
		addChild(topEntry);
		topEntry.onChange.add(updateScroll);
	}
	
	function getIndexAt(localY:Float)
	{
		final localY = localY;
		return Math.floor(localY / TreeEntry.HEIGHT);
	}
	
	function getEntryAt(localY:Float)
	{
		final index = getIndexAt(localY);
		return topEntry.get(index, true);
	}
	
	static inline final MARGIN = 4;
	function placeBetweenEntries(localY:Float)
	{
		FlxG.watch.addQuick("margin", '${(localY + MARGIN) % TreeEntry.HEIGHT}');
		return ((localY + MARGIN) % TreeEntry.HEIGHT) < (2 * MARGIN);
	}
	
	function getPlacement(localY:Float)
	{
		final index = getIndexAt(localY);
		final length = topEntry.getLength();
		if (index > length)
			return NONE;
		
		if ((localY % TreeEntry.HEIGHT) < MARGIN)
			return ABOVE(index);
		
		if (((localY + MARGIN) % TreeEntry.HEIGHT) < MARGIN)
		{
			return (index < length)
				? BELOW(getIndexAt(localY))
				: NONE;
		}
		
		return IN(getIndexAt(localY));
			
	}
	
	function onMouseMove(e:MouseEvent)
	{
		final local = globalToLocal(new Point(e.stageX, e.stageY));
		
		if (local.x > 0 && local.x < width)
			hiliteAt(local.y);
		else
			unhilite();
		
		dropBetween.visible = false;
		switch state
		{
			case IDLE:
			case CLICKED(entry):
				if (getEntryAt(local.y) != entry)
					state = DRAGGING(entry);
			case DRAGGING(_):
				switch getPlacement(local.y)
				{
					case IN(_) | NONE:
					case ABOVE(index):
						dropBetween.y = index * TreeEntry.HEIGHT - 1;
						dropBetween.visible = true;
						// dropBetween.transform.colorTransform = new openfl.geom.ColorTransform(0, 0, 1);
					case BELOW(index):
						dropBetween.y = (index + 1) * TreeEntry.HEIGHT - 1;
						dropBetween.visible = true;
						// dropBetween.transform.colorTransform = new openfl.geom.ColorTransform(0, 1, 0);
					
				}
		}
	}
	
	function hiliteAt(localY:Float)
	{
		final index = getIndexAt(localY);
		hiliteIndex(index);
	}
	
	function hiliteIndex(index:Int)
	{
		if (index >= topEntry.getLength() || index < 0)
		{
			unhilite();
			onHilite.dispatch(null);
		}
		else
		{
			hiliter.y = index * TreeEntry.HEIGHT;
			hiliter.visible = true;
			
			final entry = topEntry.get(index, true);
			onHilite.dispatch(entry == null ? null : entry.target);
		}
	}
	
	function unhilite(?e:MouseEvent)
	{
		hiliter.visible = false;
	}
	
	function onMouseDown(e:MouseEvent)
	{
		final local = globalToLocal(new Point(e.stageX, e.stageY));
		
		if (local.x > 0 && local.x < width)
			selectAt(local.y);
		// else
			// deselect();
	}
	
	function onMouseUp(e:MouseEvent)
	{
		switch state
		{
			case IDLE:
			case CLICKED(_):
				state = IDLE;
			case DRAGGING(dragEntry):
				final local = globalToLocal(new Point(e.stageX, e.stageY));
				switch getPlacement(local.y)
				{
					case NONE:
					case placement:
						switch getMovement(placement)
						{
							case ADD(parent):
								parent.addEntry(dragEntry);
								
							case INSERT(parent, index):
								parent.addEntryAt(dragEntry, index);
						}
				}
				
				state = IDLE;
		}
	}
	
	function onClick(e:MouseEvent)
	{
		final local = globalToLocal(new Point(e.stageX, e.stageY));
		
		final ticks = FlxG.game.ticks;
		if (local.x > 0 && local.x < width && (ticks - lastClick) / 1000 < 0.2)
		{
			final entry = getEntryAt(local.y);
			if (entry != null)
				onDoubleClick.dispatch(entry.target);
		}
		
		lastClick = ticks;
	}
	
	function getMovement(placement:DropPlacement)
	{
		return switch placement
		{
			case NONE:
				throw "Unexpected none";
			case IN(index):
				ADD(topEntry.get(index, true));
			case ABOVE(index):
				final selected = topEntry.get(index, true);
				final newParent = selected.parentEntry;
				INSERT(newParent, newParent.getIndex(selected));
			case BELOW(index):
				final selected = topEntry.get(index, true);
				if (selected.expanded && selected.empty == false)
					INSERT(selected, 0);
				else
					INSERT(selected.parentEntry, selected.parentEntry.getIndex(selected));
		}
	}
	
	function selectAt(localY:Float)
	{
		selectIndex(getIndexAt(localY));
	}
	
	function selectIndex(index:Int)
	{
		if (index >= topEntry.getLength() || index < 0)
		{
			deselect();
			onSelect.dispatch(null);
		}
		else
		{
			selection.y = index * TreeEntry.HEIGHT;
			selection.visible = true;
			final entry = topEntry.get(index, true);
			if (entry == null)
				throw 'Selected invlid index: $index';
			
			state = CLICKED(entry);
			onSelect.dispatch(entry.target);
			selected = entry;
		}
	}
	
	function deselect(?e:MouseEvent)
	{
		selection.visible = false;
		selected = null;
	}
	
	override function setScrollSize(width:Float, height:Float)
	{
		super.setScrollSize(width, height);
		
		hiliter.graphics.clear();
		hiliter.graphics.beginFill(0xFFFFFF, 0.1);
		hiliter.graphics.drawRect(0, 0, width, TreeEntry.HEIGHT);
		
		selection.graphics.clear();
		selection.graphics.beginFill(0xFFFFFF, 0.3);
		selection.graphics.drawRect(0, 0, width, TreeEntry.HEIGHT);
		
		dropBetween.graphics.clear();
		dropBetween.graphics.beginFill(0xFFFFFF, 1.0);
		dropBetween.graphics.drawRect(0, 0, width, 3);
		dropBetween.visible = false;
	}
	
	override function onMouseScroll(e:MouseEvent)
	{
		super.onMouseScroll(e);
		
		if (topEntry != null)
			onMouseMove(e);
	}
	
	override function get_height()
	{
		return topEntry == null ? 0 : topEntry.height + scroll.height - TreeEntry.HEIGHT;
	}
}

class TreeEntry extends Sprite implements IFlxDestroyable
{
	static final collapseIcon = new CollapseIcon(0, 0);
	static final expandIcon = new ExpandIcon(0, 0);
	static final objectIcon = new ObjectIcon(0, 0);
	
	public static inline var HEIGHT = TreeField.HEIGHT;
	
	static var nameIndex = 0;
	static inline var INDENT = 10;
	
	public final target:Component;
	public final onChange = new FlxSignal();
	public var parentEntry(default, null):Null<TreeEntry>;
	public var expanded(default, null):Bool = true;
	public var empty(default, null):Bool = true;
	
	public final button:FlxSystemButton;
	public final nameText:TreeField;
	public final childEntries = new Array<TreeEntry>();
	
	public function new(?parentEntry, target:Component, collapse:Bool)
	{
		this.parentEntry = parentEntry;
		this.target = target;
		super();
		
		empty = target.childComponents.length == 0;
		final icon = empty ? objectIcon : collapseIcon;
		button = new FlxSystemButton(icon, clickToggle);
		button.enabled = empty == false;
		button.x = 2;
		addChild(button);
		
		nameText = new TreeField();
		final displayName = '<${target.cssName}${target.id == null ? "" : ' id="${target.id}"'}>';
		name = '$displayName[${nameIndex++}]';
		nameText.text = displayName;
		nameText.x = button.x + 10;
		addChild(nameText);
		
		button.y = nameText.y + (nameText.height - button.height) / 2;
		
		for (child in target.childComponents)
		{
			final entry = new TreeEntry(this, child, true);
			entry.x = INDENT;
			childEntries.push(entry);
			this.addChild(entry);
			entry.onChange.add(onChildChange);
		}
		
		if (empty == false)
		{
			if (collapse)
				this.collapse();
			else
				redraw();
		}
	}
	
	public function destroy()
	{
		FlxDestroyUtil.removeChild(this, nameText);
		
		var i = childEntries.length;
		while (i-- > 0)
			childEntries.pop().destroy();
	}
	
	public function onChildChange()
	{
		redraw();
		onChange.dispatch();
	}
	
	public function redraw()
	{
		var nextY = nameText.y + HEIGHT;
		for (entry in childEntries)
		{
			entry.y = nextY;
			nextY += entry.height;
		}
	}
	
	function clickToggle()
	{
		FlxG.watch.addQuick('toggled-$name', '${button.toggled}');
		toggleExpand();
	}
	
	public function toggleExpand()
	{
		if (expanded)
			collapse();
		else
			expand();
	}
	
	public function collapse()
	{
		button.changeIcon(expandIcon);
		expanded = false;
		for (entry in childEntries)
		{
			if (entry.empty == false)
				entry.collapse();
			entry.visible = false;
		}
		onChange.dispatch();
	}
	
	public function expand()
	{
		button.changeIcon(collapseIcon);
		expanded = true;
		for (entry in childEntries)
			entry.visible = true;
		
		redraw();
		onChange.dispatch();
	}
	
	public function get(index:Int, visibleOnly = false):Null<TreeEntry>
	{
		if (index == 0)
			return this;
		
		final oldIndex = index;
		index--;
		for (entry in childEntries)
		{
			final length = entry.getLength(visibleOnly);
			if (length > index)
				return entry.get(index, false);
			
			index -= length;
		}
		
		return null;
	}
	
	public function getIndex(child:TreeEntry, visibleOnly = true):Int
	{
		if (child == this)
			return 0;
		
		if (!expanded)
			return -1;
		
		var index = 0;
		for (entry in childEntries)
		{
			final length = entry.getLength(visibleOnly);
			final found = entry.getIndex(child, visible);
			if (found != -1)
				return found + index;
			
			index += length;
		}
		
		return -1;
	}
	
	public function addEntry(entry:TreeEntry)
	{
		addEntryAt(entry, childEntries.length);
	}
	
	public function setEntryIndex(entry:TreeEntry, index:Int)
	{
		if (childEntries.indexOf(entry) == index)
			return;
		
		removeEntry(entry);
		addEntryAt(entry, index);
	}
	
	public function addEntryAt(entry:TreeEntry, index:Int)
	{
		if (entry.parentEntry == this)
		{
			setEntryIndex(entry, index);
		}
		else
		{
			if (entry.parentEntry != null)
				entry.parentEntry.removeEntry(entry);
			
			entry.x = INDENT;
			target.addComponentAt(entry.target, index);
			target.invalidateComponent();
			entry.parentEntry = this;
			addChildAt(entry, index);
			childEntries.insert(index, entry);
		}
		redraw();
		onChange.dispatch();
	}
	
	public function removeEntry(entry:TreeEntry)
	{
		if (contains(entry) == false)
			throw "Cannot remove entry";
		
		target.removeComponent(entry.target, false); 
		entry.parentEntry = null;
		removeChild(entry);
		childEntries.remove(entry);
		redraw();
		onChange.dispatch();
	}
	
	public function containsEntry(entry:TreeEntry)
	{
		if (childEntries.contains(entry))
			return true;
		
		for (child in childEntries)
		{
			if (child.containsEntry(entry))
				return true;
		}
		
		return false;
	}
	
	override function get_height()
	{
		return HEIGHT * getLength(true);
	}
	
	public function getLength(visibleOnly = true)
	{
		if (!expanded && visibleOnly)
			return 1;
		
		var length = 1;
		for (entry in childEntries)
			length += entry.getLength(visibleOnly);
		
		return length;
	}
}

@:forward
abstract TreeField(TextField) to TextField
{
	static public inline var HEIGHT = 16;
	
	inline public function new ()
	{
		this = DebuggerUtil.createTextField();
		this.defaultTextFormat = new TextFormat(FlxAssets.FONT_DEBUGGER, 12, 0xFFFFFF);
	}
}

enum DropPlacement
{
	IN(index:Int);
	ABOVE(index:Int);
	BELOW(index:Int);
	NONE;
}

enum DropMovement
{
	ADD(parent:TreeEntry);
	INSERT(parent:TreeEntry, index:Int);
}