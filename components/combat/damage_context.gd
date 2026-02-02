extends RefCounted
## DamageContext - container for damage metadata.

var amount: float = 0.0
var source: Node = null
var damage_type: String = ""
var knockback: float = 0.0

func _init(_amount: float = 0.0, _source: Node = null, _damage_type: String = "", _knockback: float = 0.0) -> void:
	amount = _amount
	source = _source
	damage_type = _damage_type
	knockback = _knockback
