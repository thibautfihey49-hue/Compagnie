extends Node2D

@onready var animal: Node3D = $Animal
@onready var ui: Control = $UI

func _ready():
	print("🚀 COMPAGNIE 3D DÉMARRÉE")
	ui.connecter_animal(animal)
