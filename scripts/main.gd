extends Node3D

func _ready():
    print("✅ Compagnie 3D DÉMARRÉ !")

func _process(delta):
    $Soleil.rotate_y(delta * 1.5)
