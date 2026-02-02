# Phase 16: Ring Menu System - Context

**Gathered:** 2026-01-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Secret of Mana-style radial ring menu for items, equipment, companions, and options. Full party system with 3 AI-controlled bulldog companions, each with unique meter mechanics. Does NOT include item/equipment creation, shops, or new zones.

</domain>

<decisions>
## Implementation Decisions

### Ring visual design
- Secret of Mana style, max 8 icons per ring
- More detailed icons than standard game pixel art
- Centered on Momi (active character)
- No background dimming — gameplay stays visible
- Collapse to actual items (no empty slots shown)
- Hover over item shows brief effect description

### Navigation & controls
- Tab opens and closes ring menu
- Left = counter-clockwise rotation, Right = clockwise
- Down switches rings (cycle: Items → Equipment → Companions → Options → Items)
- Double press to confirm and use selected item
- Smooth rotation animation like Secret of Mana

### Item & equipment behavior
- Game pauses when ring is open
- Ring closes immediately on item use, effect plays in gameplay
- Instant equipment swap (no confirmation needed)
- Max 10 per item type
- 5 equipment slots per character: Collar, Harness, Leash, Coat/Jacket/Shirt, Hat

### The Bulldog Squad (Party System)
- All 3 bulldogs fight together at once (full party)
- Q cycles active companion control (Momi → Cinnamon → Philo → Momi)
- Companions have AI with configurable distance + aggression (presets in Options ring)
- Companions can be knocked out — recover via items or rest at safe zone
- Each companion's unique meter shows near their health bar

### Companion Mechanics
- **Momi (French Bulldog, DPS)**: Zoomies meter builds from combat. When activated, drains while providing faster movement + faster attacks.
- **Cinnamon (English Bulldog, Tank)**: Overheat meter builds from blocking/taking hits. When maxed, forces cooldown period (can't block).
- **Philo (Boston Terrier, Support)**: Motivation meter starts high, drains over time. Restores when Momi gets hit (support activates when team needs help).

### Claude's Discretion
- Exact rotation animation timing/easing
- Icon designs and visual polish
- AI behavior preset names and exact values
- Meter fill/drain rates (balance tuning)
- Sound effects for ring navigation
- How knocked-out companions are visually represented

</decisions>

<specifics>
## Specific Ideas

- "Just like Secret of Mana" — the ring menu should feel nostalgic and familiar to fans
- Philo's mechanic creates natural synergy: support character gets motivated when the party is struggling
- Equipment slots reflect real dog accessories (collar, harness, leash, coat, hat)
- Q for quick companion cycling keeps combat flow smooth without opening the ring

</specifics>

<deferred>
## Deferred Ideas

- Shop system for buying items/equipment — future phase
- Item crafting/combining — future phase
- More companions beyond the initial 3 — future phase

</deferred>

---

*Phase: 16-ring-menu*
*Context gathered: 2026-01-28*
