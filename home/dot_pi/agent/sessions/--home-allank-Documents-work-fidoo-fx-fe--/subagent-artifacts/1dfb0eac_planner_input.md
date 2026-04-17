# Task for planner

Design an interface for merging the cashflow table section components into one cohesive component family. Current modules include category sections (collapsible section header, icon, toggle, body rows, clickable row labels, detail opening) and summary rows (static label cell, summary value cells). Requirements: preserve the existing table structure, keep the fixed first-column label width consistent, support collapsible sections for income/costs, support summary rows like net balance/final balance, and keep the caller API meaningful and easy to read. We want to reduce duplicated naming between category and summary components. Constraints for this design: maximize flexibility — support many use cases, future variants, and optional behaviors like click-to-open detail or custom header actions.

Output format:
1. Interface signature (types/methods)
2. Usage example (how caller uses it)
3. What this design hides internally
4. Trade-offs of this approach

---
**Output:** Write your findings to: /home/allank/Documents/work/fidoo-fx-fe/plan.md