extends Control

const WEBID = ""

const SU_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + WEBID
const SI_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + WEBID

onready var http = $HTTPRequest

onready var su_label = $TabContainer/Signup/Label
onready var su_uname = $TabContainer/Signup/username
onready var su_email = $TabContainer/Signup/email
onready var su_pass = $TabContainer/Signup/password

onready var li_label = $TabContainer/Login/Label
onready var li_uname = $TabContainer/Login/username
onready var li_pass = $TabContainer/Login/password

func _ready():
	print("Ready!")
	li_label.text = ""
	su_label.text = ""

func signUp():
	su_label.text = ""
	su_pass.self_modulate = Color.white
	$TabContainer/Signup/passwordc.self_modulate = Color.white
	su_uname.self_modulate = Color.white
	su_email.self_modulate = Color.white
	
	if su_pass.text != $TabContainer/Signup/passwordc.text:
		su_label.text = "Passwords don't match"
		su_pass.self_modulate = Color.red
		$TabContainer/Signup/passwordc.self_modulate = Color.red
		return
	
	if su_uname.text.strip_edges() == "":
		su_label.text = "Username must not be blank"
		su_uname.self_modulate = Color.red
		return
	
	var passw = su_pass.text
	var email = su_email.text
	var uname = su_uname.text
	http.request("https://testsystem-f5fa0.firebaseio.com/users/" + uname + ".json")
	var result = yield(http, "request_completed") as Array
	if result[1] != 200:
		su_label.text = "An error has occoured."
		print(result[3].get_string_from_ascii())
	else:
		if result[3].get_string_from_ascii() != "null":
			su_label.text = "Username already exists"
			su_uname.self_modulate = Color.red
		else: #No errors exist as far as the game can tell
			#print("Attempting signup")
			var body = {
				"email": email,
				"password": passw
			}
			http.request(SU_ENDPOINT + main.fbid, [], false, HTTPClient.METHOD_POST, to_json(body))
			var res = yield(http, "request_completed") as Array
			if res[1] != 200:
				#print("ERROR")
				#print(res[3].get_string_from_ascii())
				var parse = JSON.parse(res[3].get_string_from_ascii()).result
				if parse.error.message == "EMAIL_EXISTS":
					su_label.text = "Email already exists"
					su_email.self_modulate = Color.red
				elif parse.error.message == "INVALID_EMAIL":
					su_label.text = "Invalid email"
					su_email.self_modulate = Color.red
				elif parse.error.message.begins_with("WEAK_PASSWORD"):
					su_label.text = "Weak password (password should be at least 6 characters)"
					su_pass.self_modulate = Color.red
					$TabContainer/Signup/passwordc.self_modulate = Color.red
			else:
				var store = {
					"email":email,
					"uname":uname
				}
				http.request("https://testsystem-f5fa0.firebaseio.com/users/" + uname + ".json", [], false, HTTPClient.METHOD_PUT, to_json(store))
				var sreq = yield(http, "request_completed") as Array
				if sreq[1] != 200:
					print("ERROR")
				else:
					print("OK")

func signIn():
	li_uname.self_modulate = Color.white
	li_pass.self_modulate = Color.white
	li_label.text = ""
	
	if li_uname.text.strip_edges() != "":
		var uname = li_uname.text
		var passw = li_pass.text
		
		http.request("https://testsystem-f5fa0.firebaseio.com/users/" + uname + ".json", [], false, HTTPClient.METHOD_GET, to_json({}))
		var result = yield(http, "request_completed") as Array
		if result[1] != 200:
			li_label.text = "An error has occoured. Try again later."
		else:
			if result[3].get_string_from_ascii() == "null":
				li_label.text = "Unknown username"
				li_uname.self_modulate = Color.red
			else:
				var email = JSON.parse(result[3].get_string_from_ascii()).result.email
				var body = {
					"email":email,
					"password":passw
				}
				http.request(SI_ENDPOINT + main.fbid, [], false, HTTPClient.METHOD_POST, to_json(body))
				var result2 = yield(http, "request_completed") as Array
				if result2[1] != 200:
					li_label.text = "Invalid password"
					li_pass.self_modulate = Color.red
				else:
					print("OK")
	else:
		li_label.text = "Invalid username"
		li_uname.self_modulate = Color.red
