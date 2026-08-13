extends Node2D

@onready var animal: Node3D = $World/Animal
@onready var ui: Control = $UI

func _ready() -> void:
\tprint("🚀 COMPAGNIE 3D DÉMARRÉE")
\tui.connecter_animal(animal)
