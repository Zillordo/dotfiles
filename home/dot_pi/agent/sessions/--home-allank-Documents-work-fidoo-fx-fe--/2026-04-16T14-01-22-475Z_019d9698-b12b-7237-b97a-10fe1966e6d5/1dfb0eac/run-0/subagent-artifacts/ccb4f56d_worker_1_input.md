# Task for worker

Design an interface for merging the cashflow table section components into one cohesive component family.

Current modules and behavior:
- provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCategorySection.tsx renders a collapsible income/costs section header with icon, title, toggle, total value cells, and body category rows.
- provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowCategory.tsx exposes many low-level pieces: CashflowCategory, CashflowCategoryHeader, CashflowCategoryHeaderTitle, CashflowCategoryHeaderIcon, CashflowCategoryRow, CashflowCategoryRowLabel, CashflowCategoryTrigger, CashflowCategoryRows.
- provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowCategoryDataRow.tsx renders clickable label + clickable value cells to open detail.
- provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummary.tsx and CashflowTableSummaryValueCell.tsx render summary rows with a static first label cell and value cells.
- provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableNetBalanceRow.tsx and CashflowTableFinalBalanceRow.tsx use the summary components.
- Fixed first-column width is defined by cashflowLayoutConfig.labelColumnWidth and must stay consistent.
- Table structure must be preserved (TableRow/TableCell-based layout).

Requirements:
- preserve existing table structure
- keep fixed first-column label width consistent
- support collapsible sections for income/costs
- support summary rows like net balance/final balance
- reduce duplicated naming between category and summary components
- maximize flexibility for future variants and optional behaviors like click-to-open detail or custom header actions
- keep caller API meaningful and easy to read

Constraint for this design: Maximize flexibility — support many use cases, future variants, optional click-to-open detail, custom header actions, custom row/cell behaviors.

Output format:
1. Interface signature (types/methods)
2. Usage example (how caller uses it)
3. What this design hides internally
4. Trade-offs of this approach