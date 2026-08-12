extends Node3D

# 📊 Statistiques
var health = 100
var hunger = 80
var energy = 100
var happiness = 100
var hygiene = 100
var age_in_minutes = 0
var birth_time = OS.get_ticks_msec() / 60000.0

# 🐱 État
var is_sleeping = false
var is_dead = false
var current_stage = "EGG"

# 🌱 Évolution
var stages = {
	"EGG": {"name": "Œuf 🥚", "min": 0},
	"BABY": {"name": "Bébé 🐣", "min": 5},
	"CHILD": {"name": "Enfant 🐱", "min": 30},
	"TEEN": {"name": "Adolescent 😺", "min": 120},
	"ADULT": {"name": "Adulte 🦁", "min": 360}
}

var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_update)
	timer.start()
	_load()
	_idle_anim()

# 🍖 Actions
func feed():
	if not is_dead and not is_sleeping:
		hunger = min(100, hunger + 25)
		happiness = min(100, happiness + 4)
		_anim_happy()
		_save()

func play():
	if not is_dead and not is_sleeping and energy > 15:
		happiness = min(100, happiness + 22)
		energy = max(0, energy - 10)
		hunger = max(0, hunger - 6)
		_anim_jump()
		_save()

func sleep_toggle():
	if not is_dead:
		is_sleeping = !is_sleeping
		_save()

func clean():
	if not is_dead and not is_sleeping:
		hygiene = min(100, hygiene + 35)
		happiness = min(100, happiness + 6)
		_save()

func heal():
	if not is_dead and not is_sleeping:
		health = min(100, health + 45)
		_save()

# ⏳ Mise à jour
func _update():
	if is_dead: return
	age_in_minutes = int((OS.get_ticks_msec()/60000.0) - birth_time)
	
	if is_sleeping:
		energy = min(100, energy + 1)
		hunger = max(0, hunger - 1)
		hygiene = max(0, hygiene - 1)
	else:
		hunger = max(0, hunger - 1)
		energy = max(0, energy - 1)
		happiness = max(0, happiness - 1)
		hygiene = max(0, hygiene - 1)
	
	health = int((hunger+energy+happiness+hygiene)/4)
	
	if health < 5:
		is_dead = true
		timer.stop()
	
	_evolve()
	_save()

# 🌱 Évolution
func _evolve():
	var s = "EGG"
	for k in stages:
		if age_in_minutes >= stages[k]["min"]: s = k
	if s != current_stage:
		current_stage = s
		_anim_evolve()

# ✨ Animations
func _idle_anim():
	var t = create_tween()
	t.set_loops()
	t.tween_property($Body, "position:y", 0.1, 1).set_ease(Tween.EASE_IN_OUT)
	t.tween_property($Body, "position:y", 0, 1).set_ease(Tween.EASE_IN_OUT)

func _anim_happy():
	var t = create_tween()
	t.tween_property($Body, "scale", Vector3(1.2,1.2,1.2), 0.3)
	t.tween_property($Body, "scale", Vector3(1,1,1), 0.3)

func _anim_jump():
	var t = create_tween()
	t.tween_property($Body, "position:y", 0.8, 0.4).set_ease(Tween.EASE_OUT)
	t.tween_property($Body, "position:y", 0, 0.4).set_ease(Tween.EASE_IN)

func _anim_evolve():
	var t = create_tween()
	t.tween_property($Body, "scale", Vector3(2,2,2), 0.5)
	t.tween_property($Body, "scale", Vector3(1,1,1), 0.5)

# 💾 Sauvegarde
func _save():
	var d = {"h":health, "g":hunger, "e":energy, "hp":happiness, "hy":hygiene, "b":birth_time, "s":is_sleeping, "d":is_dead, "st":current_stage}
	FileAccess.write_text("user://save.json", JSON.stringify(d))

func _load():
	if FileAccess.file_exists("user://save.json"):
		var d = JSON.new().parse(FileAccess.read_text("user://save.json"))
		health=d.get("h",100); hunger=d.get("g",80); energy=d.get("e",100)
		happiness=d.get("hp",100); hygiene=d.get("hy",100)
		birth_time=d.get("b", OS.get_ticks_msec()/60000.0)
		is_sleeping=d.get("s",false); is_dead=d.get("d",false)
		current_stage=d.get("st","EGG")
