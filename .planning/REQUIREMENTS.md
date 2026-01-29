# Requirements: Momi's Adventure

**Defined:** 2026-01-29
**Core Value:** Satisfying action RPG combat with Momi and friends — everything wired up and working

## v1.6 Requirements

Requirements for the Visual Polish milestone. Replace all placeholder colored shapes with AI-generated pixel art sprites.

### Tooling (TOOL)

- [x] **TOOL-01**: Gemini automation script generates sprites from `prompts.json` via Playwright browser
- [x] **TOOL-02**: `rip_sprites.py` removes backgrounds and downscales all generated art to game-ready PNGs

### Character Sprites (CHAR)

- [ ] **CHAR-01**: Player (Momi) uses animated sprite sheets for all states (idle, walk, run, attack, dodge, block, hurt, death)
- [ ] **CHAR-02**: Cinnamon companion uses animated sprite sheets (idle, walk, attack, overheat)
- [ ] **CHAR-03**: Philo companion uses animated sprite sheets (idle, walk, attack, motivated, lazy)

### Enemy Sprites (ENEM)

- [ ] **ENEM-01**: All 5 enemy types use sprite-based visuals instead of colored polygons (raccoon, crow, stray cat, sewer rat, shadow creature)
- [ ] **ENEM-02**: All 3 mini-bosses use sprite-based visuals (Alpha Raccoon, Crow Matriarch, Rat King)
- [ ] **ENEM-03**: Raccoon King boss uses sprite-based visuals with enrage variant

### NPC & World Sprites (WRLD)

- [ ] **WRLD-01**: Nutkin shop NPC uses sprite-based visuals
- [ ] **WRLD-02**: Item and equipment icons display as pixel art in ring menu and shop UI

### Effects & Particles (FX)

- [ ] **FX-01**: Combat effects use sprite-based textures instead of ColorRect (hit spark, death poof, dust puff)
- [ ] **FX-02**: Pickup items (health heart, coin) use sprite-based visuals instead of colored shapes

### Integration (INTG)

- [ ] **INTG-01**: All Polygon2D character nodes replaced with Sprite2D or AnimatedSprite2D across all .tscn files
- [ ] **INTG-02**: EffectsManager particle spawning uses sprite textures instead of ColorRect.new()

## Out of Scope

| Feature | Reason |
|---------|--------|
| New audio/music | Audio system already complete (88 tracks) — defer to future milestone |
| Zone tileset replacement | Existing tile_atlas.png works; full tileset rework is a separate milestone |
| UI redesign (HUD layout) | Only skinning item/equipment icons, not restructuring HUD |
| New gameplay features | Visual-only milestone — no mechanics changes |
| AnimationPlayer rework | Swap shapes → sprites, keep existing state machine logic |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| TOOL-01 | Phase 30 | Complete |
| TOOL-02 | Phase 30 | Complete |
| CHAR-01 | Phase 32 | Pending |
| CHAR-02 | Phase 33 | Pending |
| CHAR-03 | Phase 33 | Pending |
| ENEM-01 | Phase 34 | Pending |
| ENEM-02 | Phase 34 | Pending |
| ENEM-03 | Phase 34 | Pending |
| WRLD-01 | Phase 35 | Pending |
| WRLD-02 | Phase 35 | Pending |
| FX-01 | Phase 35 | Pending |
| FX-02 | Phase 35 | Pending |
| INTG-01 | Phase 35 | Pending |
| INTG-02 | Phase 35 | Pending |

**Coverage:**
- v1.6 requirements: 14 total
- Mapped to phases: 14 ✓
- Unmapped: 0

---
*Requirements defined: 2026-01-29*
*Last updated: 2026-01-29 after Phase 30 completion*
