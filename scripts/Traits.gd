class_name Traits

#region Constants - Organized by Category

## Poses organized by life stage and fur length
const POSES = {
	"bairn": {
		"short": [
			{
				"id": "bp1",
				"pose": "res://sprites/bairnpose1.png",
				"base": {"solid": "res://sprites/bairnpose1solid.png", "smokeback": "res://sprites/bairnpose1smokeback.png"},
				"eyes": {"default": "res://sprites/bairnpose1eyes.png"}
			}
		]
	},
	"juvenile": {
		"short": [
			{
				"id": "jp1",
				"pose": "res://sprites/juvenilepose1.png",
				"base": {"solid": "res://sprites/juvenilepose1solid.png", "smokeback": "res://sprites/juvenilepose1smokeback.png"},
				"eyes": {"default": "res://sprites/juvenilepose1eyes.png"}
			}
		],
		"long": [
			{
				"id": "jp2",
				"pose": "res://sprites/juvenilepose2.png",
				"base": {"solid": "res://sprites/juvenilepose2solid.png", "smokeback": "res://sprites/juvenilepose2smokeback.png"},
				"eyes": {"default": "res://sprites/juvenilepose2eyes.png"}
			}
		]
	},
	"adult": {
		"short": [
			{
				"id": "ap1",
				"pose": "res://sprites/adultpose1.png",
				"base": {"solid": "res://sprites/adultpose1solid.png", "smokeback": "res://sprites/adultpose1smokeback.png"},
				"eyes": {"default": "res://sprites/adultpose1eyes.png"}
			},
			{
				"id": "ap2",
				"pose": "res://sprites/adultpose2.png",
				"base": {"solid": "res://sprites/adultpose2solid.png", "smokeback": "res://sprites/adultpose2smokeback.png"},
				"eyes": {"default": "res://sprites/adultpose2eyes.png"}
			}
		],
		"long": [
			{
				"id": "ap3",
				"pose": "res://sprites/adultpose3.png",
				"base": {"solid": "res://sprites/adultpose3solid.png", "smokeback": "res://sprites/adultpose3smokeback.png"},
				"eyes": {"default": "res://sprites/adultpose3eyes.png"}
			},
			{
				"id": "ap4",
				"pose": "res://sprites/adultpose4.png",
				"base": {"solid": "res://sprites/adultpose4solid.png", "smokeback": "res://sprites/adultpose4smokeback.png"},
				"eyes": {"default": "res://sprites/adultpose4eyes.png"}
			},
		]
	},
	"senior": {
		"short": [
			{
				"id": "sp1",
				"pose": "res://sprites/seniorpose1.png",
				"base": {"solid": "res://sprites/seniorpose1solid.png", "smokeback": "res://sprites/seniorpose1smokeback.png"},
				"eyes": {"default": "res://sprites/seniorpose1eyes.png"}
			}
		],
		"long": [
			{
				"id": "sp2",
				"pose": "res://sprites/seniorpose2.png",
				"base": {"solid": "res://sprites/seniorpose2solid.png", "smokeback": "res://sprites/seniorpose2smokeback.png"},
				"eyes": {"default": "res://sprites/seniorpose2eyes.png"}
			}
		]
	}
}

## Base colors - rich, warm, and earthy (SECOND LIGHTEST)
const COLORS = {
	"white": {"modulate": "#ffffff"}, # DEBUG: should never show up
	"russet": {"modulate": "#cc5500"}, # old: e3812b
	"ebony": {"modulate": "#3d3d3d"},
	"taupe": {"modulate": "#756556"},
	"slate": {"modulate": "#708090"} 
}

## Dilution variations for each base color
const DILUTIONS = {
	"thinned": { # LIGHT, WASHED OUT, CREAMY, LIGHTEST
		"russet": {"modulate": "#e8b98d"}, # old: e3bb76
		"ebony": {"modulate": "#7d7d7d"},
		"taupe": {"modulate": "#d2b48c"},
		"slate": {"modulate": "#d3d3d3"}
	},
	"caramelized": { # DEEPER, REDDER, DEEPEST
		"russet": {"modulate": "#a34212"}, # old: e05200
		"ebony": {"modulate": "#5c4033"},
		"taupe": {"modulate": "#7b3f00"},
		"slate": {"modulate": "#5d8aa8"}
	},
	"intensified": { # VIBRANT, BRIGHT, SECOND DEEPEST
		"russet": {"modulate": "#ff7b24"},  # old: ff9500
		"ebony": {"modulate": "#1a1a1a"},
		"taupe": {"modulate": "#4d1d05"},
		"slate": {"modulate": "#464647"}
	}
}

