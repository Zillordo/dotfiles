# Task for worker

[Read from: /tmp/pi-subagents-uid-1000/chain-runs/35af6e7e/context.md, /tmp/pi-subagents-uid-1000/chain-runs/35af6e7e/plan.md]

implement changes based on the plan

---
Create and maintain progress at: /tmp/pi-subagents-uid-1000/chain-runs/35af6e7e/progress.md
Previous step output:
# Implementation Plan

## Goal
Refactor the cockpit cashflow table and calendar pickers to use the recommended shared interfaces, reducing duplicated UI/state logic without changing behavior.

## Tasks
1. **Extract a shared value-cell shell for clickable/highlighted cashflow cells**
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableValueCell.tsx`
   - Changes: Add a memoized shell component that owns selected-column highlighting, default `setPeriod(dayjs(dateFrom))` click behavior, shared `TableCell` chrome, and shared value-color calculation; expose a minimal API of `columnIndex`, `dateFrom`, `isBold?`, `colorMode?`, `onClick?`, and `children`.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCell.tsx`
   - Changes: Convert to a thin amount/progress wrapper that keeps `formatCashflowAmount(...)` and optional `LinearProgress`, but delegates all shell behavior/styling to `CashflowTableValueCell`.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummaryValueCell.tsx`
   - Changes: Convert to a thin summary wrapper that keeps nullable `CurrencyAmount` rendering and `CashflowQualityIndicator`, but delegates shell behavior/styling to `CashflowTableValueCell`.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/index.ts`
   - Changes: Export the new shared shell if needed by sibling components.
   - Acceptance: `CashflowTableCell` and `CashflowTableSummaryValueCell` still highlight the selected column, keep existing click behavior, preserve current colors for `balance`/`final`/`none`, and still render progress bars or quality indicators only in their respective wrappers.

2. **Replace duplicated income/costs section components with a single preset-driven section**
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCategorySection.tsx`
   - Changes: Add one semantic section component driven by `kind: "income" | "costs"`; derive icon, icon color, translation key, trigger type, `TransactionDirection`, total field, and filter list from an internal preset/config map.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTable.tsx`
   - Changes: Render the new section twice with `kind="income"` and `kind="costs"` instead of importing two nearly identical section files.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableIncomeCategories.tsx`
   - Changes: Remove this duplicate file, or reduce it to a temporary wrapper if the refactor is split into smaller commits.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCostsCategories.tsx`
   - Changes: Remove this duplicate file, or reduce it to a temporary wrapper if the refactor is split into smaller commits.
   - Acceptance: The table still renders identical income/cost sections, totals stay mapped to `period.income`/`period.costs`, category rows use the correct `IN`/`OUT` direction, and expand/collapse behavior remains unchanged.

3. **Introduce low-level row/label shell primitives and rebuild summary/category components on top**
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowRowShell.tsx`
   - Changes: Add shared primitives for the common `TableRow` wrapper and label-cell styling, including the repeated background, right border, fixed label-column width, and optional bold/interactive variants.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowCategory.tsx`
   - Changes: Keep expansion context, trigger logic, icon wrapper, tooltip, and detail-opening behavior here, but rebuild header and row label components on top of the new low-level primitives instead of duplicating the shell styles.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummary.tsx`
   - Changes: Rebuild summary row/label components as thin compositions over the same low-level primitives.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/index.ts`
   - Changes: Export the new primitives if they are consumed outside their file.
   - Acceptance: Summary rows and category rows keep the same layout and widths, category labels still open detail views for the selected column, tooltips still work, and expansion-specific logic stays isolated to category components.

4. **Extract shared month/week calendar state orchestration into a headless hook**
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/useControlledCalendarPicker.ts`
   - Changes: Add a hook that reads `selectedDay`, `maxDateRangeFrom`, and `maxDateRangeTo` from `useTimePeriodControls()`, owns local `value`/`view` state, and exposes a generic `handleChange` that commits only when the current view matches a configurable terminal `commitView`.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/MonthPicker.tsx`
   - Changes: Replace duplicated local state/orchestration with the hook while keeping month-specific `StaticCalendar` props, `views`, `openTo`, and sizing styles.
   - File: `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/WeekPicker.tsx`
   - Changes: Replace duplicated local state/orchestration with the hook while preserving week-specific styles, day slot override, and `slotProps` for the custom week day component.
   - Acceptance: Month selection still commits on the month view, week selection still commits on the day view, min/max date limits remain enforced, and the custom week highlight rendering is unchanged.

5. **Run targeted regression checks for the refactor**
   - File: `provider-bw/libs/bw-react-cockpit/project.json`
   - Changes: No code changes expected; use the existing `lint`, `typecheck`, and `test` targets for validation.
   - Changes: Run `nx lint bw-react-cockpit`, `nx typecheck bw-react-cockpit`, and `nx test bw-react-cockpit`; then do a manual smoke test of the cashflow table (category expansion, category detail click, summary rows) and calendar popover (month/week selection).
   - Acceptance: All Nx checks pass and the manual smoke test confirms no behavior regressions in the table or pickers.

## Files to Modify
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCell.tsx` - turn into a thin amount/progress wrapper over the shared value-cell shell.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummaryValueCell.tsx` - turn into a thin summary wrapper over the shared value-cell shell.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTable.tsx` - switch to the new unified category section component.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableIncomeCategories.tsx` - remove or temporarily wrap the new unified section during migration.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCostsCategories.tsx` - remove or temporarily wrap the new unified section during migration.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowCategory.tsx` - compose category-specific pieces from shared row/label primitives.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummary.tsx` - compose summary pieces from shared row/label primitives.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/index.ts` - export new shared primitives/components.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/MonthPicker.tsx` - move shared state orchestration into the new hook.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/WeekPicker.tsx` - move shared state orchestration into the new hook.

## New Files (if any)
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableValueCell.tsx` - shared shell for clickable/highlighted value cells.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCategorySection.tsx` - preset-driven income/costs section component.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowRowShell.tsx` - shared low-level row and label-cell primitives.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/useControlledCalendarPicker.ts` - headless hook for calendar picker state orchestration.

## Dependencies
- Task 1 should land before or alongside any consumers that want to reuse the new value-cell shell.
- Task 3 should land before or alongside Task 2 if the unified category section consumes the refactored category/summary primitives.
- Task 4 is independent of the cashflow-table refactors.
- Task 5 depends on Tasks 1-4 being complete.

## Risks
- Removing `CashflowTableIncomeCategories.tsx` and `CashflowTableCostsCategories.tsx` is safe only if no external consumers import them outside `CashflowTable.tsx`; verify before deletion.
- The shared value-cell shell must preserve memoization and not widen re-render scope for column highlighting.
- The row-shell extraction must not accidentally move category-specific behavior (expansion state, detail-opening logic) into the shared primitive.
- The calendar hook must avoid committing too early when the user is still navigating between year/month/day views.
- Styling regressions are easy to miss here; do a visual smoke test for borders, widths, hover affordances, and selected-column highlighting.