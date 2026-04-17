# Task for worker

Design an interface for merging two React components in provider-bw/libs/bw-react-cockpit cashflow table: CashflowTableCellComponent and CashflowTableSummaryValueCellComponent.

Inferred requirements from current code:
- Both render a clickable MUI TableCell for a period column.
- Both share column highlight behavior via useIsColumnSelected(columnIndex).
- Both share default click behavior: onClick override, otherwise setPeriod(dayjs(dateFrom)).
- Both share nearly identical TableCell sx and identical colorMode logic (balance/final/none).
- One variant renders a simple formatted number with optional LinearProgress bar.
- The other variant renders a compact currency amount with optional CashflowQualityIndicator and accepts null values.
- Current callers:
  - CashflowTableNetBalanceRow -> simple numeric value, bold, colorMode=balance
  - CashflowCategoryDataRow -> simple numeric value, custom onClick for detail
  - CashflowTableFinalBalanceRow -> summary value + quality indicator + currency, bold, colorMode=final
  - CashflowTableIncomeCategories / CashflowTableCostsCategories -> summary value + currency, bold, colorMode=none
- Constraints:
  - React + TypeScript + MUI
  - preserve memoization/perf mindset
  - avoid over-generalizing if possible
  - hide highlight/click/color/styling internals
  - design interface only, do not implement

Constraint for this design: Take inspiration from headless/slot-based component APIs (MUI slots / Radix-style composition). Separate behavior shell from content.

Output format:
1. Interface signature
2. Usage example
3. What this design hides internally
4. Trade-offs of this approach