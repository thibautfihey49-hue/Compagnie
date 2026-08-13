extends Node3D

signal besoins_mis_a_jour(faim, bonheur, sante, energie)
signal alerte(nom, valeur)
signal evolution(etat_nom)
signal mort

@export var faim: float = 85.0
@export var bonheur: float = 85.0
@export var sante: float = 100.0
@export var energie: float = 100.0
@export var facteur_temps: float = 1.0

const FAIM_DEG: float = 0.065
const BONHEUR_DEG: float = 0.050
const SANTE_DEG: float = 0.015
const ENERGIE_DEG: float = 0.035

const SEUIL_ALERTE: float = 30.0
const SEUIL_CRITIQUE: float = 12.0

enum Etat { OEUF, BEBE, JUVENILE, ADULTE, SENIOR }
@export var etat: Etat = Etat.OEUF
@export var age_heures: float = 0.0
const HEURES_PAR_ETAPE: float = 180.0

@onready var modele: Node3D = $Modele
@onready var corps: MeshInstance3D = $Modele/Corps
@onready var yeux_gauche: MeshInstance3D = $Modele/Yeux/Gauche
@onready var yeux_droit: MeshInstance3D = $Modele/Yeux/Droit
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("🐱 COMPAGNIE 3D DÉMARRÉ")
	await get_tree().create_timer(3.0).timeout
	_evoluer_vers(Etat.BEBE)

func _process(delta: float) -> void:
	if etat == Etat.OEUF:
		return

	age_heures += delta / 3600.0 * 60.0 * facteur_temps
	faim = max(0.0, faim - FAIM_DEG * delta * facteur_temps)
	bonheur = max(0.0, bonheur - BONHEUR_DEG * delta * facteur_temps)
	sante = max(0.0, sante - SANTE_DEG * delta * facteur_temps)
	energie = max(0.0, energie - ENERGIE_DEG * delta * facteur_temps)

	_verifier_alertes()
	_verifier_evolution()

	if sante <= 0.0 or (faim <= 0.0 and energie <= 0.0):
		mort.emit()
		set_process(false)
		return

	modele.scale = Vector3.ONE * (1.0 + sin(OS.get_ticks_msec() * 0.003) * 0.02)
	besoins_mis_a_jour.emit(round(faim), round(bonheur), round(sante), round(energie))

func _verifier_alertes() -> void:
	if faim < SEUIL_CRITIQUE:
		alerte.emit("faim", faim)
	elif faim < SEUIL_ALERTE:
		alerte.emit("faim", faim)

	if bonheur < SEUIL_CRITIQUE:
		alerte.emit("bonheur", bonheur)
	elif bonheur < SEUIL_ALERTE:
		alerte.emit("bonheur", bonheur)

	if sante < SEUIL_CRITIQUE:
		alerte.emit("sante", sante)

	if energie < SEUIL_CRITIQUE:
		alerte.emit("energie", energie)

func _verifier_evolution() -> void:
	match etat:
		Etat.BEBE:
			if age_heures >= HEURES_PAR_ETAPE:
				_evoluer_vers(Etat.JUVENILE)
		Etat.JUVENILE:
			if age_heures >= HEURES_PAR_ETAPE * 2.0:
				_evoluer_vers(Etat.ADULTE)
		Etat.ADULTE:
			if age_heures >= HEURES_PAR_ETAPE * 4.0:
				_evoluer_vers(Etat.SENIOR)

func _evoluer_vers(nouvel_etat: Etat) -> void:
	etat = nouvel_etat
	var noms = ["ŒUF", "BÉBÉ", "JUVÉNILE", "ADULTE", "SENIOR"]
	var tailles = [0.5, 0.7, 1.0, 1.3, 1.1]
	var couleurs = [
		Color(0.95, 0.9, 0.8),
		Color(1.0, 0.8, 0.5),
		Color(1.0, 0.65, 0.3),
		Color(0.9, 0.45, 0.1),
		Color(0.6, 0.5, 0.4)
	]

	modele.scale = Vector3.ONE * tailles[nouvel_etat]
	if corps and corps.material_override:
		corps.material_override.albedo_color = couleurs[nouvel_etat]

	print("✨ ÉVOLUTION : ", noms[nouvel_etat])
	evolution.emit(noms[nouvel_etat])
	if animation:
		animation.play("evolution")

func nourrir() -> void:
	faim = min(100.0, faim + 32.0)
	sante = min(100.0, sante + 1.5) if faim > 50.0 else sante
	if animation:
		animation.play("manger")

func jouer() -> void:
	bonheur = min(100.0, bonheur + 28.0)
	energie = max(0.0, energie - 8.0)
	faim = max(0.0, faim - 5.0)
	if animation:
		animation.play("sauter")

func dormir() -> void:
	energie = min(100.0, energie + 45.0)
	sante = min(100.0, sante + 4.0)
	if animation:
		animation.play("dormir")

func soigner() -> void:
	sante = min(100.0, sante + 50.0)
	bonheur = max(0.0, bonheur - 5.0)
	if animation:
		animation.play("soigner")
