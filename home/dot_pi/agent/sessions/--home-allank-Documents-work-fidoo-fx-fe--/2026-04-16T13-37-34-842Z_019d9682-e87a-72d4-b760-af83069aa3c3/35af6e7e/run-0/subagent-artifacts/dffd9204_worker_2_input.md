# Task for worker

Design an interface for refactoring the duplication between CashflowCategory.tsx and CashflowTableSummary.tsx in bw-react-cockpit cashflow table.

Requirements:
- Both expose small row/label composition primitives around TableRow/TableCell.
- Both share nearly identical label cell styling using cashflowLayoutConfig.labelColumnWidth and border/background settings.
- CashflowCategory additionally includes context for expansion, trigger behavior, icons, clickable row labels, and rows wrapper.
- Recommend an interface that separates shared row-shell primitives from category-specific behavior.

Constraint for this design: Maximize flexibility - support many row types while keeping category-specific features composable.

Output format:
1. Interface signature
2. Usage example
3. What this design hides internally
4. Trade-offs of this approach