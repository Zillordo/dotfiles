# Code Context

The task requests: **"for each of the refactoring recommendations spawn the interface desing skill"**.

## Interpretation
- Apply the `interface-design` skill to **each existing refactoring recommendation**.
- The `interface-design` skill requires generating multiple radically different interface options, typically via parallel sub-agents.
- No concrete source file containing the target refactoring recommendations was provided in this prompt.

## Interface-Design Skill Requirements
Source: `/home/allank/.pi/agent/skills/interface-design/SKILL.md`

Key workflow required by the skill:
1. Gather requirements for the module/problem.
2. Spawn **3+ sub-agents in parallel** per recommendation, each producing a radically different design.
3. Present each design with:
   - interface signature
   - usage example
   - what complexity is hidden internally
   - trade-offs
4. Compare the designs.
5. Synthesize a recommended direction.

## Constraint / Blocker
I could not identify the actual list of refactoring recommendations from the current task alone.
A repository-wide search for generic terms like `refactor` and `recommendations` returned many unrelated hits, but no authoritative file or report was specified as the source of recommendations to process.

## What is Needed
To execute this accurately, provide one of:
- the file/path containing the refactoring recommendations, or
- the actual recommendation list, or
- the previous chain output that produced those recommendations.

## Suggested Next Step
Once the recommendation source is identified, process **each recommendation independently** using the `interface-design` skill and produce, for each:
- requirements summary
- 3+ contrasting interface designs
- comparison
- synthesis / recommendation
