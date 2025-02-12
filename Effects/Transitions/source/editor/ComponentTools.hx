package editor;

import haxe.ui.core.Component;

enum ComponentType
{
	ANIMATION;
	ATLASPLAYER;
	BUTTON;
	CALENDAR;
	CANVAS;
	CHECKBOX;
	COLORPICKER;
	COLUMN;
	DECORATOR;
	DROPDOWN;
	HORIZONTALRULE;
	HORIZONTALRANGE;
	HORIZONTALSCROLL;
	HORIZONTALSLIDER;
	HORIZONTALPROGRESS;
	ICONLINK;
	IMAGE;
	LABEL;
	LINK;
	MONTHSTEPPER;
	OPTIONBOX;
	OPTIONSTEPPER;
	PROGRESS;
	RANGE;
	RULE;
	SCROLL;
	SECTIONHEADER;
	SLIDER;
	SPACER;
	SPINNER;
	STEPPER;
	SWITCH;
	TABBAR;
	TEXTAREA;
	TEXTFIELD;
	TOGGLE;
	VERTICALRULE;
	VERTICALRANGE;
	VERTICALSCROLL;
	VERTICALSLIDER;
	VERTICALPROGRESS;
	COLORPICKERPOPUP;
	ACCORDION;
	BOX;
	BUTTONBAR;
	CARD;
	COLLAPSIBLE;
	CALENDARVIEW;
	CONTINUOUSHBOX;
	FOOTER;
	FORM;
	FRAME;
	GRID;
	GROUP;
	HBOX;
	HEADER;
	HORIZONTALBUTTONBAR;
	HORIZONTALSPLITTER;
	LISTVIEW;
	PANEL;
	SCROLLVIEW;
	SIDEBAR;
	STACK;
	SPLITTER;
	TABLEVIEW;
	TABVIEW;
	TREEVIEW;
	TREEVIEWNODE;
	VBOX;
	COLLAPSIBLEDIALOG;
	DIALOG;
	MESSAGEBOX;
	MENU;
	MENUBAR;
	PROPERTYGRID;
	PROPERTYGROUP;
	WINDOW;
	WINDOWFOOTER;
	WINDOWLIST;
	WINDOWTITLE;
}

