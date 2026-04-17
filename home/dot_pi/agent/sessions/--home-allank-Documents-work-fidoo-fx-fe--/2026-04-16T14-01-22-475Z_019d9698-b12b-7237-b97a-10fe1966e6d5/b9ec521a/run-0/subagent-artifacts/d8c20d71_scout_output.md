# Code Context

## Files Retrieved
1. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTable.tsx` (lines 1-55) - Top-level table composition and current call sites.
2. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCategorySection.tsx` (lines 1-88) - Current consolidated income/costs category section API (`variant`-based).
3. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableIncomeCategories.tsx` (lines 1-66) - Legacy/parallel dedicated income call-site shape.
4. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableCostsCategories.tsx` (lines 1-66) - Legacy/parallel dedicated costs call-site shape.
5. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableNetBalanceRow.tsx` (lines 1-29) - Net balance row component and value-cell usage.
6. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTableFinalBalanceRow.tsx` (lines 1-31) - Final balance row component and summary-value-cell usage.
7. `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/types/cashflow-table.types.ts` (lines 1-105) - Core data model (`CashflowPeriod`, `CashflowTableCellProps`) and naming constraints.

## Key Code

### 1) Primary call sites in current composition
`CashflowTable` now renders category sections by `variant`, then two summary rows:

```tsx
// provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTable.tsx
<TableBody>
  <CashflowTableCategorySection variant="income" />
</TableBody>
<TableBody>
  <CashflowTableCategorySection variant="costs" />
</TableBody>

<TableBody>
  <CashflowTableNetBalanceRow />
  <CashflowTableFinalBalanceRow />
</TableBody>
```

This corresponds to the four primary functional call sites the task asks about:
- income categories (via `variant="income"`)
- costs categories (via `variant="costs"`)
- net balance row (`CashflowTableNetBalanceRow`)
- final balance row (`CashflowTableFinalBalanceRow`)

### 2) Category section prop shape (income + costs)

```ts
// CashflowTableCategorySection.tsx
type CashflowTableCategorySectionProps = {
  variant: "income" | "costs";
};
```

Behavior is configured by `sectionPresets[variant]`:
- title translation key
- icon + icon color
- `categoryType` for trigger (`"income" | "costs"`)
- row `direction` (`"IN" | "OUT"`)
- period total selector (`period.income` / `period.costs`)
- filtered categories selector (`categoryFilter.income` / `categoryFilter.costs`)

### 3) Net balance row prop/input shape
No external props; reads table context (`data`) internally:

```tsx
// CashflowTableNetBalanceRow.tsx
<CashflowTableCell
  value={period.netBalance}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="balance"
/>
```

Effective cell prop shape comes from `CashflowTableCellProps`:

```ts
{
  value: number;
  columnIndex: number;
  dateFrom: string;
  isBold?: boolean;
  progressPercentage?: number;
  colorMode?: "balance" | "final" | "none";
  onClick?: () => void;
}
```

### 4) Final balance row prop/input shape
No external props; reads (`data`, `currency`) internally:

```tsx
// CashflowTableFinalBalanceRow.tsx
<CashflowTableSummaryValueCell
  value={period.finalBalance?.value ?? null}
  balanceQuality={period.finalBalance?.balanceQuality ?? null}
  currency={currency}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold={true}
  colorMode="final"
/>
```

Notable differences from net balance row:
- uses `CashflowTableSummaryValueCell` (not `CashflowTableCell`)
- accepts nullable value (`number | null`) and `balanceQuality`
- includes `currency`

### 5) Duplicated naming / API duplication found
There are two overlapping category APIs:
1. **Current in-use generic**: `CashflowTableCategorySection variant="income"|"costs"`
2. **Older specialized components still present**:
   - `CashflowTableIncomeCategories`
   - `CashflowTableCostsCategories`

The specialized components duplicate almost identical structure and differ only in:
- label key
- icon/color
- total field (`income` vs `costs`)
- filter key (`categoryFilter.income` vs `.costs`)
- direction (`IN` vs `OUT`)

Also naming is slightly inconsistent:
- Some files call total cells `CashflowTableSummaryValueCell`
- Generic category section uses `CashflowTableValueCell`
- Net row uses `CashflowTableCell`

So there is conceptual duplication around “value cell” component naming.

## Architecture
- `CashflowTable` is the composition root.
- `useCashflowTable()` provides shared context (`data`, `currency`, category filters, etc.).
- Category rendering has been consolidated into `CashflowTableCategorySection` with a `variant` discriminator and preset mapping.
- Summary rows (`NetBalance`, `FinalBalance`) are separate leaf components, both iterating over `data.periods`.
- Data contract originates from `CashflowPeriod` in `types/cashflow-table.types.ts`.

## Start Here
Start with `provider-bw/libs/bw-react-cockpit/src/lib/cashflow-table/CashflowTable.tsx` because it shows the **actual active call sites** and immediately reveals the intended public composition API.

---

## Proposed common-case interface (concise + render-preserving)

Given current usage, the most common-case interface is:

```tsx
<CashflowTableCategorySection variant="income" />
<CashflowTableCategorySection variant="costs" />
<CashflowTableSummaryRow variant="net" />
<CashflowTableSummaryRow variant="final" />
```

Suggested prop contracts:

```ts
type CategorySectionVariant = "income" | "costs";
type SummaryRowVariant = "net" | "final";

type CashflowTableCategorySectionProps = {
  variant: CategorySectionVariant;
};

type CashflowTableSummaryRowProps = {
  variant: SummaryRowVariant;
};
```

Why this is the best common-case:
- Matches current concise call site style (`variant`-driven, no extra props).
- Keeps rendering behavior unchanged (all data still sourced from `useCashflowTable`).
- Removes duplicated component names (`IncomeCategories`/`CostsCategories`, `NetBalanceRow`/`FinalBalanceRow`) behind two predictable primitives.
- Preserves extensibility (add future variants like `opening`/`forecast` without new component files).

If preserving existing exports is important, keep wrappers:
- `CashflowTableIncomeCategories => <CashflowTableCategorySection variant="income" />`
- `CashflowTableCostsCategories => <CashflowTableCategorySection variant="costs" />`
- `CashflowTableNetBalanceRow => <CashflowTableSummaryRow variant="net" />`
- `CashflowTableFinalBalanceRow => <CashflowTableSummaryRow variant="final" />`

This provides backward compatibility while converging on one common-case API.