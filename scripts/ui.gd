extends Control

var pet_ref = null
@onready var hbar = $Stats/Health
@onready var gbar = $Stats/Hunger
@onready var ebar = $Stats/Energy
@onready var hpbar = $Stats/Happiness
@onready var feed = $Btns/Feed
@onready var play = $Btns/Play
@onready var sleep = $Btns/Sleep
@onready var clean = $Btns/Clean
@onready var heal = $Btns/Heal

func _ready():
	feed.pressed.connect(func(): pet_ref.feed())
	play.pressed.connect(func(): pet_ref.play())
	sleep.pressed.connect(func(): pet_ref.sleep_toggle())
	clean.pressed.connect(func(): pet_ref.clean())
	heal.pressed.connect(func(): pet_ref.heal())

func _process(delta):
	if pet_ref:
		hbar.value = pet_ref.health
		gbar.value = pet_ref.hunger
		ebar.value = pet_ref.energy
		hpbar.value = pet_ref.happiness
