# Phase 19: The Sewers Zone - Context

**Gathered:** 2026-01-29
**Status:** Ready for planning

<domain>
## Phase Boundary

New dungeon zone accessible from the Neighborhood via manhole cover. Darker atmosphere, tighter corridors, environmental hazards (toxic puddles, dark areas), sewer-specific enemy spawns (rats + shadow creatures), and a linear path with optional side rooms leading to the Rat King mini-boss room. Ambient sewer effects throughout.

The Rat King mini-boss itself is Phase 20 — this phase builds the zone and leads to the boss door.

</domain>

<decisions>
## Implementation Decisions

### Zone layout & navigation
- Linear main path with optional side rooms (alcoves/chambers off to the side with loot or enemies)
- 5-7 minutes to explore everything — proper dungeon feel
- Corridors 3-4 tiles wide — snug but playable, can still dodge but feels constrained compared to open zones
- Manhole cover entrance in Neighborhood, freely re-enter anytime — enemies respawn but layout persists
- Player progress is not gated — can leave and come back to grind

### Environmental hazards
- Toxic puddles: mix of obvious (bright green glow, bubbling) and camouflaged (darker, subtle discoloration) — teaches awareness over time
- Toxic puddle damage: applies lingering poison debuff that continues for a few seconds after leaving (reuse existing poison DoT system from sewer rats)
- Dark areas: limited light radius around the player, everything else is black/very dark
- Darkness is purely atmospheric — no light source pickups or abilities, just part of the zone

### Atmosphere & visual mood
- Color palette: dark blue-purple — underground mystery, cooler tones, slightly ethereal (fits shadow creatures)
- Ambient effects: steady presence — regular drips, visible particles drifting, constant reminder you're underground (not sparse, not overwhelming)
- Water: flowing channel on the main path (gives directional sense — follow the flow), stagnant pools in side rooms
- Sound atmosphere: living underground — drips plus faint skittering, occasional distant splashes, something's down here

### Enemy encounter pacing
- Enemy composition escalates: rat-heavy early sections, shadow creature-heavy deeper sections, builds tension toward boss room
- Dense but clustered: corridors can be empty, but rooms/chambers have packs waiting — rhythm of tension and release
- Side rooms: mixed — some are treasure stashes (easy loot), some are ambush traps (hard fight, good loot) — keeps exploration unpredictable
- Pre-boss area: warning signs — rat bones, bigger scratches on walls, a health pickup as mercy — atmospheric foreshadowing before the boss door

### Claude's Discretion
- Exact tilemap layout and room placement
- Number and placement of side rooms
- Specific enemy counts per room
- Light radius size for dark areas
- Particle effect density and speed
- Manhole cover visual design

</decisions>

<specifics>
## Specific Ideas

- Flowing water channel doubles as navigation aid — "follow the flow" leads to the boss room
- Escalating enemy composition mirrors going deeper underground — rats are surface dwellers, shadows are the deep threat
- Side room ambush traps should feel like "you walked into their nest" — enemies appear when you enter, not visible from corridor
- Pre-boss mercy health pickup signals "last chance to prepare" without explicit text

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 19-sewers-zone*
*Context gathered: 2026-01-29*
