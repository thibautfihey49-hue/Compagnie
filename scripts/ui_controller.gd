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

func _ready():
	alerte_timer = Timer.new()
	add_child(alerte_timer)
	alerte_timer.wait_time = 3.0
	alerte_timer.timeout.connect(_cacher_alerte)
	alerte_container.visible = false
	btn_nourrir.pressed.connect(_on_nourrir)
	btn_jouer.pressed.connect(_on_jouer)
	btn_dormir.pressed.connect(_on_dormir)
	btn_soigner.pressed.connect(_on_soigner)
	print("✅ UI chargée")

func connecter_animal(animal_node):
	animal = animal_node
	animal.besoins_mis_a_jour.connect(_on_besoins)
	animal.evolution.connect(_on_evolution)
	animal.alerte.connect(_on_alerte)
	animal.mort.connect(_on_mort)
	print("🔗 Animal connecté")

func _on_besoins(faim, bonheur, sante, energie):
	barre_faim.value = faim
	barre_bonheur.value = bonheur
	barre_sante.value = sante
	barre_energie.value = energie
	barre_faim.modulate = _couleur(faim)
	barre_bonheur.modulate = _couleur(bonheur)
	barre_sante.modulate = _couleur(sante)
	barre_energie.modulate = _couleur(energie)
	if animal: label_age.text = "Âge : " + str(round(animal.age_heures / 60.0, 1)) + " min"

func _couleur(v):
	if v < 15: return Color(1, 0.15, 0.15)
	if v < 30: return Color(1, 0.5, 0.1)
	if v < 50: return Color(1, 0.8, 0.1)
	return Color(0.2, 1, 0.4)

func _on_evolution(nom): label_etat.text = "État : " + nom; label_etat.modulate = Color(1, 0.85, 0.3)
func _on_alerte(nom, val):
	var ic = {"faim":"🍽️", "bonheur":"😊", "sante":"❤️", "energie":"⚡"}
	var nm = {"faim":"Faim", "bonheur":"Bonheur", "sante":"Santé", "energie":"Énergie"}
	alerte_icone.text = ic.get(nom, "⚠️")
	alerte_texte.text = nm.get(nom, nom) + " faible !"
	alerte_container.visible = true
	alerte_timer.start()
func _cacher_alerte(): alerte_container.visible = false
func _on_mort(): alerte_icone.text = "💀"; alerte_texte.text = "Votre animal est parti..."; alerte_container.visible = true; for b in [btn_nourrir,btn_jouer,btn_dormir,btn_soigner]: b.disabled = true
func _on_nourrir(): if animal: animal.nourrir()
func _on_jouer(): if animal: animal.jouer()
func _on_dormir(): if animal: animal.dormir()
func _on_soigner(): if animal: animal.soigner()
