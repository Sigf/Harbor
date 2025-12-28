class_name VillagerCharacter extends Node3D

@export var character_name: String
@export var character_health: int
@export var character_energy: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func do_work():
	print("Villager ", character_name, " did some work.")


func _on_turn_ended(turn_number: int):
	do_work()


func initialize_base_stats() -> void:
	character_name = "Tav"
	character_health = 10
	character_energy = 20
