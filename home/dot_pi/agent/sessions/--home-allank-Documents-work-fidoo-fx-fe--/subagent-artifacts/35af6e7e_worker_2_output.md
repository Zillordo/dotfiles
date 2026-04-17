Implemented the refactor and validated it.

What changed:
- Added a shared cashflow value-cell shell and refactored:
  - `CashflowTableCell`
  - `CashflowTableSummaryValueCell`
- Added a preset-driven unified category section:
  - `CashflowTableCategorySection`
  - updated `CashflowTable` to use it
- Extracted shared calendar picker orchestration:
  - `useControlledCalendarPicker`
  - refactored `MonthPicker` and `WeekPicker`
- Exported the new shared cashflow table primitives from `components/index.ts`

Validation:
- `nx lint bw-react-cockpit` ✅
- `nx typecheck bw-react-cockpit` ✅
- `nx test bw-react-cockpit` ✅

Progress file updated at:
- `/tmp/pi-subagents-uid-1000/chain-runs/35af6e7e/progress.md`

Note:
- I left the old income/costs wrapper files in place as unused compatibility files rather than deleting them.