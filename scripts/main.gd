extends Node2D

@onready var animal: Node3D = $Scene3D/Animal
@onready var ui: Control = $UI

func _ready() -> void:
	print("✅ Interface connectée à l'animal")
	ui.connecter_animal(animal)
