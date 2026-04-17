# Implementation Plan

## Goal
Adjust the `duplication-auditor` skill so its default duplication scan prioritizes low-noise, actionable `jscpd` findings by focusing on `src/` code, excluding obvious false-positive paths, and using conservative duplication thresholds.

## Tasks
1. **Update the skill contract to make “low-noise first” the default behavior**
   - File: `.pi/skills/duplication-auditor/SKILL.md`
   - Changes: Revise the skill description, scope rules, and workflow notes so they explicitly say the default audit should prefer minimizing false positives over maximizing raw duplicate counts. Document that scans should focus on `src/` content inside `bw-react` paths, ignore tests/specs/stories/snapshots/generated/build artifacts by default, and allow users to widen the scan only when they ask for a broader pass.
   - Acceptance: Reading `SKILL.md` makes it clear that the default mode is a focused, conservative scan and that the current repo-wide broad scan is no longer the intended behavior.

2. **Narrow the helper script’s default `jscpd` target selection to production source trees**
   - File: `.pi/skills/duplication-auditor/scripts/run-duplication-auditor.mjs`
   - Changes: Change the path-selection logic so `jscpd` scans `src/` under the requested `bw-react` scope instead of broad package roots. For repo-wide runs, resolve the scan to the relevant `bw-react` source directories rather than all of `provider-bw`. Add a safe fallback for scopes that do not have a direct `src/` child so the script still works without silently scanning unrelated directories.
   - Acceptance: A scoped run against something like `provider-bw/libs/bw-react-cockpit/` targets `provider-bw/libs/bw-react-cockpit/src`, and the no-scope default no longer scans the whole `provider-bw` tree.

3. **Add conservative `jscpd` defaults that suppress common noise**
   - File: `.pi/skills/duplication-auditor/scripts/run-duplication-auditor.mjs`
   - Changes: Bake in default ignore globs for `__tests__`, `*.test.*`, `*.spec.*`, story files, snapshots, generated code, `node_modules`, and build output; add slightly conservative duplication thresholds (for example higher-than-default `min-lines` and/or `min-tokens`) so tiny boilerplate matches are filtered out. Preserve a user override path via existing passthrough/custom args so broader audits are still possible.
   - Acceptance: The generated `jscpd` command includes explicit low-noise defaults, and users can still override them when they want a more exhaustive scan.

4. **Surface the effective scan configuration in the generated summary**
   - File: `.pi/skills/duplication-auditor/scripts/run-duplication-auditor.mjs`
   - Changes: Expand the markdown summary to record the effective scope, resolved source paths, ignore rules, and thresholds used for the run. If fallback behavior is triggered, note that in the summary so downstream interpretation is transparent.
   - Acceptance: The summary file clearly shows what was actually scanned and why, making the report reproducible and easier to review.

5. **Sanity-check tool alignment and document any mismatch risk**
   - File: `.pi/skills/duplication-auditor/SKILL.md`
   - Changes: Clarify whether `fallow` should follow the same narrowed scope/ignore philosophy, or explicitly warn that the two tools may report on different effective scopes until the helper is aligned. This keeps the comparison step honest.
   - Acceptance: The skill instructions no longer imply an apples-to-apples comparison if the tools are scanning materially different content.

## Files to Modify
- `.pi/skills/duplication-auditor/SKILL.md` - document the new low-noise-first policy, focused `src/` targeting, exclusions, and comparison caveats
- `.pi/skills/duplication-auditor/scripts/run-duplication-auditor.mjs` - implement focused `jscpd` scope resolution, ignore defaults, conservative thresholds, and richer summary output

## New Files (if any)
- None

## Dependencies
- Task 1 should happen first or alongside Task 2 so the intended behavior is explicit before implementation details are finalized.
- Task 2 is a prerequisite for Task 3 because ignore rules and thresholds should be applied to the resolved scan targets.
- Task 4 depends on Tasks 2 and 3 so it can report the final effective configuration.
- Task 5 depends on reviewing the final script behavior and any remaining `fallow` differences.

## Risks
- `jscpd` CLI flag syntax for ignore patterns and multi-path scans must match the installed version; verify before coding.
- Some valid duplicate hotspots may live outside `src/`, so the tighter default could miss them unless the override path is well documented.
- Some `bw-react` scopes may not have a simple `src/` layout, so fallback behavior must be explicit and predictable.
- If `fallow` remains broader than `jscpd`, comparison output may still be skewed unless the difference is called out clearly.