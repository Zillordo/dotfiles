---
name: duplication-auditor
description: Runs conservative jscpd and fallow audits over bw-react code, then compares the reports and writes a curated markdown summary of meaningful duplication and refactor opportunities.
---

# Duplication Auditor

Use this skill when the user wants to analyze duplicate or near-duplicate React/TypeScript code in `bw-react` folders.

This skill is **analysis-only**: do not edit, refactor, rename, move, or patch code. Only run scans, compare findings, and provide a written assessment.

## Scope rules

- The default audit is intentionally **low-noise first**: prefer fewer false positives over maximizing raw duplicate counts.
- The analysis must always stay inside paths that contain `bw-react`.
- The default scan should focus on `src/` trees beneath the requested `bw-react` scope.
- If the user provides a narrower path such as `provider-bw/libs/bw-react-cockpit/`, analyze that subtree and prefer `provider-bw/libs/bw-react-cockpit/src` when it exists.
- Ignore obvious noise by default:
  - tests/specs
  - generated code
  - `node_modules`
  - build artifacts
  - story files
  - snapshots

## Workflow

1. Build one shared filtered workspace containing only the selected `bw-react` production-leaning `src` files.
2. Run `jscpd` on that workspace for exact / near-exact duplication.
3. Run `fallow` on that same workspace for semantic duplication.
4. Read both outputs.
5. Compare overlap and unique findings on the same scan surface.
6. Filter out false positives and low-value boilerplate.
7. Classify the remaining items as meaningful refactor opportunities.
8. Write a markdown summary for tech debt backlog use.

## Inputs

When invoked by the user, accept an optional path argument.
Examples:

```text
/skill:duplication-auditor provider-bw/libs/bw-react-cockpit/
/skill:duplication-auditor provider-bw/libs/bw-react-marketplace/
```

If the user omits the path, default to a repo-wide `bw-react` source-tree sweep.

## Output

Produce a concise but actionable summary containing:
- scope analyzed
- tool configuration used
- top hotspots
- items found by both tools
- items found only by `fallow`
- items found only by `jscpd`
- false positives removed
- prioritized refactor backlog (described as recommendations only; do not implement changes)
- a short conclusion on whether each duplicate family meaningfully reduces code complexity

## Implementation notes

- Use the helper script for the deterministic scan and report generation:
  - `node /home/allank/.pi/agent/skills/duplication-auditor/scripts/run-duplication-auditor.mjs [scope]`
- Run the command from the target repository root.
- Prefer writing outputs to `docs/analysis/`.
- Keep summaries focused on analysis and refactor value, not raw duplication counts.
- The helper runs both tools against the same filtered workspace, so overlap counts are much more trustworthy.
- Explicitly state that no code changes were made or are proposed as part of execution; the skill only analyzes and reports.
