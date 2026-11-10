
extends Control

@onready var username_input: LineEdit = $CenterContainer/LoginPanel/Content/UsernameInput
@onready var password_input: LineEdit = $CenterContainer/LoginPanel/Content/PasswordInput
@onready var error_label: Label = $CenterContainer/LoginPanel/Content/ErrorLabel
@onready var login_button: Button = $CenterContainer/LoginPanel/Content/LoginButton
@onready var register_button: Button = $CenterContainer/LoginPanel/Content/RegisterButton
@onready var http_request: HTTPRequest = $HTTPRequest


func _ready() -> void:
	login_button.pressed.connect(_on_login_pressed)
	register_button.pressed.connect(_on_register_pressed)
	http_request.request_completed.connect(_on_login_completed)

	error_label.text = ""


func _on_login_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text

	if username.is_empty() or password.is_empty():
		show_error("Completa todos los campos.")
		return

	login_button.disabled = true
	login_button.text = "CONECTANDO..."
	error_label.text = ""

	var data = {
		"login": username,
		"password": password
	}

	var json_data = JSON.stringify(data)

	var headers = PackedStringArray([
		"Content-Type: application/json"
	])

	var error = http_request.request(
		Session.API_URL + "/auth/login",
		headers,
		HTTPClient.METHOD_POST,
		json_data
	)

	if error != OK:
		login_button.disabled = false
		login_button.text = "INICIAR SESIÓN"
		show_error("No se pudo conectar con el servidor.")


func _on_login_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	login_button.disabled = false
	login_button.text = "INICIAR SESIÓN"

	if result != HTTPRequest.RESULT_SUCCESS:
		show_error("No hay conexión con el servidor.")
		return

	var response = JSON.parse_string(body.get_string_from_utf8())

	if not response is Dictionary:
		show_error("Respuesta inválida del servidor.")
		return

	if response_code == 200 and response.get("success", false):
		Session.save_session(response)

		get_tree().change_scene_to_file(
			"res://scenes/lobby/Lobby.tscn"
		)
	else:
		show_error(
			response.get("message", "Error al iniciar sesión.")
		)


func _on_register_pressed() -> void:
	get_tree().change_scene_to_file(
        "res://scenes/auth/Register.tscn"
	)


func show_error(message: String) -> void:
	error_label.text = message
