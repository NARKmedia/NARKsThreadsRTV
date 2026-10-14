extends Node

const ITEMS = [
	["NARK_Threads_Flannel_Blue", "res://NARK_Threads/Items/Blue_Flannel/Blue_Flannel", "Sleeves"],
	["NARK_Threads_Flannel_Red", "res://NARK_Threads/Items/Red_Flannel/Red_Flannel", "Sleeves"],
	["NARK_Threads_Flannel_Green", "res://NARK_Threads/Items/Green_Flannel/Green_Flannel", "Sleeves"],
	["NARK_Threads_Flannel_Black", "res://NARK_Threads/Items/Black_Flannel/Black_Flannel", "Sleeves"],
	["NARK_Threads_ProGloves_Grey", "res://NARK_Threads/Items/Pro_Gloves_Grey/Pro_Gloves_Grey", "Gloves"],
	["NARK_Threads_ProGloves_Black", "res://NARK_Threads/Items/Pro_Gloves_Black/Pro_Gloves_Black", "Gloves"],
	["NARK_Threads_ProGloves_Tan", "res://NARK_Threads/Items/Pro_Gloves_Tan/Pro_Gloves_Tan", "Gloves"],
	["NARK_Threads_ProGloves_Blue", "res://NARK_Threads/Items/Pro_Gloves_Blue/Pro_Gloves_Blue", "Gloves"]
]

const NORMALS = {
	"Sleeves": "res://NARK_Threads/Items/Blue_Flannel/Assets/Sleeves_Normal.png",
	"Gloves": "res://NARK_Threads/Items/Pro_Gloves_Grey/Assets/Gloves_Normal.png"
}

var textures: Dictionary = {}

func _ready():
	var lib = Engine.get_meta("RTVModLib", null)
	if lib == null or not lib.has_method("register"):
		return
	if lib.has_signal("frameworks_ready") and lib.get("_is_ready") == false:
		await lib.frameworks_ready
	for entry in ITEMS:
		register_item(lib, entry[0], entry[1], entry[2])

func load_texture(path: String, mipmaps: bool, normal: bool = false) -> Texture2D:
	if textures.has(path):
		return textures[path]
	var image = Image.new()
	if image.load(path) != OK:
		return null
	if mipmaps and image.generate_mipmaps(normal) != OK:
		return null
	var texture = ImageTexture.create_from_image(image)
	textures[path] = texture
	return texture

func register_item(lib: Object, id: String, path: String, kind: String):
	var assets = path.get_base_dir() + "/Assets/"
	var icon = load_texture(assets + "Icon.png", false)
	var albedo = load_texture(assets + kind + "_Albedo.png", true)
	var normal = load_texture(NORMALS[kind], true, true)
	var world_albedo = load_texture(assets + "World_Albedo.png", true)
	if icon == null or albedo == null or normal == null or world_albedo == null:
		return
	var item = load(path + ".tres")
	var world_material = load(assets + "MT_World.tres") as ShaderMaterial
	if item == null or not item.material is ShaderMaterial or world_material == null:
		return
	if not item.tetris is PackedScene:
		return
	var sprite = item.tetris.instantiate() as Sprite2D
	if sprite == null:
		return
	sprite.texture = icon
	var tetris = PackedScene.new()
	var result = tetris.pack(sprite)
	sprite.free()
	if result != OK:
		return
	tetris.take_over_path(item.tetris.resource_path)
	item.icon = icon
	item.tetris = tetris
	item.material.set_shader_parameter("albedo", albedo)
	item.material.set_shader_parameter("normal", normal)
	world_material.set_shader_parameter("albedo", world_albedo)
	var world = load(path + ".tscn")
	if world == null:
		return
	lib.register("items", id, item)
	lib.register("scenes", id, world)
	lib.register("loot", id + "_Master", {"item": item, "table": "LT_Master"})
