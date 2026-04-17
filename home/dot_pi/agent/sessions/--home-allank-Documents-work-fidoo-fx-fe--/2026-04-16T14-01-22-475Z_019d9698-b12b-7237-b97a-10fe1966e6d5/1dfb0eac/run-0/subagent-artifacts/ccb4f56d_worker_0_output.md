## 1. Interface signature

A single cohesive family centered on one primitive:

```ts
type CashflowTableSectionVariant = "category" | "summary";

type CashflowTableSectionProps = {
  variant?: CashflowTableSectionVariant;

  // shared layout
  label: React.ReactNode;
  value?: React.ReactNode;
  secondaryValue?: React.ReactNode;

  // structure / behavior
  collapsible?: boolean;
  defaultOpen?: boolean;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;

  // first-column width consistency
  labelColumnWidth?: string | number; // defaults to cashflowLayoutConfig.labelColumnWidth

  // optional content
  icon?: React.ReactNode;
  actions?: React.ReactNode;
  children?: React.ReactNode;

  // interaction hooks
  onLabelClick?: () => void;
  onValueClick?: () => void;
  onRowClick?: () => void;

  // styling / composition
  className?: string;
};
```

Recommended component family:

```ts
export function CashflowTableSection(props: CashflowTableSectionProps) { ... }
```

Optional thin aliases for readability only:

```ts
export const CashflowTableCategorySection = CashflowTableSection;
export const CashflowTableSummaryRow = CashflowTableSection;
```

Internally, the component decides whether it renders:

- a collapsible category section
- a static summary row

based on `variant` + `collapsible`.

---

## 2. Usage example

### Collapsible income/costs section

```tsx
<CashflowTableSection
  variant="category"
  label="Income"
  icon={<IncomeIcon />}
  collapsible
  defaultOpen
  value={incomeTotal}
  onOpenChange={setIncomeOpen}
>
  {categories.map((category) => (
    <CashflowCategoryDataRow
      key={category.id}
      label={category.name}
      value={category.amount}
      onLabelClick={() => openCategory(category.id)}
      onValueClick={() => openCategoryDetails(category.id)}
    />
  ))}
</CashflowTableSection>
```

### Summary row like net balance

```tsx
<CashflowTableSection
  variant="summary"
  label="Net balance"
  value={netBalance}
  secondaryValue={netBalancePercentage}
  labelColumnWidth={cashflowLayoutConfig.labelColumnWidth}
/>
```

### Final balance row with custom action

```tsx
<CashflowTableSection
  variant="summary"
  label="Final balance"
  value={finalBalance}
  actions={<InfoTooltip />}
  onRowClick={showBalanceBreakdown}
/>
```

---

## 3. What this design hides internally

This interface hides the current split between:

- `CashflowTableCategorySection`
- `CashflowCategory`
- `CashflowCategoryHeader`
- `CashflowCategoryHeaderTitle`
- `CashflowCategoryHeaderIcon`
- `CashflowCategoryRow`
- `CashflowCategoryRowLabel`
- `CashflowCategoryTrigger`
- `CashflowCategoryRows`
- `CashflowCategoryDataRow`
- `CashflowTableSummary`
- `CashflowTableSummaryValueCell`

Internally, it can still preserve the existing `TableRow` / `TableCell` structure exactly:

- one root `TableRow`
- a fixed-width label cell
- value cells aligned to the current layout
- optional expand/collapse trigger
- optional action area
- optional nested rows in a body section

It also keeps the fixed first-column width centralized through one prop defaulting to `cashflowLayoutConfig.labelColumnWidth`.

---

## 4. Trade-offs of this approach

### Pros
- Smallest public surface area: one real component, one concept.
- Easy to read at call sites: `variant`, `label`, `value`, `children`.
- Supports both current patterns without forcing callers to learn separate APIs.
- Leaves room for future variants and custom actions.
- Preserves table layout and the fixed label column width.

### Cons
- Some semantics move from named components into props, which can reduce explicitness.
- The component will contain more branching internally.
- Very specialized behavior may still need small helper components internally.
- If the team prefers composition over configuration, this is slightly more “prop-driven” than the current low-level API.

### Why it fits the constraint
This keeps the surface intentionally small while still covering:
- collapsible sections
- summary rows
- detail-open interactions
- custom header actions
- consistent table layout

If you want, I can also propose a **second alternative interface** that is even more compositional, then compare the two.