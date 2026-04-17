# Task for planner

[Read from: /tmp/pi-subagents-uid-1000/chain-runs/35af6e7e/context.md]
[Write to: /tmp/pi-subagents-uid-1000/chain-runs/35af6e7e/plan.md]

plan refactors with the recommended interface in the cockpit module

---
Previous step output:
# Code Context

## Relevant Files

### Duplication 1: clickable/highlighted value cells
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCell.tsx`
  - Owns shared cell shell concerns: selected-column highlighting, default `setPeriod(dayjs(dateFrom))` click behavior, common `TableCell` borders/background, bold styling, and value color calculation.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummaryValueCell.tsx`
  - Repeats the same shell concerns, but differs in cell content: nullable values, `CurrencyAmount`, and `CashflowQualityIndicator`.
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/types/cashflow-table.types.ts:74`
  - Existing `CashflowTableCellProps` already captures shared concerns (`value`, `columnIndex`, `dateFrom`, `isBold`, `colorMode`, `onClick`, `progressPercentage`).

**Recommended interface**
- Introduce a single shared shell component, e.g. `CashflowTableValueCell`, with a small API:
  - shared props: `columnIndex`, `dateFrom`, `isBold?`, `colorMode?`, `onClick?`
  - content as `children`
- Keep specialized content in thin wrappers:
  - amount/progress variant renders `formatCashflowAmount(...)` and optional `LinearProgress`
  - summary variant renders nullable `CurrencyAmount` plus optional `CashflowQualityIndicator`

**Why this interface**
- Best “minimal API” design from interface exploration.
- Deduplicates interaction and styling without coupling the wrapper to rendering details.
- Matches the current code split: both files are mostly the same outer shell, but semantically different inner content.

---

### Duplication 2: income/costs category sections
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCostsCategories.tsx`
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableIncomeCategories.tsx`

Both components share the same structure:
- `CashflowCategory`
- `CashflowCategoryHeader`
- `CashflowCategoryHeaderTitle`
- section icon + translated label + `CashflowCategoryTrigger`
- map periods to `CashflowTableSummaryValueCell`
- map filtered categories to `CashflowCategoryDataRow`

Differences are all configuration:
- title key
- icon/color
- `categoryType`
- total field (`period.income` vs `period.costs`)
- filter list (`categoryFilter.income` vs `.costs`)
- direction (`IN` vs `OUT`)

**Recommended interface**
- Introduce one semantic section component driven by a discriminated config:
  - `kind: "income" | "costs"`
  - caller passes the minimal varying data, while internals derive icon, colors, trigger type, direction, and which period total/filter list to use.
- Optionally back it with an internal preset map, e.g. `sectionPresets[kind]`.

**Why this interface**
- Best “optimize for common case” design.
- Call sites stay terse and domain-oriented.
- Avoids repeating the same JSX skeleton while keeping future divergence manageable via preset-based internals.

---

### Duplication 3: row/label shell primitives
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowCategory.tsx`
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/components/CashflowTableSummary.tsx`

Shared duplication:
- `TableRow` wrapper primitives
- label-cell styling with:
  - `backgroundColor: "background.paper"`
  - right border using `custom.borderSecondary`
  - `cashflowLayoutConfig.labelColumnWidth`
  - `boxSizing: "border-box"`
  - bold summary/header label presentation

Category-specific additions in `CashflowCategory.tsx`:
- expansion context/provider
- toggle trigger
- icon support
- clickable category row label opening detail view
- conditional row rendering when expanded

**Recommended interface**
- Split into two layers:
  1. low-level shared primitive, e.g. `CashflowRowShell` / `CashflowLabelCell`
  2. category-specific composition on top, e.g. `CashflowCategoryRow` / `CashflowCategorySection`
- Keep expansion and detail-opening behavior out of the shared primitive.

**Why this interface**
- Best “maximize flexibility” design.
- Captures the true shared abstraction: row and label-shell layout.
- Prevents category-specific concerns from leaking into summary-row primitives.
- Creates a reusable base for future subtotal/group/header rows.

---

### Duplication 4: month/week picker calendar state orchestration
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/MonthPicker.tsx`
- `provider-bw/libs/bw-react-cockpit/src/lib/cashflowFilterControls/WeekPicker.tsx`

Shared logic:
- read `selectedDay`, `maxDateRangeFrom`, `maxDateRangeTo` from `useTimePeriodControls()`
- local `value` state initialized from `selectedDay`
- local `view` state
- render `StaticCalendar` with min/max range props
- change handler updates local state and commits only when the picker is at its terminal view

Differences:
- terminal view (`month` vs `day`)
- `views` and `openTo`
- layout/sizing styles
- week mode custom `day` slot and slot props

**Recommended interface**
- Extract a headless hook, e.g. `useControlledCalendarPicker`:
  - owns `value`, `view`, range props, and generic `handleChange`
  - accepts mode/config such as `views`, `openTo`, `commitView`, optional slot overrides
- Keep `MonthPicker` and `WeekPicker` as thin renderers over `StaticCalendar`.

**Why this interface**
- Best “headless hook + thin view” design.
- Deduplicates state orchestration while preserving picker-specific rendering and slots.
- Avoids a monolithic picker component with many mode conditionals.

## Patterns Found
- Existing code favors small React function components and composition over inheritance.
- Shared behavior is already abstracted via hooks/contexts:
  - `useIsColumnSelected`
  - `useTimePeriodControls`
  - `useSelectedColumn`
  - `createCheckedContext`
- Cashflow table code already separates shell/layout from domain rows through component primitives in `components/index.ts`.
- The best-fitting refactors are therefore:
  - shared shell component for duplicated cell chrome
  - preset/config-driven section component for income/costs
  - low-level row primitive plus higher-level category composition
  - headless hook for calendar orchestration

## Dependencies
- React (`memo`, hooks, composition)
- MUI (`TableCell`, `TableRow`, `Box`, `IconButton`, `Tooltip`, date pickers)
- `dayjs`
- `@dfp/react-currency-amount`
- `@dfp/react-icons`
- project hooks/contexts under `cashflow-table` and `cashflowFilterControls`