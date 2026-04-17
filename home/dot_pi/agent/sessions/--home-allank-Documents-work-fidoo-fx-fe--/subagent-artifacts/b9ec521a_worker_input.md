# Task for worker

Design an interface for merging the cashflow table components around the most common cases in this codebase. The primary callers are the income categories, costs categories, net balance row, and final balance row. Requirements: preserve current rendering, use meaningful names, keep the API easy for these four call sites, and make the common case concise. Reduce duplicated naming between category and summary components. Constraints for this design: optimize for the most common case — two collapsible category sections and two summary rows.

Output format:
1. Interface signature (types/methods)
2. Usage example (how caller uses it)
3. What this design hides internally
4. Trade-offs of this approach