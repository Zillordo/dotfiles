# Cashflow table section interface design

## Recommended approach
Use a **compound component family** built around a neutral concept: a **group** with a shared **row** primitive.

That gives one public vocabulary for both current shapes:
- collapsible income/costs blocks
- non-collapsible summary rows

It also avoids replacing the current duplication with one huge prop-driven component.

---

## 1. Interface signature (types/methods)

```ts
import type { ReactNode, Key, FC } from "react";

export type CashflowRowTone = "default" | "summary";
export type CashflowRowWeight = "regular" | "bold";

export type CashflowCellSpec = {
  key: Key;
  columnIndex: number;
  dateFrom: string;

  /** Common case: numeric amount rendered by the family */
  value?: number | null;
  currency?: string;
  colorMode?: CashflowTableValueColorMode;
  balanceQuality?: BalanceQuality | null;
  weight?: CashflowRowWeight;
  onClick?: () => void;

  /** Escape hatch for custom rendering, e.g. final balance cell with quality indicator */
  render?: (ctx: {
    columnIndex: number;
    dateFrom: string;
  }) => ReactNode;
};

export type CashflowRowProps = {
  label: ReactNode;
  labelTooltip?: ReactNode;
  labelIcon?: ReactNode;
  labelIndent?: number;
  tone?: CashflowRowTone;
  weight?: CashflowRowWeight;
  actions?: ReactNode;

  /** Optional row-label interaction, e.g. open category detail */
  onLabelClick?: () => void;
  labelAriaLabel?: string;

  cells: CashflowCellSpec[];
};

export type CashflowGroupProps = {
  children: ReactNode;

  /** Optional override; defaults to cashflowLayoutConfig.labelColumnWidth */
  labelWidth?: number;

  /** For section-like groups only */
  collapsible?: boolean;
  defaultExpanded?: boolean;
  expanded?: boolean;
  onExpandedChange?: (expanded: boolean) => void;
};

export type CashflowGroupHeaderProps = Omit<CashflowRowProps, "tone"> & {
  /** Shows the expand/collapse affordance when parent group is collapsible */
  showToggle?: boolean;
};

export type CashflowGroupBodyProps = {
  children: ReactNode;
  keepMounted?: boolean;
};

export type CashflowToggleProps = {
  ariaLabel?: string;
};

export type CashflowTableGroupFamily = FC<CashflowGroupProps> & {
  Header: FC<CashflowGroupHeaderProps>;
  Body: FC<CashflowGroupBodyProps>;
  Row: FC<CashflowRowProps>;
  Toggle: FC<CashflowToggleProps>;
};

export declare const CashflowTableGroup: CashflowTableGroupFamily;
```

### Design notes
- `CashflowTableGroup.Row` is the shared primitive for:
  - category rows
  - summary rows
  - any future static total rows
- `CashflowTableGroup.Header` is just a specialized row with optional icon/toggle/actions.
- `CashflowTableGroup` owns expansion state only when a block needs it.
- Fixed first-column width stays centralized inside the family and defaults to `cashflowLayoutConfig.labelColumnWidth`.

---

## 2. Usage example (how caller uses it)

### Collapsible income section

```tsx
<CashflowTableGroup collapsible defaultExpanded>
  <CashflowTableGroup.Header
    label={tt("cashflowTable.rows.income")}
    labelIcon={<IconArrowUpRight />}
    weight="bold"
    showToggle
    actions={<CashflowTableGroup.Toggle />}
    cells={data.periods.map((period, columnIndex) => ({
      key: period.id,
      columnIndex,
      dateFrom: period.dateFrom,
      value: period.income,
      currency,
      weight: "bold",
    }))}
  />

  <CashflowTableGroup.Body>
    {categoryFilter.income.map((category) => (
      <CashflowTableGroup.Row
        key={category}
        label={getCategoryLabel(category, allCategories)}
        labelIndent={4}
        onLabelClick={() => openCategoryDetail({
          category,
          direction: "IN",
          selectedColumn,
        })}
        cells={data.periods.map((period, columnIndex) => ({
          key: `${category}-${period.id}`,
          columnIndex,
          dateFrom: period.dateFrom,
          value: period.incomeCategories.get(category) ?? 0,
          onClick: () =>
            openCategoryDetail({
              category,
              direction: "IN",
              columnIndex,
            }),
        }))}
      />
    ))}
  </CashflowTableGroup.Body>
</CashflowTableGroup>
```

### Collapsible costs section with custom header action

```tsx
<CashflowTableGroup collapsible defaultExpanded>
  <CashflowTableGroup.Header
    label={tt("cashflowTable.rows.costs")}
    labelIcon={<IconArrowDownRight />}
    weight="bold"
    showToggle
    actions={
      <>
        <CategoryFilterButton />
        <CashflowTableGroup.Toggle />
      </>
    }
    cells={data.periods.map((period, columnIndex) => ({
      key: period.id,
      columnIndex,
      dateFrom: period.dateFrom,
      value: period.costs,
      currency,
      weight: "bold",
    }))}
  />

  <CashflowTableGroup.Body>
    {categoryFilter.costs.map((category) => (
      <CashflowTableGroup.Row
        key={category}
        label={getCategoryLabel(category, allCategories)}
        labelIndent={4}
        onLabelClick={() => openCategoryDetail({ category, direction: "OUT" })}
        cells={data.periods.map((period, columnIndex) => ({
          key: `${category}-${period.id}`,
          columnIndex,
          dateFrom: period.dateFrom,
          value: period.costsCategories.get(category) ?? 0,
          onClick: () =>
            openCategoryDetail({
              category,
              direction: "OUT",
              columnIndex,
            }),
        }))}
      />
    ))}
  </CashflowTableGroup.Body>
</CashflowTableGroup>
```

