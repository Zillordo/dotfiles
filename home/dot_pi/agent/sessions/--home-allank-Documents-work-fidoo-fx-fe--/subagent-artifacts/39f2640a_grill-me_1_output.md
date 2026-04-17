First question: should we optimize the jscpd setup for **maximizing true duplicate findings** or for **minimizing false positives/noise**?

Recommended answer: **minimizing false positives first** — start with a focused `src/` scan, ignore generated/test/snapshot paths, and use a slightly conservative threshold so the report is actionable.