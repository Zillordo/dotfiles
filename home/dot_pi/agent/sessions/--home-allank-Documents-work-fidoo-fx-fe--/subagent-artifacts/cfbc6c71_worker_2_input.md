# Task for worker

[Read from: /tmp/pi-subagents-uid-1000/chain-runs/cfbc6c71/context.md, /tmp/pi-subagents-uid-1000/chain-runs/cfbc6c71/plan.md]

implement the plan

---
Create and maintain progress at: /tmp/pi-subagents-uid-1000/chain-runs/cfbc6c71/progress.md
Previous step output:
# Implementation Plan

## Goal
Update the recommendation-processing workflow so that each refactoring recommendation is run through the existing `interface-design` skill and produces a synthesized interface recommendation before any implementation work begins.

## Tasks
1. **Locate the authoritative refactoring recommendation source**
   - File: `TBD — the report, chain output, or prompt artifact that contains the refactoring recommendations`
   - Changes: None until the source is identified; confirm the exact input format, recommendation boundaries, and whether recommendations already include target files/modules.
   - Acceptance: A single authoritative source is identified, and each recommendation can be enumerated deterministically.

2. **Define the recommendation-to-interface-design mapping**
   - File: `TBD — the orchestration prompt/chain step that currently consumes refactoring recommendations`
   - Changes: Specify how each recommendation is converted into an interface-design brief, including problem statement, callers, key operations, constraints, and hidden complexity expectations.
   - Acceptance: For every recommendation, the workflow can generate a complete requirements summary that satisfies the `interface-design` skill input checklist.

3. **Extend the orchestration to invoke `interface-design` per recommendation**
   - File: `TBD — the agent, chain, or task definition responsible for processing refactoring recommendations`
   - Changes: Iterate over the recommendation list and, for each item, invoke the `interface-design` skill rather than treating recommendations as plain prose. Ensure each invocation requests 3+ radically different interface designs in parallel, followed by comparison and synthesis.
   - Acceptance: Running the workflow on a recommendation list produces one interface-design analysis block per recommendation.

4. **Standardize the output contract for each recommendation**
   - File: `TBD — output template, report formatter, or chain step that aggregates results`
   - Changes: Require each per-recommendation result to include: requirements summary, 3+ contrasting designs, usage examples, hidden complexity, trade-off comparison, and a recommended interface direction.
   - Acceptance: Output for each recommendation is structured, complete, and directly usable by a later implementation step.

5. **Handle missing or underspecified recommendations safely**
   - File: `TBD — same orchestration file(s) as Tasks 2–4`
   - Changes: Add guardrails so recommendations without enough context are flagged for clarification instead of producing low-confidence interface designs.
   - Acceptance: Ambiguous recommendations are explicitly reported as blocked, with the missing inputs called out.

6. **Validate the workflow with a representative recommendation set**
   - File: `TBD — test fixture, sample input, or manual execution notes`
   - Changes: Run the updated workflow against at least one known recommendation list and verify that each item receives an independent interface-design analysis.
   - Acceptance: The number of generated interface-design outputs matches the number of input recommendations, and each output follows the required structure.

## Files to Modify
- `TBD — recommendation source consumer` - add iteration over recommendations and per-item skill invocation.
- `TBD — orchestration prompt/chain definition` - encode the `interface-design` workflow requirements for each recommendation.
- `TBD — output/report template` - format per-recommendation interface design results consistently.
- `TBD — test fixture or validation artifact` - cover multi-recommendation execution and ambiguity handling.

## New Files (if any)
- `TBD — sample recommendation fixture` - representative input for validating per-recommendation processing.
- `TBD — golden output / snapshot / documentation note` - expected structure for generated interface-design results.

## Dependencies
- Task 2 depends on Task 1.
- Task 3 depends on Task 2.
- Task 4 depends on Task 3.
- Task 5 depends on Tasks 2 and 3.
- Task 6 depends on Tasks 3–5.

## Risks
- The authoritative recommendation source is currently unknown; without it, implementation targets and file paths cannot be identified precisely.
- Recommendations may be too vague to satisfy the `interface-design` skill’s requirement-gathering step.
- If the workflow does not enforce radical variation across sub-agents, outputs may collapse into near-duplicate interface options.
- Aggregated output may become difficult to review if multiple recommendations are processed without a strict per-item structure.