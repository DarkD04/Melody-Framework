extends Node
class_name StateMachine


signal transitioned(state_name)
@export var initial_state := NodePath()
@onready var state: State = get_node(initial_state)

func _ready():
	await owner.ready
	for child in get_children():
		child.state_machine = self
	state.enter()

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)

func change(target_state_name: String, msg: Dictionary = {}) -> void:
	if !has_node(target_state_name):
		return

	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
