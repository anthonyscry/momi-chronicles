# UI Audit

## Summary
HUD and menu systems are functional but include per-frame updates and repeated styling. Targeted optimization can reduce allocations and improve responsiveness.

## HUD Findings
- `ui/hud/coin_counter.gd` updates display in `_process` even when stable.
- `ui/hud/combo_counter.gd` creates ColorRect sparks on combo events (no pooling).
- `ui/hud/game_hud.gd` creates runtime nodes (vignette, save indicator, tutorial prompt) - acceptable but should avoid repeated tweens.

## Menu Findings
- Title, pause, settings menus use multiple Label overrides and theme overrides.
- A shared HUD theme resource would reduce repeated configuration.

## Recommendations
1) Gate coin counter updates to changes only.
2) Pool combo spark nodes or cap per-combo allocations.
3) Introduce `ui/themes/hud_theme.tres` and apply to HUD scene(s).

## Validation Steps
- Verify no visual regressions in HUD layout and fonts.
- Check UI updates for health, coins, guard, and combo changes.
