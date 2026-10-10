extends RefCounted
## Shared UI builders. Touch targets >= MIN_TOUCH px, text through tr() keys with English defaults.
## Preload by path: const Kit := preload("res://src/ui/common/ui_kit.gd")

const MIN_TOUCH: int = 88

## Translate `key`; fall back to `default_text` while no translation exists.
static func t(key: String, default_text: String) -> String:
	var s: String = str(TranslationServer.translate(key))
	return default_text if s == "" or s == key else s


static func button(key: String, default_text: String, min_size: Vector2 = Vector2(MIN_TOUCH, MIN_TOUCH), gold: bool = false) -> Button:
	var b: Button = Button.new()
	b.text = t(key, default_text)
	b.custom_minimum_size = min_size
	if gold:
		b.theme_type_variation = &"PrimaryButton"
	return b


static func label(key: String, default_text: String, variation: StringName = &"", align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l: Label = Label.new()
	l.text = t(key, default_text)
	l.horizontal_alignment = align
	if variation != &"":
		l.theme_type_variation = variation
	return l


static func backdrop(root: Control, color: Color) -> ColorRect:
	var r: ColorRect = ColorRect.new()
	r.color = color
	root.add_child(r)
	r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return r


## Centred column on `root`; inside a rounded panel when `panel` is true.
static func column(root: Control, panel: bool = true, min_width: int = 460) -> VBoxContainer:
	var center: CenterContainer = CenterContainer.new()
	root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var col: VBoxContainer = VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	col.custom_minimum_size.x = min_width
	if panel:
		var p: PanelContainer = PanelContainer.new()
		var m: MarginContainer = MarginContainer.new()
		for side: String in ["left", "right", "top", "bottom"]:
			m.add_theme_constant_override("margin_" + side, 32)
		center.add_child(p)
		p.add_child(m)
		m.add_child(col)
	else:
		center.add_child(col)
	return col


## Let taps fall through everything except buttons (HUD / touch overlays must not cover the board).
static func click_through(n: Node) -> void:
	if n is Control and not n is BaseButton:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c: Node in n.get_children():
		click_through(c)


## "m:ss" from seconds.
@warning_ignore("integer_division")
static func clock(seconds: float) -> String:
	var s: int = int(maxf(seconds, 0.0))
	return "%d:%02d" % [s / 60, s % 60]
