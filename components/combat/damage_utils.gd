extends RefCounted
## DamageUtils - shared helpers for applying damage.

const DamageContext = preload("res://components/combat/damage_context.gd")

static func apply_hitbox_damage(target: Node, hitbox: Hitbox) -> bool:
	if not target or not hitbox:
		return false
	var hurtbox = target.get_node_or_null("Hurtbox")
	if hurtbox and hurtbox is Hurtbox:
		hurtbox.take_hit(hitbox)
		return true
	return false

static func apply_context_to_health(target: Node, context: DamageContext) -> bool:
	if not target or not context:
		return false
	var health = target.get_node_or_null("HealthComponent")
	if health and health.has_method("take_damage"):
		health.take_damage(int(context.amount))
		return true
	return false
