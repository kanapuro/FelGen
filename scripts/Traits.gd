class_name Traits

static var NAMELIST = [] # = 4583
static var WORDLIST = [] # = 1114
static var SYLLIST = [] # = 91

static func _static_init():
	NAMELIST = load_text_file("res://resources/nameslist.txt")
	WORDLIST = load_text_file("res://resources/wordslist.txt") 
	SYLLIST = load_text_file("res://resources/sylllist.txt")

# Pose dictionary by life stage + fur length
const POSES = {
	"bairn": {
		"short": [
			{
				"id": "bp1",
				"pose": "res://sprites/bairnpose1.png",
				"base": {"solid": "res://sprites/bairnpose1solid.png"},
				"eyes": {"default": "res://sprites/bairnpose1eyes.png"}
			}
		]
	},
	"juvenile": {
		"short": [
			{
				"id": "jp1",
				"pose": "res://sprites/juvenilepose1.png",
				"base": {"solid": "res://sprites/juvenilepose1solid.png"},
				"eyes": {"default": "res://sprites/juvenilepose1eyes.png"}
			}
		],
		"long": [
			{
				"id": "jp2",
				"pose": "res://sprites/juvenilepose2.png",
				"base": {"solid": "res://sprites/juvenilepose2solid.png"},
				"eyes": {"default": "res://sprites/juvenilepose2eyes.png"}
			}
		]
	},
	"adult": {
		"short": [
			{
				"id": "ap1",
				"pose": "res://sprites/adultpose1.png",
				"base": {"solid": "res://sprites/adultpose1solid.png"},
				"eyes": {"default": "res://sprites/adultpose1eyes.png"}
			},
			{
				"id": "ap2",
				"pose": "res://sprites/adultpose2.png",
				"base": {"solid": "res://sprites/adultpose2solid.png"},
				"eyes": {"default": "res://sprites/adultpose2eyes.png"}
			}
		],
		"long": [
			{
				"id": "ap3",
				"pose": "res://sprites/adultpose3.png",
				"base": {"solid": "res://sprites/adultpose3solid.png"},
				"eyes": {"default": "res://sprites/adultpose3eyes.png"}
			}
		]
	},
	"senior": {
		"short": [
			{
				"id": "sp1",
				"pose": "res://sprites/seniorpose1.png",
				"base": {"solid": "res://sprites/seniorpose1solid.png"},
				"eyes": {"default": "res://sprites/seniorpose1eyes.png"}
			}
		],
		"long": [
			{
				"id": "sp2",
				"pose": "res://sprites/seniorpose2.png",
				"base": {"solid": "res://sprites/seniorpose2solid.png"},
				"eyes": {"default": "res://sprites/seniorpose2eyes.png"}
			}
		]
	}
}

const COLORS = { # base must be rich, warm, and earthy, SECOND LIGHTEST
	"white": {"modulate": "#ffffff"}, # DEBUG: should never show up
	"russet": {"modulate": "#cc5500"}, # old: e3812b, terra cotta orange
	"ebony": {"modulate": "#3d3d3d"}, # dark charcoal
	"taupe": {"modulate": "#756556"}, # dark taupe
	"slate": {"modulate": "#708090"} # blue-gray
}

const DILUTIONS = {
	"thinned": { # thinned dilution / thin dilute color | LIGHT, WASHED OUT, CREAMY, LIGHTEST
		"russet": {"modulate": "#e8b98d"}, # old: e3bb76, apricot cream
		"ebony": {"modulate": "#7d7d7d"}, # medium gray
		"taupe": {"modulate": "#d2b48c"}, # fawn beige
		"slate": {"modulate": "#d3d3d3"} # light silver
	},
	"caramelized": { # caramelized dilution / caramel dilute color | DEEPER, REDDER, DEEPEST
		"russet": {"modulate": "#a34212"}, # old: e05200, burnt sienna
		"ebony": {"modulate": "#5c4033"}, # warm brown-black
		"taupe": {"modulate": "#7b3f00"}, # chocolate
		"slate": {"modulate": "#5d8aa8"} # steel blue
	},
	"intensified": { # intensified dilution / intense dilute color | VIBRANT, BRIGHT, SECOND DEEPEST
		"russet": {"modulate": "#ff7b24"},  # old: ff9500, pumpkin orange
		"ebony": {"modulate": "#1a1a1a"}, # near black
		"taupe": {"modulate": "#4d1d05"}, # mahogany
		"slate": {"modulate": "#464647"} # iron gray
	}
}

const EYE_COLORS = {
	"amber": {"modulate": "#d19c08"},
	"hazel": {"modulate": "#9aab3e"},
	"green": {"modulate": "#42894b"},
	"blue": {"modulate": "#3076d1"},
	"cocoa": {"modulate": "a66328"},
	"dandelion yellow": {"modulate": "ffe17f"}
}


# -- GENDERS --

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
static var IRREGULAR_VERBS = {
	"go": "goes",
	"do": "does",
	"have": "has",
	"be": "is",
	# add more as needed
}
# --- GENDER TEMPLATES ---
# Static dialogue function
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
			# Check irregular first
			if IRREGULAR_VERBS.has(verb):
				verb = IRREGULAR_VERBS[verb]
			else:
				# normal s/es rule
				if verb.ends_with("s") or verb.ends_with("x") or verb.ends_with("z"):
					verb += "es"
				else:
					verb += GENDERS[gender].verb_suffix
		result = result.replace(match.strings[0], verb)

	return result

static func load_text_file(path: String) -> Array:
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
