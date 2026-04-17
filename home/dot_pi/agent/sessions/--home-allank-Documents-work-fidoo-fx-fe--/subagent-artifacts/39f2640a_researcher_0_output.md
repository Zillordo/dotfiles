# Research: Using jscpd to find duplicates in React projects

## Summary
jscpd is best used in React codebases as a **signal generator**, not an auto-refactor tool: run it on `src/` with sensible file patterns, ignore generated/test/build output, and tune `min-lines`, `min-tokens`, and `threshold` so it surfaces real maintenance problems instead of tiny JSX repeats. In React, the right response to a duplicate depends on what is duplicated: **UI repetition usually becomes composition or a reusable component, shared stateful logic usually becomes a custom Hook, and shared state itself should be lifted up**. [jscpd installation/configuration](https://jscpd.dev/getting-started/installation) [React custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)

## Findings
1. **Start with a focused scan, not the whole repo.** jscpd supports pattern-based scans (`--pattern`) and `.jscpd.json` config, so in React projects you should usually target `src/**/*.{js,jsx,ts,tsx}` and exclude `dist/`, `build/`, `coverage/`, snapshots, and dependencies. That keeps clone reports relevant to code you actually maintain. [jscpd installation](https://jscpd.dev/getting-started/installation) [jscpd configuration](https://jscpd.dev/getting-started/configuration)

2. **Tune detection for React’s small, repetitive syntax.** jscpd defaults to `minLines: 5` and `minTokens: 50`; for React, that is often a good baseline, but many teams get better results by increasing the bar a bit for JSX-heavy code so repeated prop wrappers and markup fragments do not flood the report. A practical starting point is to keep the defaults, inspect false positives, then raise thresholds for noisy folders or file types. [jscpd configuration](https://jscpd.dev/getting-started/configuration)

3. **Use reporters that support review and CI.** jscpd’s HTML reporter is useful for manual review, JSON is best for CI integration, and the `threshold` reporter can fail builds when duplication crosses an agreed limit. A common workflow is: local HTML review, CI JSON output, and a threshold gate that starts lenient and tightens over time. [jscpd reporters](https://jscpd.dev/reporters/html) [jscpd reporters](https://jscpd.dev/reporters/json) [jscpd reporters](https://jscpd.dev/reporters)

4. **In React, duplicate logic should usually become a custom Hook.** React’s official guidance shows duplicated effect/state logic being extracted into `useOnlineStatus`, `useChatRoom`, or similar Hooks, because custom Hooks share **stateful logic** without sharing state itself. This is the most direct way to turn jscpd hits in effect-heavy code into maintainable abstractions. [React custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)

5. **Do not over-abstract JSX duplicates into “lifecycle” Hooks.** React recommends keeping custom Hooks focused on concrete use cases and avoiding abstract wrappers like `useMount` or `useEffectOnce`. If jscpd flags repeated UI structure, prefer a component composition/refactor; if it flags repeated effect code, prefer a domain-specific Hook. [React custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)

6. **If the duplicated thing is state, not logic, use lifting state instead of a Hook.** React’s docs are explicit that custom Hooks do not share state between callers. So when jscpd finds repeated state variables that really need to be shared, the right fix is to lift state up and pass it down, not to wrap the state in a Hook. [React custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)

7. **React’s rules-of-hooks docs matter when refactoring jscpd findings.** Because Hooks must be called from components or other Hooks and should not be passed around dynamically, refactors should stay static and explicit. That makes jscpd findings a good trigger for cleanup, but the final abstraction must still follow React’s hook rules. [React rules](https://react.dev/reference/rules/react-calls-components-and-hooks)

## Recommended workflow for React
1. Run jscpd on `src/` with JSX/TSX patterns only.
2. Ignore generated, test, and snapshot folders first.
3. Review HTML output locally and sort findings by repeated domain logic, not raw count.
4. Refactor in this order:
   - repeated effects/async/data sync → custom Hook
   - repeated UI structure → reusable component/composition
   - repeated state that must be shared → lift state up
5. Add a CI threshold only after the noise level is acceptable.

### Example baseline config
```json
{
  "threshold": 2,
  "minLines": 8,
  "minTokens": 80,
  "reporters": ["html", "json", "console"],
  "ignore": [
    "**/node_modules/**",
    "**/dist/**",
    "**/build/**",
    "**/coverage/**",
    "**/__snapshots__/**",
    "**/*.test.*",
    "**/*.spec.*"
  ],
  "gitignore": true,
  "absolute": true
}
```

## Sources
- Kept: jscpd Installation / Basic Usage / Config examples — best official starting point for CLI and `.jscpd.json` setup. https://jscpd.dev/getting-started/installation
- Kept: jscpd Configuration — official list of `minLines`, `minTokens`, `threshold`, `ignore`, and `gitignore` options. https://jscpd.dev/getting-started/configuration
- Kept: jscpd Reporters — official guidance for HTML, JSON, and threshold-based reporting. https://jscpd.dev/reporters
- Kept: React — Reusing Logic with Custom Hooks — best authoritative guidance for how to refactor duplicated logic in React. https://react.dev/learn/reusing-logic-with-custom-hooks
- Kept: React — React calls Components and Hooks — rules that constrain safe refactors. https://react.dev/reference/rules/react-calls-components-and-hooks
- Dropped: generic DRY/React blog posts from DEV/Medium — useful background, but less authoritative than React’s official docs.

## Gaps
- jscpd’s docs are strong on configuration and reporters, but they do not prescribe React-specific thresholds; the recommended `minLines`/`minTokens` values above are a practical starting point, not an official rule.
- I did not find a first-party jscpd guide specifically for React/TSX-only workflows, so the React-specific advice here is a synthesis of jscpd’s generic scanning options and React’s official refactoring guidance.
