extends Control

@onready var label_etat: Label = $Info/Etat
@onready var label_age: Label = $Info/Age
@onready var barre_faim: ProgressBar = $Barres/Faim
@onready var barre_bonheur: ProgressBar = $Barres/Bonheur
@onready var barre_sante: ProgressBar = $Barres/Sante
@onready var barre_energie: ProgressBar = $Barres/Energie
@onready var alerte_container: HBoxContainer = $AlerteContainer
@onready var alerte_icone: Label = $AlerteContainer/Icone
@onready var alerte_texte: Label = $AlerteContainer/Texte
@onready var btn_nourrir: Button = $Boutons/Nourrir
@onready var btn_jouer: Button = $Boutons/Jouer
@onready var btn_dormir: Button = $Boutons/Dormir
@onready var btn_soigner: Button = $Boutons/Soigner

var animal: Node3D
var alerte_timer: Timer

func _ready() -> void:
\talerte_timer = Timer.new()
\tadd_child(alerte_timer)
\talerte_timer.one_shot = true
\talerte_timer.wait_time = 3.0
\talerte_timer.timeout.connect(_cacher_alerte)
\talerte_container.visible = false
\tbtn_nourrir.pressed.connect(_on_nourrir)
\tbtn_jouer.pressed.connect(_on_jouer)
\tbtn_dormir.pressed.connect(_on_dormir)
\tbtn_soigner.pressed.connect(_on_soigner)

func connecter_animal(animal_node: Node3D) -> void:
\tanimal = animal_node
\tanimal.besoins_mis_a_jour.connect(_on_besoins)
\tanimal.evolution.connect(_on_evolution)
\tanimal.alerte.connect(_on_alerte)
\tanimal.mort.connect(_on_mort)

func _on_besoins(faim, bonheur, sante, energie) -> void:
\tbarre_faim.value = faim
\tbarre_bonheur.value = bonheur
\tbarre_sante.value = sante
\tbarre_energie.value = energie
\tif animal:
\t\tlabel_age.text = "Âge : " + str(round(animal.age_heures / 60.0, 1)) + " min"

func _couleur(v: float) -> Color:
\tif v < 15.0:
\t\treturn Color(1, 0.15, 0.15)
\tif v < 30.0:
\t\treturn Color(1, 0.5, 0.1)
\tif v < 50.0:
\t\treturn Color(1, 0.8, 0.1)
\treturn Color(0.2, 1, 0.4)

func _on_evolution(nom: String) -> void:
\tlabel_etat.text = "État : " + nom
\tlabel_etat.modulate = Color(1, 0.85, 0.3)

func _on_alerte(nom: String, val: float) -> void:
\tvar ic := {"faim":"🍽️", "bonheur":"😊", "sante":"❤️", "energie":"⚡"}
\tvar nm := {"faim":"Faim", "bonheur":"Bonheur", "sante":"Santé", "energie":"Énergie"}
\talerte_icone.text = ic.get(nom, "⚠️")
\talerte_texte.text = nm.get(nom, nom) + " faible !"
\talerte_container.visible = true
\talerte_timer.start()

func _cacher_alerte() -> void:
\talerte_container.visible = false

func _on_mort() -> void:
\talerte_icone.text = "💀"
\talerte_texte.text = "Votre animal est parti..."
\talerte_container.visible = true
\tfor b in [btn_nourrir, btn_jouer, btn_dormir, btn_soigner]:
\t\tb.disabled = true

func _on_nourrir() -> void:
\tif animal:
\t\tanimal.nourrir()

func _on_jouer() -> void:
\tif animal:
\t\tanimal.jouer()

func _on_dormir() -> void:
\tif animal:
\t\tanimal.dormir()

func _on_soigner() -> void:
\tif animal:
\t\tanimal.soigner()
