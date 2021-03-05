extends VBoxContainer

class_name KeyboardBasedTabsContainer

const default_modulate = Color("#FFFFFF")

enum TabAlignMode { 
	BEGIN = 0, 
	CENTER = 1,
	END = 2, 
}

export (TabAlignMode) var tab_alignment: int = TabAlignMode.BEGIN

export var inactive_content_modulate = Color("#888888")
export var normal_tab: StyleBox
export var pressed_tab: StyleBox
export var disabled_tab: StyleBox
export var focused_tab: StyleBox

export var normal_font_color: Color
export var clicked_font_color: Color
export var disabled_font_color: Color
export var focused_font_color: Color

var tabs_container: HBoxContainer
var content_container: Container
var tabs_button_group: ButtonGroup

var current_content: Control

func _ready():
	var children = pop_children()
	build_tabs_container()
	build_content_container()
	build_tabs(children)
	assign_tab_neighbours()
	set_initial_focus()

func pop_children():
	var children = get_children()
	
	for child in children:
		remove_child(child)
	
	return children

func build_tabs_container():
	tabs_container = HBoxContainer.new()
	tabs_container.name = "Tabs"
	tabs_container.alignment = tab_alignment
	tabs_container.size_flags_horizontal = SIZE_EXPAND_FILL
	tabs_container.size_flags_vertical = SIZE_SHRINK_CENTER
	self.add_child(tabs_container)

func build_content_container():
	content_container = VBoxContainer.new()
	content_container.name = "Content"
	content_container.size_flags_horizontal = SIZE_EXPAND_FILL
	content_container.size_flags_vertical = SIZE_EXPAND_FILL
	content_container.modulate = inactive_content_modulate
	
	self.add_child(content_container)

func build_tabs(children: Array):
	tabs_button_group = ButtonGroup.new()
	for child in children:
		child.visible = false
		content_container.add_child(child)
		var tab_button = build_tab_button_for(child)
		tabs_container.add_child(tab_button)

		
func build_tab_button_for(child: Control):
	var button = Button.new()
	if normal_tab != null:
		button.add_stylebox_override("normal", normal_tab)
	if pressed_tab != null:
		button.add_stylebox_override("pressed", pressed_tab)
	if disabled_tab != null:
		button.add_stylebox_override("disabled", disabled_tab)
	if focused_tab != null:
		button.add_stylebox_override("focus", focused_tab)

	button.text = child.name
	button.toggle_mode = true
	button.group = tabs_button_group
	
	button.connect("focus_entered", self, "on_button_focused", [button])
	button.connect("toggled", self, "on_content_toggled", [child])
	
	return button

func assign_tab_neighbours():
	var children = tabs_container.get_children()
	var buttons = []
	for child in children:
		if not child.disabled:
			buttons.append(child)
			
	for i in range(len(buttons)):
		var button = buttons[i]
		button.focus_neighbour_top = button.get_path_to(button)
		button.focus_neighbour_bottom = button.get_path_to(button)
		button.focus_neighbour_left = button.get_path_to(buttons[posmod((i - 1), len(buttons))])
		button.focus_neighbour_right = button.get_path_to(buttons[posmod((i + 1), len(buttons))])
	
func set_initial_focus():
	if not tabs_button_group.get_buttons().empty():
		var first_button = tabs_button_group.get_buttons()[0]
		first_button.pressed = true
		first_button.grab_click_focus()
		first_button.grab_focus()

	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_down"):
		var pressed_tab_button = tabs_button_group.get_pressed_button()
		if pressed_tab_button.has_focus() and current_content.has_method("get_first_focusable_control"):
			var node = current_content.get_first_focusable_control()
			node.grab_focus()
			node.grab_click_focus()
			content_container.modulate = default_modulate
			get_tree().set_input_as_handled()

	elif event.is_action_pressed("ui_cancel"):
		var pressed_tab_button = tabs_button_group.get_pressed_button()
		if not pressed_tab_button.has_focus():
			pressed_tab_button.grab_click_focus()
			pressed_tab_button.grab_focus()
			content_container.modulate = inactive_content_modulate
			get_tree().set_input_as_handled()
	
	

func on_button_focused(button: Button):
	button.pressed = true

func on_content_toggled(toggled: bool, content: Control):
	content.visible = toggled
	
	if toggled:
		current_content = content
		current_content.size_flags_horizontal = SIZE_EXPAND_FILL
		current_content.size_flags_vertical = SIZE_EXPAND_FILL

func set_tab_disabled(i: int, value: bool):
	var tab_button: Button = tabs_container.get_child(i)
	if tab_button.has_focus():
		var new_focused_node = tab_button.get_node(tab_button.focus_neighbour_right)
		new_focused_node.grab_focus()
		new_focused_node.grab_click_focus()
		
	tab_button.focus_mode = Control.FOCUS_NONE
	tab_button.disabled = value
	tab_button.group = tabs_button_group if value else null
	assign_tab_neighbours()

func set_current_tab(i: int):
	tabs_container.get_child(i).pressed = true
	
