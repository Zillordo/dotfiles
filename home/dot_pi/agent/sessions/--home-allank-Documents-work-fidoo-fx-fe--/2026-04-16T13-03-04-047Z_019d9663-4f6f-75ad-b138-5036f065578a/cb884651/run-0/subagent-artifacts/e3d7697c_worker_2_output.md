I’d merge them into one **minimal discriminated component** and keep the existing two names as thin wrappers if you need compatibility.

## Signature

```tsx
export type CashflowTableCategorySectionKind = "income" | "costs";

export type CashflowTableCategorySectionProps = {
  section: CashflowTableCategorySectionKind;
};

export function CashflowTableCategorySection(
  props: CashflowTableCategorySectionProps,
): JSX.Element;
```

If you want to preserve today’s callers with zero churn:

```tsx
export const CashflowTableIncomeCategories = () => (
  <CashflowTableCategorySection section="income" />
);

export const CashflowTableCostsCategories = () => (
  <CashflowTableCategorySection section="costs" />
);
```

## Usage example

### Preferred merged usage
```tsx
<TableBody>
  <CashflowTableCategorySection section="income" />
  <CashflowTableCategorySection section="costs" />
</TableBody>
```

### Backward-compatible usage
```tsx
<TableBody>
  <CashflowTableIncomeCategories />
</TableBody>
<TableBody>
  <CashflowTableCostsCategories />
</TableBody>
```

## Hidden internals

Internally, the component should use one small lookup table keyed by `section`:

- `titleKey`
  - `income` → `cashflowTable.rows.income`
  - `costs` → `cashflowTable.rows.costs`
- `icon`
  - `income` → up-right arrow
  - `costs` → down-right arrow
- `iconColor`
  - `income` → `success.main`
  - `costs` → `error.main`
- `periodTotalField`
  - `income` → `period.income`
  - `costs` → `period.costs`
- `categoryList`
  - `income` → `categoryFilter.income`
  - `costs` → `categoryFilter.costs`
- `rowDirection`
  - `income` → `"IN"`
  - `costs` → `"OUT"`

The component itself still reads from `useCashflowTable()` and `useTT()`, renders the same `CashflowCategory` / `CashflowCategoryHeader` / `CashflowCategoryRows` structure, and passes the selected section metadata through to:

- `CashflowCategoryTrigger`
- `CashflowTableSummaryValueCell`
- `CashflowCategoryDataRow`

## Trade-offs

### Pros
- Very small API: one prop, one discriminant.
- Matches the current real-world call sites almost perfectly.
- Removes duplicate JSX and duplicated per-section wiring.
- Keeps the section-specific behavior in one internal config map, so future edits are less error-prone.

### Cons
- Less flexible than a fully configurable component.
- Hard-codes the current two-section model (`income` / `costs`).
- If a third section appears later, you’ll need to extend the internal config or rethink the API.
- Slightly more abstract than the current explicit two-component naming.

### Why this is the conservative choice
This design optimizes for the **common case we already have**: exactly two sections, always rendered the same way, with only the semantic differences hidden behind the section kind. It minimizes props while still keeping the code understandable.

If you want, I can also sketch the exact TypeScript implementation for this merged component.