class ComponentTools
{
	static final map: Map<ComponentType, ()->Component> =
		[ ANIMATION          => ()->new haxe.ui.components.Animation              ()
		, ATLASPLAYER        => ()->new haxe.ui.components.AtlasPlayer            ()
		, BUTTON             => ()->new haxe.ui.components.Button                 ()
		, CALENDAR           => ()->new haxe.ui.components.Calendar               ()
		, CANVAS             => ()->new haxe.ui.components.Canvas                 ()
		, CHECKBOX           => ()->new haxe.ui.components.CheckBox               ()
		, COLORPICKER        => ()->new haxe.ui.components.ColorPicker            ()
		, COLUMN             => ()->new haxe.ui.components.Column                 ()
		, DECORATOR          => ()->new haxe.ui.components.Decorator              ()
		, DROPDOWN           => ()->new haxe.ui.components.DropDown               ()
		, HORIZONTALRULE     => ()->new haxe.ui.components.HorizontalRule         ()
		, HORIZONTALRANGE    => ()->new haxe.ui.components.HorizontalRange        ()
		, HORIZONTALSCROLL   => ()->new haxe.ui.components.HorizontalScroll       ()
		, HORIZONTALSLIDER   => ()->new haxe.ui.components.HorizontalSlider       ()
		, HORIZONTALPROGRESS => ()->new haxe.ui.components.HorizontalProgress     ()
		, ICONLINK           => ()->new haxe.ui.components.IconLink               ()
		, IMAGE              => ()->new haxe.ui.components.Image                  ()
		, LABEL              => ()->new haxe.ui.components.Label                  ()
		, LINK               => ()->new haxe.ui.components.Link                   ()
		, MONTHSTEPPER       => ()->new haxe.ui.components.MonthStepper           ()
		, OPTIONBOX          => ()->new haxe.ui.components.OptionBox              ()
		, OPTIONSTEPPER      => ()->new haxe.ui.components.OptionStepper          ()
		// , PROGRESS           => ()->new haxe.ui.components.Progress               ()
		// , RANGE              => ()->new haxe.ui.components.Range                  ()
		// , RULE               => ()->new haxe.ui.components.Rule                   ()
		// , SCROLL             => ()->new haxe.ui.components.Scroll                 ()
		, SECTIONHEADER      => ()->new haxe.ui.components.SectionHeader          ()
		// , SLIDER             => ()->new haxe.ui.components.Slider                 ()
		, SPACER             => ()->new haxe.ui.components.Spacer                 ()
		, SPINNER            => ()->new haxe.ui.components.Spinner                ()
		, STEPPER            => ()->new haxe.ui.components.Stepper                ()
		, SWITCH             => ()->new haxe.ui.components.Switch                 ()
		, TABBAR             => ()->new haxe.ui.components.TabBar                 ()
		, TEXTAREA           => ()->new haxe.ui.components.TextArea               ()
		, TEXTFIELD          => ()->new haxe.ui.components.TextField              ()
		, TOGGLE             => ()->new haxe.ui.components.Toggle                 ()
		, VERTICALRULE       => ()->new haxe.ui.components.VerticalRule           ()
		, VERTICALRANGE      => ()->new haxe.ui.components.VerticalRange          ()
		, VERTICALSCROLL     => ()->new haxe.ui.components.VerticalScroll         ()
		, VERTICALSLIDER     => ()->new haxe.ui.components.VerticalSlider         ()
		, VERTICALPROGRESS   => ()->new haxe.ui.components.VerticalProgress       ()
		, COLORPICKERPOPUP   => ()->new haxe.ui.components.popups.ColorPickerPopup()
		// containers
		, ACCORDION           => ()->new haxe.ui.containers.Accordion                ()
		, BOX                 => ()->new haxe.ui.containers.Box                      ()
		// , BUTTONBAR           => ()->new haxe.ui.containers.ButtonBar                ()
		, CARD                => ()->new haxe.ui.containers.Card                     ()
		, COLLAPSIBLE         => ()->new haxe.ui.containers.Collapsible              ()
		, CALENDARVIEW        => ()->new haxe.ui.containers.CalendarView             ()
		, CONTINUOUSHBOX      => ()->new haxe.ui.containers.ContinuousHBox           ()
		, FOOTER              => ()->new haxe.ui.containers.Footer                   ()
		, FORM                => ()->new haxe.ui.containers.Form                     ()
		, FRAME               => ()->new haxe.ui.containers.Frame                    ()
		, GRID                => ()->new haxe.ui.containers.Grid                     ()
		, GROUP               => ()->new haxe.ui.containers.Group                    ()
		, HBOX                => ()->new haxe.ui.containers.HBox                     ()
		, HEADER              => ()->new haxe.ui.containers.Header                   ()
		, HORIZONTALBUTTONBAR => ()->new haxe.ui.containers.HorizontalButtonBar      ()
		, HORIZONTALSPLITTER  => ()->new haxe.ui.containers.HorizontalSplitter       ()
		, LISTVIEW            => ()->new haxe.ui.containers.ListView                 ()
		, PANEL               => ()->new haxe.ui.containers.Panel                    ()
		, SCROLLVIEW          => ()->new haxe.ui.containers.ScrollView               ()
		, SIDEBAR             => ()->new haxe.ui.containers.SideBar                  ()
		, STACK               => ()->new haxe.ui.containers.Stack                    ()
		// , SPLITTER            => ()->new haxe.ui.containers.Splitter                 ()
		, TABLEVIEW           => ()->new haxe.ui.containers.TableView                ()
		, TABVIEW             => ()->new haxe.ui.containers.TabView                  ()
		, TREEVIEW            => ()->new haxe.ui.containers.TreeView                 ()
		, TREEVIEWNODE        => ()->new haxe.ui.containers.TreeViewNode             ()
		, VBOX                => ()->new haxe.ui.containers.VBox                     ()
		, COLLAPSIBLEDIALOG   => ()->new haxe.ui.containers.dialogs.CollapsibleDialog()
		, DIALOG              => ()->new haxe.ui.containers.dialogs.Dialog           ()
		, MESSAGEBOX          => ()->new haxe.ui.containers.dialogs.MessageBox       ()
		, MENU                => ()->new haxe.ui.containers.menus.Menu               ()
		, MENUBAR             => ()->new haxe.ui.containers.menus.MenuBar            ()
		, PROPERTYGRID        => ()->new haxe.ui.containers.properties.PropertyGrid  ()
		, PROPERTYGROUP       => ()->new haxe.ui.containers.properties.PropertyGroup ()
		, WINDOW              => ()->new haxe.ui.containers.windows.Window           ()
		, WINDOWFOOTER        => ()->new haxe.ui.containers.windows.WindowFooter     ()
		, WINDOWLIST          => ()->new haxe.ui.containers.windows.WindowList       ()
		, WINDOWTITLE         => ()->new haxe.ui.containers.windows.WindowTitle      ()
		];
	
	static public function create(type:ComponentType)
	{
		return map[type]();
	}
}
