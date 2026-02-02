# Feature Code Review Risk Register

## Summary
Risks associated with the efficiency, modularization, E2E expansion, workflow, and UI optimization effort.

| ID | Risk | Impact | Likelihood | Mitigation | Owner | Status |
|----|------|--------|------------|------------|-------|--------|
| R1 | Merge artifact cleanup alters save/load behavior | Save compatibility or regressions | Medium | Choose one authoritative SaveManager path, add manual save/load validation | Eng | Open |
| R2 | EntityRegistry cache becomes stale | Enemies or player not tracked correctly | Medium | Use SceneTree node added/removed hooks and validate counts in tests | Eng | Open |
| R3 | UI theme changes affect layout | HUD or menus misaligned | Medium | Apply theme incrementally and verify in editor | Eng | Open |
| R4 | E2E runner flakiness | False failures in automated checks | Medium | Add retries and stable waits in UITester | Eng | Open |
| R5 | Damage helper refactor breaks combat | Player/enemy damage not applied | Medium | Add targeted combat checks in UITester and manual tests | Eng | Open |
| R6 | Performance changes regress behavior | Gameplay timing or AI logic drift | Low | Capture baseline metrics and compare after changes | Eng | Open |

## Validation Steps
- Run headless E2E suite and compare results to baseline
- Execute manual HUD, pause, ring menu, and save/load flows
- Verify combat hits for swoop and bomb damage

## Review Cadence
- After CR-2 merge cleanup
- After CR-3 caching changes
- After CR-5 E2E expansion
