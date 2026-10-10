class_name ProfileEditSnapshot extends RefCounted
## Create / rename panel state. The glue validates (ProfileStore.clean_name) and sets [member error_key].

## Friendly pre-fill names (strings.csv keys).
const RANDOM_NAME_KEYS: PackedStringArray = [
	"UI_PROFILE_NAME_PIP", "UI_PROFILE_NAME_CLOVER", "UI_PROFILE_NAME_BRAMBLE", "UI_PROFILE_NAME_POPPY",
	"UI_PROFILE_NAME_MOSS", "UI_PROFILE_NAME_TWIG", "UI_PROFILE_NAME_BUTTON", "UI_PROFILE_NAME_FERN",
]

var is_rename: bool = false
## Slot being renamed (-1 when creating).
var slot: int = -1
var name: String = ""
var color: StringName = &"lemon"
var badge: StringName = &"acorn"
## UI_* key of the error line, "" = none.
var error_key: String = ""
## Bump with each rejected save so the screen shakes again for a repeated error.
var error_nonce: int = 0


## A translated random friendly name. Pass a seeded RNG (no global RNG).
static func random_name(rng: RandomNumberGenerator) -> String:
	return str(TranslationServer.translate(RANDOM_NAME_KEYS[rng.randi_range(0, RANDOM_NAME_KEYS.size() - 1)]))
