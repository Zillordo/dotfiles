Here’s a flexible component-family design that unifies the current category, data-row, and summary-row APIs while keeping the table structure intact.

---

## 1. Interface signature (types/methods)

### Core idea
Introduce one cohesive family centered around a single table row primitive plus composable “slots” for:
- fixed first-column label
- optional collapsible header
- optional action area
- body rows
- per-cell rendering
- click-to-open behavior

### Proposed API

```ts
type CashflowSectionKind = "category" | "summary";

type CashflowSectionRowBaseProps = {
  kind: CashflowSectionKind;
  label: ReactNode;
  labelTooltip?: ReactNode;
  labelWidth?: number; // defaults to cashflowLayoutConfig.labelColumnWidth
  isHeader?: boolean;
  isExpanded?: boolean; // only relevant for collapsible sections
  onToggleExpanded?: () => void;
  headerIcon?: ReactNode;
  headerActions?: ReactNode;
  rowActions?: ReactNode;
};

type CashflowSectionCellRenderContext = {
  period: CashflowPeriod;
  columnIndex: number;
  dateFrom: string;
};

type CashflowSectionCellProps = {
  children?: ReactNode;
  value?: number | null;
  currency?: string;
  colorMode?: CashflowTableValueColorMode;
  isBold?: boolean;
  balanceQuality?: BalanceQuality | null;
  onClick?: () => void;
  render?: (ctx: CashflowSectionCellRenderContext) => ReactNode;
};

type CashflowSectionRowProps = CashflowSectionRowBaseProps & {
  cells: Array<CashflowSectionCellProps>;
};

type CashflowSectionProps = {
  children: ReactNode;
};

type CashflowSectionHeaderProps = {
  label: ReactNode;
  icon?: ReactNode;
  actions?: ReactNode;
  collapsible?: boolean;
  expanded?: boolean;
  onToggleExpanded?: () => void;
};

type CashflowSectionBodyProps = {
  children: ReactNode;
  visible?: boolean;
};

type CashflowSectionLabelCellProps = {
  children: ReactNode;
  tooltip?: ReactNode;
  width?: number;
  clickable?: boolean;
  onClick?: () => void;
};

type CashflowSectionValueCellProps = {
  value: number | null;
  currency?: string;
  columnIndex: number;
  dateFrom: string;
  isBold?: boolean;
  colorMode?: CashflowTableValueColorMode;
  balanceQuality?: BalanceQuality | null;
  onClick?: () => void;
};

type CashflowSectionComponents = {
  Root: (props: CashflowSectionProps) => JSX.Element;
  Header: (props: CashflowSectionHeaderProps) => JSX.Element;
  Body: (props: CashflowSectionBodyProps) => JSX.Element;
  Row: (props: CashflowSectionRowProps) => JSX.Element;
  LabelCell: (props: CashflowSectionLabelCellProps) => JSX.Element;
  ValueCell: (props: CashflowSectionValueCellProps) => JSX.Element;
};
```

### Suggested exported family
```ts
export const CashflowSection: CashflowSectionComponents;
```

### Convenience presets/builders
To keep caller code readable, add thin specialized wrappers:

```ts
type CashflowCategorySectionProps = {
  variant: "income" | "costs";
  renderHeaderActions?: ReactNode;
  renderRowActions?: (category: CategoryType) => ReactNode;
  onCategoryCellClick?: (args: {
    category: CategoryType;
    periodIndex: number;
  }) => void;
};

type CashflowSummarySectionProps = {
  label: ReactNode;
  rows: Array<{
    key: string;
    cells: Array<CashflowSectionCellProps>;
  }>;
};
```

---

## 2. Usage example (how caller uses it)

