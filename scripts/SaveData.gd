extends Resource
class_name SaveData

var world_name: String = "My Clan"
var world_id: String = ""
var timestamp: String = ""
var camps: Array = []
var game_time_months: int = 0
var global_seed: int = 0

func _init():
	world_id = str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000)
	timestamp = Time.get_datetime_string_from_system()

func serialize() -> Dictionary:
	return {
		"version": 1.0,
		"world_name": world_name,
		"world_id": world_id,
		"timestamp": timestamp,
		"game_time_months": game_time_months,
		"global_seed": global_seed,
		"camps": _serialize_camps()
	}

func _serialize_camps() -> Array:
	var serialized_camps = []
	for camp in camps:
		if camp is Dictionary and camp.has("name"):
			var serialized_camp = {
				"name": camp["name"],
				"cats": _serialize_cats(camp.get("cats", []))
			}
			# Add camp position if available
			if camp.has("position"):
				serialized_camp["position"] = {"x": camp["position"].x, "y": camp["position"].y}
			serialized_camps.append(serialized_camp)
	return serialized_camps

func _serialize_cats(cats: Array) -> Array:
	var serialized_cats = []
	for cat in cats:
		if cat is Dictionary and cat.has("id"):
			var serialized_cat = {
				"id": cat.get("id", -1),
				"nick": cat.get("nick", ""),
				"gender": cat.get("gender", ""),
				"colony": cat.get("colony", ""),
				"age_months": cat.get("age_months", 0),
				"life_stage": cat.get("life_stage", ""),
				"fur_length": cat.get("fur_length", ""),
				"dilution": cat.get("dilution", ""),
				"base_color": cat.get("base_color", ""),
				"base_pattern": cat.get("base_pattern", ""),
				"eye_color": cat.get("eye_color", ""),
				"eye_pattern": cat.get("eye_pattern", ""),
				"position": {"x": cat.get("position", Vector2.ZERO).x, "y": cat.get("position", Vector2.ZERO).y},
				"stats": cat.get("stats", {}).duplicate(),
				"core_ability": cat.get("core_ability", 0),
				"character_class": cat.get("character_class", ""),
				"xp": cat.get("xp", 0),
				"level": cat.get("level", 1),
				"proficiencies": cat.get("proficiencies", []).duplicate()
			}
			serialized_cats.append(serialized_cat)
	return serialized_cats

static func deserialize(data: Dictionary) -> SaveData:
	var save_data = SaveData.new()
	save_data.world_name = data.get("world_name", "My Clan")
	save_data.world_id = data.get("world_id", "")
	save_data.timestamp = data.get("timestamp", "")
	save_data.game_time_months = data.get("game_time_months", 0)
	save_data.global_seed = data.get("global_seed", 0)
	save_data.camps = _deserialize_camps(data.get("camps", []))
	return save_data

static func _deserialize_camps(camps_data: Array) -> Array:
	var deserialized_camps = []  # Changed variable name
	for camp_data in camps_data:
		var camp = {
			"name": camp_data.get("name", ""),
			"cats": _deserialize_cats(camp_data.get("cats", []))
		}
		# Restore camp position if available
		var pos_data = camp_data.get("position", {})
		if pos_data:
			camp["position"] = Vector2(pos_data.get("x", 0), pos_data.get("y", 0))
		deserialized_camps.append(camp)  # Use the new variable name
	return deserialized_camps  # Return the new variable name

static func _deserialize_cats(cats_data: Array) -> Array:
	var cats = []
	for cat_data in cats_data:
		var cat = {
			"id": cat_data.get("id", -1),
			"nick": cat_data.get("nick", ""),
			"gender": cat_data.get("gender", ""),
			"colony": cat_data.get("colony", ""),
			"age_months": cat_data.get("age_months", 0),
			"life_stage": cat_data.get("life_stage", ""),
			"fur_length": cat_data.get("fur_length", ""),
			"dilution": cat_data.get("dilution", ""),
			"base_color": cat_data.get("base_color", ""),
			"base_pattern": cat_data.get("base_pattern", ""),
			"eye_color": cat_data.get("eye_color", ""),
			"eye_pattern": cat_data.get("eye_pattern", ""),
			"stats": cat_data.get("stats", {}).duplicate(),
			"core_ability": cat_data.get("core_ability", 0),
			"character_class": cat_data.get("character_class", ""),
			"xp": cat_data.get("xp", 0),
			"level": cat_data.get("level", 1),
			"proficiencies": cat_data.get("proficiencies", []).duplicate()
		}
		# Restore position
		var pos_data = cat_data.get("position", {})
		cat["position"] = Vector2(pos_data.get("x", 0), pos_data.get("y", 0))
		cats.append(cat)
	return cats
