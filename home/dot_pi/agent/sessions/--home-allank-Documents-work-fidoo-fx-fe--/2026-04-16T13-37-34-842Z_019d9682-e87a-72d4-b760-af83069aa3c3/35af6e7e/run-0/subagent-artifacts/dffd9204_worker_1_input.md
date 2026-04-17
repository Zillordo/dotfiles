# Task for worker

Design an interface for refactoring the duplication between CashflowTableCostsCategories.tsx and CashflowTableIncomeCategories.tsx in bw-react-cockpit cashflow table.

Requirements:
- Both render a category section wrapper with header title, icon, trigger, mapped summary cells across periods, and mapped category rows.
- Differences are label key, icon/color, categoryType, period total field (income vs costs), filter list, and transaction direction.
- Recommend an interface to share structure while keeping callsites readable.

Constraint for this design: Optimize for the most common case and make the caller terse.

Output format:
1. Interface signature
2. Usage example
3. What this design hides internally
4. Trade-offs of this approach