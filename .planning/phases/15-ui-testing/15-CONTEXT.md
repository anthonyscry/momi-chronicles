# Phase 15: UI Testing Automation - Context

**Gathered:** 2026-01-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Automated UI testing system extending AutoBot. Verifies all UI flows (title → gameplay → pause → game over → retry) and HUD elements (health, guard, coins, EXP, combo). Outputs detailed test reports to console. Does NOT include visual regression testing or external test frameworks.

</domain>

<decisions>
## Implementation Decisions

### Test triggering & control
- F2 toggles UITester mode (separate from F1 AutoBot gameplay)
- Claude's discretion on most effective triggering approach
- Should feel natural alongside existing AutoBot infrastructure

### Test output & reporting
- Maximum detail — log every check performed
- Show actual values vs expected values for each verification
- Include helpful context (what state the game is in, what triggered the check)
- Clear pass/fail summary at end with counts
- Timestamp each test for timing analysis
- Print which scenario is running before each scenario starts

### Failure behavior
- Run ALL tests regardless of failures (don't stop on first failure)
- Screenshot on EVERY failure (save to `exports/test_screenshots/`)
- Attempt small incremental fixes where possible, then retry
- If fix + retry still fails, log the failure and continue
- At end, summarize: X passed, Y failed, Z fixed-on-retry

### Verification criteria (comprehensive)
- **Existence checks:** Node exists in tree, is visible, is not null
- **Value checks:** Health bar shows correct HP, coin counter shows correct count, EXP bar shows correct level/progress
- **State checks:** Button is focused, menu is visible/hidden, correct scene loaded
- **Timing checks:** Transitions complete within expected time
- **Interaction checks:** Buttons respond to simulated input, sliders move

### Test scenarios to cover
1. **Title screen flow:** Title loads → buttons visible → Start works → scene changes
2. **Gameplay HUD:** Health bar, guard bar, coin counter, EXP bar, combo counter all present and updating
3. **Pause menu flow:** ESC opens pause → buttons work → sliders adjust audio → resume works
4. **Game over flow:** Player death → game over screen → retry returns to gameplay
5. **New features smoke test:** Block/parry visual feedback, pickup collection effects, save/load indicators

### Claude's Discretion
- Exact test triggering mechanism (run all on F2, or present menu of scenarios)
- Test execution order and grouping
- Screenshot naming convention
- Fix/retry logic implementation details
- How to simulate button presses and interactions

</decisions>

<specifics>
## Specific Ideas

- Should integrate with existing AutoBot infrastructure (auto_bot.gd)
- Test output should be readable in Godot's output panel during development
- Screenshots help debug what went wrong visually
- "Fixed-on-retry" concept: if a timing issue causes failure, wait a frame and retry before marking as failed

</specifics>

<deferred>
## Deferred Ideas

- Visual regression testing (pixel-perfect comparison) — too complex for this phase
- External test framework integration (GUT, etc.) — using built-in approach
- Continuous integration hooks — future phase
- Performance benchmarking — separate concern

</deferred>

---

*Phase: 15-ui-testing*
*Context gathered: 2026-01-28*