## Eye colors
const EYE_COLORS = {
	"amber": {"modulate": "#d19c08"},
	"hazel": {"modulate": "#9aab3e"},
	"green": {"modulate": "#42894b"},
	"blue": {"modulate": "#3076d1"},
	"cocoa": {"modulate": "#a66328"}, # Fixed missing #
	"dandelion yellow": {"modulate": "#ffe17f"} # Fixed missing #
}

## Gender pronouns and verb conjugations
const GENDERS = {
	"veil": {
		"subj": "they",
		"obj": "them",
		"poss_adj": "their",
		"poss_pron": "theirs",
		"reflex": "themself",
		"verb_suffix": ""
	},
	"bloom": {
		"subj": "she",
		"obj": "her",
		"poss_adj": "her",
		"poss_pron": "hers",
		"reflex": "herself",
		"verb_suffix": "s"
	},
	"stone": {
		"subj": "he",
		"obj": "him",
		"poss_adj": "his",
		"poss_pron": "his",
		"reflex": "himself",
		"verb_suffix": "s"
	},
	"solstice": {
		"subj": "sol",
		"obj": "solis",
		"poss_adj": "sols",
		"poss_pron": "sols",
		"reflex": "soliself",
		"verb_suffix": "s"
	},
	"cinders": {
		"subj": "cin",
		"obj": "cind",
		"poss_adj": "cinds",
		"poss_pron": "cinds",
		"reflex": "cindself",
		"verb_suffix": "s"
	},
	"ashes": {
		"subj": "ashe",
		"obj": "ashe",
		"poss_adj": "ashes",
		"poss_pron": "ashes",
		"reflex": "asheself",
		"verb_suffix": "s"
	}
}

## Irregular verb conjugations
const IRREGULAR_VERBS = {
	"go": "goes",
	"do": "does",
	"have": "has",
	"be": "is",
}

#endregion

#region Static Variables
static var NAMELIST: Array = [] # = 4588
static var WORDLIST: Array = [] # = 1115  
static var SYLLIST: Array = [] # = 91
#endregion

#region Initialization
static func _static_init():
	NAMELIST = _load_text_file("res://resources/nameslist.txt")
	WORDLIST = _load_text_file("res://resources/wordslist.txt") 
	SYLLIST = _load_text_file("res://resources/sylllist.txt")
#endregion

#region File Operations
static func _load_text_file(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to load file: " + path)
		return []
	
	var lines = []
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line != "":
			lines.append(line)
	
	file.close()
	print("Loaded ", lines.size(), " lines from: ", path)
	return lines
#endregion

#region Gender/Dialogue Utilities
## Fills a dialogue template with appropriate pronouns and verb conjugations
static func fill_dialogue(template: String, gender: String) -> String:
	if not GENDERS.has(gender):
		gender = "veil"
		
	var result = template

	# Replace pronouns
	for key in ["subj", "obj", "poss_adj", "poss_pron", "reflex"]:
		result = result.replace("{{%s}}" % key, GENDERS[gender][key])

	# Replace verbs marked with {{verb:…}}
	var verb_pattern = RegEx.new()
	verb_pattern.compile(r"\{\{verb:([a-zA-Z]+)\}\}")
	var matches = verb_pattern.search_all(result)

	for match in matches:
		var verb = match.strings[1]
		if GENDERS[gender].verb_suffix != "":
			verb = _conjugate_verb(verb, gender)
		result = result.replace(match.strings[0], verb)

	return result

## Conjugates a verb based on gender rules
static func _conjugate_verb(verb: String, gender: String) -> String:
	if IRREGULAR_VERBS.has(verb):
		return IRREGULAR_VERBS[verb]
	
	if GENDERS[gender].verb_suffix != "":
		# Apply normal s/es rule
		if verb.ends_with("s") or verb.ends_with("x") or verb.ends_with("z"):
			return verb + "es"
		else:
			return verb + GENDERS[gender].verb_suffix
	
	return verb
#endregion
