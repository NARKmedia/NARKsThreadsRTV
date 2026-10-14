extends Node

const ITEMS = [
	["NARK_Threads_Flannel_Blue", "res://NARK_Threads/Items/Blue_Flannel/Blue_Flannel"],
	["NARK_Threads_Flannel_Red", "res://NARK_Threads/Items/Red_Flannel/Red_Flannel"],
	["NARK_Threads_Flannel_Green", "res://NARK_Threads/Items/Green_Flannel/Green_Flannel"],
	["NARK_Threads_Flannel_Black", "res://NARK_Threads/Items/Black_Flannel/Black_Flannel"],
	["NARK_Threads_ProGloves_Grey", "res://NARK_Threads/Items/Pro_Gloves_Grey/Pro_Gloves_Grey"],
	["NARK_Threads_ProGloves_Black", "res://NARK_Threads/Items/Pro_Gloves_Black/Pro_Gloves_Black"],
	["NARK_Threads_ProGloves_Tan", "res://NARK_Threads/Items/Pro_Gloves_Tan/Pro_Gloves_Tan"],
	["NARK_Threads_ProGloves_Blue", "res://NARK_Threads/Items/Pro_Gloves_Blue/Pro_Gloves_Blue"]
]

func _ready():
	var lib = Engine.get_meta("RTVModLib", null)
	if lib == null or not lib.has_method("register"):
		return
	if lib.has_signal("frameworks_ready") and lib.get("_is_ready") == false:
		await lib.frameworks_ready
	for entry in ITEMS:
		register_item(lib, entry[0], entry[1])

func register_item(lib: Object, id: String, path: String):
	var item = load(path + ".tres")
	var world = load(path + ".tscn")
	if item == null or world == null:
		return
	lib.register("items", id, item)
	lib.register("scenes", id, world)
	lib.register("loot", id + "_Master", {"item": item, "table": "LT_Master"})
