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
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
\tprint("🐱 Animal créé — éclosion dans 3s")
\tawait get_tree().create_timer(3.0).timeout
\t_evoluer_vers(Etat.BEBE)

func _process(delta: float) -> void:
\tif etat == Etat.OEUF:
\t\tmodele.scale = Vector3.ONE * (0.5 + sin(Time.get_ticks_msec() * 0.005) * 0.03)
\t\treturn

\tage_heures += delta / 3600.0 * 60.0 * facteur_temps
\tfaim = maxf(0.0, faim - FAIM_DEG * delta * facteur_temps)
\tbonheur = maxf(0.0, bonheur - BONHEUR_DEG * delta * facteur_temps)
\tsante = maxf(0.0, sante - SANTE_DEG * delta * facteur_temps)
\tenergie = maxf(0.0, energie - ENERGIE_DEG * delta * facteur_temps)

\t_verifier_alertes()
\t_verifier_evolution()

\tif sante <= 0.0 or (faim <= 0.0 and energie <= 0.0):
\t\tmort.emit()
\t\tset_process(false)
\t\treturn

\tmodele.scale = Vector3.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.003) * 0.02)
\tbesoins_mis_a_jour.emit(round(faim), round(bonheur), round(sante), round(energie))

func _verifier_alertes() -> void:
\tif faim < SEUIL_CRITIQUE:
\t\talerte.emit("faim", faim)
\telif faim < SEUIL_ALERTE:
\t\talerte.emit("faim", faim)

\tif bonheur < SEUIL_CRITIQUE:
\t\talerte.emit("bonheur", bonheur)
\telif bonheur < SEUIL_ALERTE:
\t\talerte.emit("bonheur", bonheur)

\tif sante < SEUIL_CRITIQUE:
\t\talerte.emit("sante", sante)

\tif energie < SEUIL_CRITIQUE:
\t\talerte.emit("energie", energie)

func _verifier_evolution() -> void:
\tmatch etat:
\t\tEtat.BEBE:
\t\t\tif age_heures >= HEURES_PAR_ETAPE:
\t\t\t\t_evoluer_vers(Etat.JUVENILE)
\t\tEtat.JUVENILE:
\t\t\tif age_heures >= HEURES_PAR_ETAPE * 2.0:
\t\t\t\t_evoluer_vers(Etat.ADULTE)
\t\tEtat.ADULTE:
\t\t\tif age_heures >= HEURES_PAR_ETAPE * 4.0:
\t\t\t\t_evoluer_vers(Etat.SENIOR)

func _evoluer_vers(nouvel_etat: Etat) -> void:
\tetat = nouvel_etat
\tvar noms := ["ŒUF", "BÉBÉ", "JUVÉNILE", "ADULTE", "SENIOR"]
\tvar tailles := [0.5, 0.7, 1.0, 1.3, 1.1]
\tvar couleurs := [
\t\tColor(0.95, 0.9, 0.8),
\t\tColor(1.0, 0.8, 0.5),
\t\tColor(1.0, 0.65, 0.3),
\t\tColor(0.9, 0.45, 0.1),
\t\tColor(0.6, 0.5, 0.4)
\t]
\tmodele.scale = Vector3.ONE * tailles[nouvel_etat]
\tif corps and corps.material_override:
\t\tcorps.material_override.albedo_color = couleurs[nouvel_etat]
\tprint("✨ ÉVOLUTION : ", noms[nouvel_etat])
\tevolution.emit(noms[nouvel_etat])
\tif animation:
\t\tanimation.play("evolution")

func nourrir() -> void:
\tfaim = minf(100.0, faim + 32.0)

func jouer() -> void:
\tbonheur = minf(100.0, bonheur + 28.0)
\tenergie = maxf(0.0, energie - 8.0)
\tfaim = maxf(0.0, faim - 5.0)

func dormir() -> void:
\tenergie = minf(100.0, energie + 45.0)
\tsante = minf(100.0, sante + 4.0)

func soigner() -> void:
\tsante = minf(100.0, sante + 50.0)
\tbonheur = maxf(0.0, bonheur - 5.0)
