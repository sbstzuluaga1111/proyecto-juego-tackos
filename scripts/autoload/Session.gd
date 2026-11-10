
extends Node

var token: String = ""
var user: Dictionary = {}

const API_URL: String = "http://127.0.0.1:3000/api"


func save_session(data: Dictionary) -> void:
	token = data.get("token", "")
	user = data.get("user", {})


func clear_session() -> void:
	token = ""
	user = {}


func is_authenticated() -> bool:
	return token != "" and not user.is_empty()


func get_auth_headers() -> PackedStringArray:
	return PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer " + token
	])
