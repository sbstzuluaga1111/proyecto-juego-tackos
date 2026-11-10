extends Control

const LOGIN_SCENE := "res://scenes/auth/Login.tscn"

const TOP := "Margin/Layout/TopBar/TopBarContent/"
const LEFT := "Margin/Layout/MainArea/LeftPanel/LeftContent/"
const HERO := "Margin/Layout/MainArea/CenterArea/HeroBox/"
const BOTTOM := "Margin/Layout/BottomBar/BottomContent/"

@onready var logout_button: Button = get_node(TOP + "LogoutButton")
@onready var player_name: Label = get_node(TOP + "PlayerCard/PlayerInfo/PlayerName")
@onready var player_level: Label = get_node(TOP + "PlayerCard/PlayerInfo/PlayerLevel")
@onready var avatar_initial: Label = get_node(TOP + "PlayerCard/AvatarPanel/AvatarInitial")
@onready var gold_label: Label = get_node(TOP + "GoldChip/GoldLabel")
@onready var gems_label: Label = get_node(TOP + "GemsChip/GemsLabel")
@onready var xp_label: Label = get_node(LEFT + "XPLabel")
@onready var xp_bar: ProgressBar = get_node(LEFT + "XPBar")
@onready var play_button: Button = get_node(HERO + "PlayButton")
@onready var inventory_button: Button = get_node(BOTTOM + "InventoryButton")
@onready var shop_button: Button = get_node(BOTTOM + "ShopButton")
@onready var quests_button: Button = get_node(BOTTOM + "QuestsButton")
@onready var settings_button: Button = get_node(BOTTOM + "SettingsButton")


func _ready() -> void:
	print("[Lobby] listo")
	logout_button.pressed.connect(_on_logout_pressed)
	play_button.pressed.connect(_on_play_pressed)

	for button: Button in [inventory_button, shop_button, quests_button, settings_button]:
		button.pressed.connect(_on_menu_pressed.bind(button.text))

	_refresh_player_info()


func _refresh_player_info() -> void:
	# Los datos del jugador vienen de Session.user (el diccionario que
	# devuelve tu API al iniciar sesión). Si falta algún campo, usa un valor por defecto.
	var user: Dictionary = Session.user

	var username := str(user.get("username", user.get("name", "Jugador")))
	var level := int(user.get("level", 1))
	var xp := int(user.get("xp", 0))
	var xp_next := int(user.get("xp_next", 100))
	var gold := int(user.get("gold", 0))
	var gems := int(user.get("gems", 0))

	player_name.text = username
	avatar_initial.text = username.substr(0, 1).to_upper()
	player_level.text = "Nivel %d" % level
	gold_label.text = "ORO  %d" % gold
	gems_label.text = "GEMAS  %d" % gems
	xp_label.text = "Nivel %d   •   %d / %d XP" % [level, xp, xp_next]
	xp_bar.max_value = max(xp_next, 1)
	xp_bar.value = xp


func _on_logout_pressed() -> void:
	print("[Lobby] Cerrar sesión pulsado")
	Session.clear_session()
	get_tree().change_scene_to_file(LOGIN_SCENE)


func _on_play_pressed() -> void:
	print("JUGAR: aquí va la escena de partida o matchmaking")


func _on_menu_pressed(menu_name: String) -> void:
	print("Menú pulsado: ", menu_name)