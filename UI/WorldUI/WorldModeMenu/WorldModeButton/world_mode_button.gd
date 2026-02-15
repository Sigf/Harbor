class_name WorldModeButton extends PanelContainer

@export var default_style: StyleBoxFlat
@export var selected_style: StyleBoxFlat
@export var button_label: Label
@export var button_text: String:
    set(value):
        button_label.text = value

var selected: bool = false:
    set(value):
        selected = value
        _set_selected(selected)

func _ready() -> void:
    assert(is_instance_valid(default_style))
    assert(is_instance_valid(selected_style))

func _set_selected(is_selected: bool) -> void:
    if is_selected:
        pass
    else:
        pass