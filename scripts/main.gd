extends Node3D

@onready var pet_scene = preload("res://scenes/Pet.tscn")
var pet = null

func _ready():
	pet = $Pet
	pet.instantiate()
	add_child(pet_scene.instance())
	pet = get_node("Pet/Pet")
	$UI.pet_ref = pet
