extends Control

@onready var barre_faim: ProgressBar = $Barres/Faim
@onready var barre_bonheur: ProgressBar = $Barres/Bonheur
@onready var barre_sante: ProgressBar = $Barres/Sante
@onready var barre_energie: ProgressBar = $Barres/Energie
@onready var label_etat: Label = $Info/Etat
@onready var label_age: Label = $Info/Age
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
	alerte_timer = Timer.new()
	add_child(alerte_timer)
	alerte_timer.one_shot = true
	alerte_timer.wait_time = 3.0
	alerte_timer.timeout.connect(_cacher_alerte)
	alerte_container.visible = false

	btn_nourrir.pressed.connect(_on_nourrir)
	btn_jouer.pressed.connect(_on_jouer)
	btn_dormir.pressed.connect(_on_dormir)
	btn_soigner.pressed.connect(_on_soigner)

func connecter_animal(animal_node: Node3D) -> void:
	animal = animal_node
	animal.besoins_mis_a_jour.connect(_on_besoins_mis_a_jour)
	animal.evolution.connect(_on_evolution)
	animal.alerte.connect(_on_alerte)
	animal.mort.connect(_on_mort)

func _on_besoins_mis_a_jour(faim, bonheur, sante, energie) -> void:
	barre_faim.value = faim
	barre_bonheur.value = bonheur
	barre_sante.value = sante
	barre_energie.value = energie
	
	barre_faim.modulate = _couleur_niveau(faim)
	barre_bonheur.modulate = _couleur_niveau(bonheur)
	barre_sante.modulate = _couleur_niveau(sante)
	barre_energie.modulate = _couleur_niveau(energie)
	
	if animal:
		label_age.text = "Âge : " + str(round(animal.age_heures / 60.0, 1)) + " min"

func _couleur_niveau(valeur: float) -> Color:
	if valeur < 15:
		return Color(1, 0.15, 0.15)
	elif valeur < 30:
		return Color(1, 0.5, 0.1)
	elif valeur < 50:
		return Color(1, 0.8, 0.1)
	else:
		return Color(0.15, 1, 0.4)

func _on_evolution(etat_nom: String) -> void:
	label_etat.text = "État : " + etat_nom
	label_etat.modulate = Color(1, 0.85, 0.3)

func _on_alerte(nom_besoin: String, valeur: float) -> void:
	var icones = {"faim": "🍽️", "bonheur": "😊", "sante": "❤️", "energie": "⚡"}
	var noms = {"faim": "Faim", "bonheur": "Bonheur", "sante": "Santé", "energie": "Énergie"}
	alerte_icone.text = icones.get(nom_besoin, "⚠️")
	alerte_texte.text = noms.get(nom_besoin, nom_besoin) + " faible !"
	alerte_icone.modulate = Color(1, 0.3, 0.3)
	alerte_texte.modulate = Color(1, 0.3, 0.3)
	alerte_container.visible = true
	alerte_timer.start()

func _cacher_alerte() -> void:
	alerte_container.visible = false

func _on_mort() -> void:
	alerte_icone.text = "💀"
	alerte_texte.text = "Votre animal est parti..."
	alerte_icone.modulate = Color(0.5, 0.5, 0.5)
	alerte_texte.modulate = Color(0.5, 0.5, 0.5)
	alerte_container.visible = true
	for btn in [btn_nourrir, btn_jouer, btn_dormir, btn_soigner]:
		btn.disabled = true

func _on_nourrir() -> void:
	if animal and animal.has_method("nourrir"):
		animal.nourrir()

func _on_jouer() -> void:
	if animal and animal.has_method("jouer"):
		animal.jouer()

func _on_dormir() -> void:
	if animal and animal.has_method("dormir"):
		animal.dormir()

func _on_soigner() -> void:
	if animal and animal.has_method("soigner"):
		animal.soigner()
