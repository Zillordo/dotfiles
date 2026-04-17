Implemented the duplication-auditor updates.

What changed:
- `.pi/skills/duplication-auditor/SKILL.md`
  - Reworded the skill to make **low-noise-first** the default.
  - Clarified that scans should focus on `bw-react` `src/` trees.
  - Documented default exclusions for tests, stories, snapshots, generated/build output, and `node_modules`.
  - Added a caveat that `fallow` may not be scanning the exact same surface as `jscpd`.

- `.pi/skills/duplication-auditor/scripts/run-duplication-auditor.mjs`
  - Resolved `jscpd` targets to `bw-react` `src/` directories instead of broad package roots.
  - Added fallback handling when a scope has no direct `src` child.
  - Added conservative defaults:
    - `min-lines: 8`
    - `min-tokens: 80`
    - explicit ignore globs for tests/specs/stories/snapshots/generated/build artifacts/node_modules
  - Expanded the generated summary to show:
    - requested scope
    - effective jscpd targets
    - fallback usage and rationale
    - ignore rules
    - thresholds
    - comparison caveat for `fallow`

- `/tmp/pi-subagents-uid-1000/chain-runs/39f2640a/progress.md`
  - Updated progress to completed.

Validation:
- `node --check` passed for the updated helper script.
- A runtime smoke test couldn’t complete here because `jscpd` is not installed on the PATH in this environment (`spawnSync jscpd ENOENT`).