### A. Collapsible income/costs section
```tsx
<CashflowSection.Root>
  <CashflowSection.Header
    label={tt("cashflowTable.rows.income")}
    icon={<IconArrowUpRight />}
    collapsible
    expanded={isExpanded}
    onToggleExpanded={toggleExpanded}
    actions={<CustomHeaderAction />}
  />

  <CashflowSection.Body visible={isExpanded}>
    {categories.map((category) => (
      <CashflowSection.Row
        key={category}
        kind="category"
        label={getCategoryLabel(category, allCategories)}
        rowActions={<CustomRowAction category={category} />}
        cells={data.periods.map((period, columnIndex) => ({
          value: period.incomeCategories.get(category) ?? 0,
          columnIndex,
          dateFrom: period.dateFrom,
          colorMode: "none",
          onClick: () => openDetail(category, columnIndex),
        }))}
      />
    ))}
  </CashflowSection.Body>
</CashflowSection.Root>
```

### B. Summary row
```tsx
<CashflowSection.Row
  kind="summary"
  label={tt("cashflowTable.rows.netBalance")}
  cells={data.periods.map((period, columnIndex) => ({
    value: period.netBalance,
    columnIndex,
    dateFrom: period.dateFrom,
    isBold: true,
    colorMode: "balance",
  }))}
/>
```

### C. Final balance with custom value rendering
```tsx
<CashflowSection.Row
  kind="summary"
  label={tt("cashflowTable.rows.finalBalance")}
  cells={data.periods.map((period, columnIndex) => ({
    columnIndex,
    dateFrom: period.dateFrom,
    render: ({ period }) => (
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

---

## 3. What this design hides internally

This API can hide the current duplication and implementation details behind a single family:

- **Fixed label column width logic**
  - always uses `cashflowLayoutConfig.labelColumnWidth`
  - callers can override only if truly needed, but default stays consistent

- **Table structure**
  - still renders `TableRow` / `TableCell`
  - callers never need to know which pieces are row shells vs cells

- **Collapsible behavior**
  - `Root` or `Header` can own expanded state
  - toggle icon, aria labels, and body visibility are internal

- **Click-to-open detail behavior**
  - category label and/or value cells can be clickable
  - opening the detail drawer/dialog can be injected via row/cell handlers
  - no need for separate `CashflowCategoryRowLabel` vs `CashflowCategoryDataRow` coupling

- **Value rendering differences**
  - summary value formatting, balance quality indicator, compact currency display, etc. can be selected by cell renderer or preset

- **Specialized variants**
  - income/costs headers, summary rows, and future variants become configuration rather than separate component families

- **Naming duplication**
  - “category” and “summary” stop being separate parallel component trees
  - instead they become variants of the same row/cell model

---

## 4. Trade-offs of this approach

### Pros
- **Much less naming duplication**
  - one family for category and summary use cases
- **Highly flexible**
  - easy to add custom header actions, row actions, clickable cells, alternate renderers
- **Preserves layout**
  - still TableRow/TableCell-based and keeps the fixed first column
- **Future-friendly**
  - can support more row variants without more top-level components
- **Caller API stays readable**
  - the semantics are explicit: Header, Body, Row, LabelCell, ValueCell

### Cons
- **More abstract**
  - callers may need to learn a more generic model
- **Can be overkill for simple rows**
  - a dedicated `NetBalanceRow` wrapper is simpler at call sites
- **More prop combinations**
  - generic components can accumulate optional behavior complexity
- **Risk of leaky flexibility**
  - if not constrained, callers may build inconsistent row patterns
- **Migration work**
  - existing components would likely need to be refactored in stages into wrappers around the new family

### Practical recommendation
Use this as a **primitive + presets** architecture:

- **Primitive**
  - `CashflowSection.Root / Header / Body / Row / LabelCell / ValueCell`
- **Presets**
  - `CashflowIncomeSection`
  - `CashflowCostsSection`
  - `CashflowSummaryRow`
  - `CashflowBalanceRow`

That gives you maximum flexibility without forcing every caller to assemble everything manually.

If you want, I can also design:
1. a **more opinionated API**,
2. a **slot-based compound component API**, or
3. a **migration map** from the current files to the new family.