
extends Control

@onready var username_input: LineEdit = $CenterContainer/RegisterPanel/Content/UsernameInput
@onready var email_input: LineEdit = $CenterContainer/RegisterPanel/Content/EmailInput
@onready var password_input: LineEdit = $CenterContainer/RegisterPanel/Content/PasswordInput
@onready var confirm_password_input: LineEdit = $CenterContainer/RegisterPanel/Content/ConfirmPasswordInput

@onready var error_label: Label = $CenterContainer/RegisterPanel/Content/ErrorLabel
@onready var register_button: Button = $CenterContainer/RegisterPanel/Content/RegisterButton
@onready var back_button: Button = $CenterContainer/RegisterPanel/Content/BackButton

@onready var http_request: HTTPRequest = $HTTPRequest


func _ready() -> void:
    register_button.pressed.connect(_on_register_pressed)
    back_button.pressed.connect(_on_back_pressed)

    http_request.request_completed.connect(_on_register_completed)

    error_label.text = ""

    username_input.max_length = 30
    email_input.max_length = 150

    password_input.secret = true
    confirm_password_input.secret = true


# ==========================================
# REGISTRO
# ==========================================
func _on_register_pressed() -> void:

    var username = username_input.text.strip_edges().to_lower()
    var email = email_input.text.strip_edges().to_lower()
    var password = password_input.text
    var confirm_password = confirm_password_input.text

    # Validar campos
    if username.is_empty() or email.is_empty() or password.is_empty() or confirm_password.is_empty():
        show_error("Completa todos los campos.")
        return

    # Validar usuario
    if username.length() < 3 or username.length() > 30:
        show_error("El usuario debe tener entre 3 y 30 caracteres.")
        return

    var username_regex = RegEx.new()
    username_regex.compile("^[a-zA-Z0-9_]{3,30}$")

    if username_regex.search(username) == null:
        show_error("El usuario solo permite letras, números y guion bajo.")
        return

    # Validar correo
    var email_regex = RegEx.new()
    email_regex.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")

    if email.length() > 150 or email_regex.search(email) == null:
        show_error("Ingresa un correo electrónico válido.")
        return

    # Validar contraseña
    if password.length() < 8:
        show_error("La contraseña debe tener mínimo 8 caracteres.")
        return

    if password.to_utf8_buffer().size() > 72:
        show_error("La contraseña supera el límite permitido.")
        return

    # Confirmar contraseña
    if password != confirm_password:
        show_error("Las contraseñas no coinciden.")
        return

    # Preparar petición
    register_button.disabled = true
    register_button.text = "CREANDO CUENTA..."
    error_label.text = ""

    var data = {
        "username": username,
        "email": email,
        "password": password
    }

    var headers = PackedStringArray([
        "Content-Type: application/json"
    ])

    var request_error = http_request.request(
        Session.API_URL + "/auth/register",
        headers,
        HTTPClient.METHOD_POST,
        JSON.stringify(data)
    )

    if request_error != OK:
        register_button.disabled = false
        register_button.text = "CREAR CUENTA"

        show_error("No se pudo conectar con el servidor.")


# ==========================================
# RESPUESTA DEL SERVIDOR
# ==========================================
func _on_register_completed(
    result: int,
    response_code: int,
    headers: PackedStringArray,
    body: PackedByteArray
) -> void:

    register_button.disabled = false
    register_button.text = "CREAR CUENTA"

    if result != HTTPRequest.RESULT_SUCCESS:
        show_error("No hay conexión con el servidor.")
        return

    var response = JSON.parse_string(body.get_string_from_utf8())

    if not response is Dictionary:
        show_error("Respuesta inválida del servidor.")
        return

    if response_code == 201 and response.get("success", false):

        error_label.text = "¡Cuenta creada correctamente!"

        register_button.disabled = true
        back_button.disabled = true

        await get_tree().create_timer(1.5).timeout

        get_tree().change_scene_to_file(
            "res://scenes/auth/Login.tscn"
        )

    else:
        show_error(
            response.get("message", "No se pudo crear la cuenta.")
        )


# ==========================================
# VOLVER AL LOGIN
# ==========================================
func _on_back_pressed() -> void:

    get_tree().change_scene_to_file(
        "res://scenes/auth/Login.tscn"
    )


# ==========================================
# MOSTRAR ERRORES
# ==========================================
func show_error(message: String) -> void:

    error_label.text = message
