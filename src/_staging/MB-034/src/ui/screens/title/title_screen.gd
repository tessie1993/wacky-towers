class_name TitleScreen extends UiScreen
## Title: first run (Play) or returning (profile chip, Continue, Map). ux/title.md, ADR-0016.
## Intents: PLAY, CONTINUE, OPEN_MAP, OPEN_SETTINGS, OPEN_PROFILES. Back is routed by AppFlow (quit_dialog).

const BACKDROP := Color("BFE8FF")
## Primary pill height in px (title.md layout table, 72 pt).
const PRIMARY_H := 72.0
## Secondary button height (56 pt) and settings/chip sizes.
const SECONDARY_H := 56.0
const CHIP_H := 56.0
## Width of the action column in landscape (title.md: 280 pt).
const ACTIONS_W := 280.0

var _first_run: bool = true
var _chip: Button
var _chip_badge: UiGlyph
var _chip_tile: PanelContainer
var _chip_name: Label
var _readonly: Label
var _settings: Button
var _primary: Button
var _map: Button
var _thumb: PanelContainer
var _thumb_label: Label
var _body: BoxContainer
var _actions: VBoxContainer
var _layout: OrientationLayout


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = BACKDROP
	bg.gui_input.connect(_on_backdrop_input)
	add_child(bg)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var safe := Control.new()
	safe.name = "Safe"
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var frame := VBoxContainer.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe.add_child(frame)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Top bar: chip, read-only badge, spacer, settings.
	var top := HBoxContainer.new()
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(top)
	_chip = Button.new()
	_chip.name = "ProfileChip"
	_chip.custom_minimum_size = Vector2(120, CHIP_H)
	_chip.tooltip_text = tr("UI_PROFILE_CHIP")
	_chip.pressed.connect(func() -> void: intent.emit(UiIntents.OPEN_PROFILES, {}))
	top.add_child(_chip)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chip.add_child(row)
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
	_chip_tile = PanelContainer.new()
	_chip_tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chip_tile.custom_minimum_size = Vector2(CHIP_H - 12, 0)
	row.add_child(_chip_tile)
	_chip_badge = UiGlyph.new()
	_chip_tile.add_child(_chip_badge)
	_chip_name = Label.new()
	_chip_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chip_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chip_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_chip_name)
	_readonly = Label.new()
	_readonly.text = tr("UI_SAVE_READONLY")
	_readonly.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_readonly.custom_minimum_size.x = 160
	_readonly.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	top.add_child(_readonly)
	var spacer := Control.new()
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	_settings = Button.new()
	_settings.name = "Settings"
	_settings.text = tr("UI_SETTINGS")
	_settings.custom_minimum_size = Vector2(CHIP_H, CHIP_H)
	_settings.pressed.connect(func() -> void: intent.emit(UiIntents.OPEN_SETTINGS, {}))
	top.add_child(_settings)

	# Body: art (logo + diorama) and actions.
	_body = BoxContainer.new()
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(_body)
	var art := VBoxContainer.new()
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(art)
	var logo := Label.new()
	logo.text = tr("UI_TITLE_LOGO")
	logo.theme_type_variation = &"LogoLabel"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	art.add_child(logo)
	var diorama := Control.new()
	diorama.name = "Diorama" # art slot, filled later
	diorama.mouse_filter = Control.MOUSE_FILTER_IGNORE
	diorama.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art.add_child(diorama)

	_actions = VBoxContainer.new()
	_actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_actions.add_theme_constant_override("separation", 12)
	_body.add_child(_actions)
	_thumb = PanelContainer.new()
	_thumb.name = "NextLevelThumb" # placeholder for the island thumbnail
	_thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thumb.custom_minimum_size.y = 72
	_thumb_label = Label.new()
	_thumb_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_thumb_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_thumb.add_child(_thumb_label)
	_actions.add_child(_thumb)
	_primary = Button.new()
	_primary.name = "Primary"
	_primary.theme_type_variation = &"PrimaryButton"
	_primary.custom_minimum_size = Vector2(ACTIONS_W, PRIMARY_H)
	_primary.pressed.connect(_on_primary)
	_actions.add_child(_primary)
	_map = Button.new()
	_map.name = "Map"
	_map.text = tr("UI_MAP")
	_map.custom_minimum_size = Vector2(ACTIONS_W, SECONDARY_H)
	_map.pressed.connect(func() -> void: intent.emit(UiIntents.OPEN_MAP, {}))
	_actions.add_child(_map)

	_layout = OrientationLayout.new()
	_layout.safe_target = safe
	_layout.changed.connect(_on_orientation)
	add_child(_layout)
	_apply_state()


## Renders the snapshot ([TitleSnapshot]). Idempotent.
func bind(snapshot: RefCounted) -> void:
	var s := snapshot as TitleSnapshot
	if s == null:
		return
	_first_run = not s.has_profile
	_apply_state()
	if _first_run:
		_primary.text = tr("UI_PLAY")
		return
	_chip_name.text = s.profile_name
	_chip_badge.glyph = s.profile_badge
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiGlyph.color_of(s.profile_color)
	sb.set_corner_radius_all(8)
	_chip_tile.add_theme_stylebox_override("panel", sb)
	_primary.text = "%s  %s" % [tr("UI_CONTINUE"), UiFormat.stars(s.continue_stars)]
	_thumb_label.text = String(s.continue_level_id).replace("_", " ").capitalize()
	_readonly.visible = s.read_only_save


func default_focus() -> Control:
	return _primary


func _apply_state() -> void:
	if _primary == null:
		return
	_chip.visible = not _first_run
	_map.visible = not _first_run
	_thumb.visible = not _first_run
	if _first_run:
		_readonly.visible = false


func _on_primary() -> void:
	intent.emit(UiIntents.PLAY if _first_run else UiIntents.CONTINUE, {})


## First run only: a tap anywhere outside the buttons counts as Play (on release).
func _on_backdrop_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if _first_run and mb != null and mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
		intent.emit(UiIntents.PLAY, {})


func _on_orientation(is_landscape: bool) -> void:
	_body.vertical = not is_landscape
	_actions.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if is_landscape else Control.SIZE_FILL
	_actions.size_flags_vertical = Control.SIZE_SHRINK_CENTER if is_landscape else Control.SIZE_SHRINK_END
	_primary.size_flags_horizontal = Control.SIZE_FILL
