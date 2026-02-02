# Testing Gap Analysis

## Current State
- Manual tests exist in `tests/MANUAL_TEST_CHECKLIST.md` and `tests/README.md`.
- UITester exists as an autoload and runs scenarios with F2.
- No CI or headless E2E runner is wired.

## Gaps
1) No headless E2E runner scene or script
2) No automated coverage for edge cases (pause/resume, save/load, UI visibility)
3) No workflow script for repeatable test runs

## Recommended Additions
- `tests/e2e_full_suite.tscn` + `tests/e2e_full_suite.gd`
- Update `tests/run_tests.sh` and `tests/run_tests.bat` to include E2E
- Add `scripts/run_e2e.sh` and `scripts/run_e2e.bat` for local workflows

## Edge Cases to Cover
- Pause menu toggle while UI tests are running
- Save/load after zone transition
- HUD elements hidden/visible states when ring menu opens
- Game over and retry flows

## Validation Steps
- Run headless E2E suite and inspect output logs
- Manual spot checks of critical UI flows
