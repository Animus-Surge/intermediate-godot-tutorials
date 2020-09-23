extends Node

var fbid

func _ready():
	var fbfile = File.new()
	fbfile.open("res://firebaseinfo.json", File.READ)
	fbid = JSON.parse(fbfile.get_as_text()).result.apikey