### Summary rows

```tsx
<CashflowTableGroup.Row
  label={tt("cashflowTable.rows.netBalance")}
  tone="summary"
  weight="bold"
  cells={data.periods.map((period, columnIndex) => ({
    key: period.id,
    columnIndex,
    dateFrom: period.dateFrom,
    value: period.netBalance,
    currency,
    colorMode: "balance",
    weight: "bold",
  }))}
/>

<CashflowTableGroup.Row
  label={tt("cashflowTable.rows.finalBalance")}
  tone="summary"
  weight="bold"
  cells={data.periods.map((period, columnIndex) => ({
    key: period.id,
    columnIndex,
    dateFrom: period.dateFrom,
    render: () => (
      <CashflowTableSummaryValueCell
        value={period.finalBalance?.value ?? null}
        balanceQuality={period.finalBalance?.balanceQuality ?? null}
        currency={currency}
        columnIndex={columnIndex}
        dateFrom={period.dateFrom}
        isBold
        colorMode="final"
      />
    ),
  }))}
/>
```

### Why this caller API reads well
- section-like things use `CashflowTableGroup`
- actual rows always use `CashflowTableGroup.Row`
- the distinction between category and summary moves from naming into data/behavior
- common optional behaviors stay obvious: `showToggle`, `actions`, `onLabelClick`, cell `onClick`, custom `render`

---

## 3. What this design hides internally

This design keeps the public API small while absorbing the current split across:
- `CashflowTableCategorySection.tsx`
- `components/CashflowCategory.tsx`
- `components/CashflowCategoryDataRow.tsx`
- `components/CashflowTableSummary.tsx`
- `components/CashflowTableSummaryValueCell.tsx`
- the summary row wrappers (`CashflowTableNetBalanceRow.tsx`, `CashflowTableFinalBalanceRow.tsx`)

### Hidden internally
1. **TableRow/TableCell wiring**
   - The family still renders the same table structure.
   - Callers do not manage `TableRow`, label-cell borders, or per-cell alignment.

2. **Fixed first-column width**
   - One internal label-cell implementation applies `cashflowLayoutConfig.labelColumnWidth` consistently.
   - No duplicate width logic across category and summary components.

3. **Collapse state and accessibility**
   - Controlled/uncontrolled expansion logic.
   - Rotation of the chevron.
   - `aria-expanded` and localized expand/collapse labels.

4. **Shared label-cell behavior**
   - summary label styling
   - category label indentation
   - tooltip/ellipsis behavior
   - optional click-to-open detail

5. **Shared value-cell behavior**
   - selected-column highlighting
   - default column click behavior
   - color modes
   - compact currency formatting
   - final-balance quality indicator handling

6. **Header composition**
   - icon + label + optional actions + optional toggle all live in one internal header-row implementation.

7. **Future row variants**
   - Any new static row, subtotal row, or action row can reuse `Row` without introducing another parallel naming tree.

---

## 4. Trade-offs of this approach

### Advantages
- **Reduces duplicated naming cleanly**
  - category and summary stop being separate public families
  - neutral terms (`Group`, `Header`, `Row`) map better to the actual table structure

- **High flexibility without a prop soup**
  - sections can be collapsible
  - rows can be static or interactive
  - cells can use default numeric rendering or custom rendering
  - custom header actions fit naturally

- **Keeps the caller meaningful**
  - `Group + Header + Body + Row` is easier to scan than many specialized components
  - common use cases remain explicit

- **Preserves current layout constraints**
  - fixed first-column width stays centralized
  - table semantics stay intact

- **Gives a straightforward migration path**
  - current specialized components can become thin wrappers around the new family during migration

### Costs / risks
- **Slightly more abstract than today’s dedicated names**
  - `Row tone="summary"` is more generic than `CashflowTableFinalBalanceRow`
  - thin wrappers may still be worth keeping for especially important rows

- **Cell specs can get verbose**
  - mapping `periods` into `cells` is flexible, but somewhat noisy
  - helper builders may be useful later if repetition grows

- **Header/body composition requires discipline**
  - the family should own layout rules so callers do not rebuild inconsistent header structures

- **The escape hatch must stay rare**
  - `render` is necessary for cases like final-balance quality UI
  - if overused, the API becomes harder to reason about

### Why this is the best fit here
Compared with the other obvious options:
- a **single giant component with variants** is smaller on paper, but becomes branch-heavy and harder to extend cleanly
- a **common-case-only opinionated API** is readable, but less capable when new row/header behaviors appear

This compound family is the best middle ground for your stated constraint: **maximize flexibility while keeping the caller API meaningful and reducing duplicated naming**.
