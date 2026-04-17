# Task for worker

Design an interface for merging two React components in provider-bw/libs/bw-react-cockpit cashflow table: CashflowTableCellComponent and CashflowTableSummaryValueCellComponent.

Requirements:
- Both render a clickable MUI TableCell for a period column.
- Both share column highlight behavior via useIsColumnSelected(columnIndex).
- Both share default click behavior: onClick override, otherwise setPeriod(dayjs(dateFrom)).
- Both share nearly identical TableCell sx and identical colorMode logic (balance/final/none).
- One variant renders a simple formatted number with optional LinearProgress bar.
- The other variant renders a compact currency amount with optional CashflowQualityIndicator and accepts null values.
- Current callers: NetBalanceRow, CategoryDataRow, FinalBalanceRow, IncomeCategories, CostsCategories.
- Constraints: React + TypeScript + MUI, preserve memoization/perf mindset, avoid over-generalizing if possible, hide highlight/click/color/styling internals.
- For THIS design, maximize flexibility. Support future renderers and additional cell content types.
- Output format: 1. Interface signature 2. Usage example 3. What this design hides internally 4. Trade-offs of this approach

Propose a design that uses the smallest practical public surface while still supporting arbitrary future content via a slot/render prop or equivalent.