extends Node3D

@onready var pet_container = $PetContainer

func _ready():
	var pet_scene = preload("res://scenes/Pet.tscn")
	var pet_instance = pet_scene.instantiate()
	pet_container.add_child(pet_instance)
