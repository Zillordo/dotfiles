I’d collapse both into one data-driven public component, `CashflowTableCategorySection`, and make the current `income` / `costs` differences live in a preset spec.  
For future visual variants, keep the data/behavior in the spec and the look in `slots`-style overrides.

## Signature

```ts
type CashflowTableCategorySectionPreset = "income" | "costs";

export type CashflowTableCategorySectionSpec = {
  id: string;
  label: ReactNode;
  icon?: ReactNode;
  iconSx?: SxProps<Theme>;
  direction: TransactionDirection;

  defaultExpanded?: boolean;
  summaryColorMode?: "none" | "balance" | "final";

  ariaLabels: {
    expand: string;
    collapse: string;
  };

  getSummaryValue: (period: CashflowPeriod) => number | null;
  getVisibleCategories: (ctx: CashflowTableContextValue) => CategoryType[];
  getCategoryValue: (period: CashflowPeriod, category: CategoryType) => number;
};

type CashflowTableCategorySectionSlots = Partial<{
  headerIcon: React.ComponentType<{ children: ReactNode; sx?: SxProps<Theme> }>;
  trigger: React.ComponentType<{
    isExpanded: boolean;
    onToggle: () => void;
    ariaLabel: string;
  }>;
  summaryValueCell: React.ComponentType<CashflowTableSummaryValueCellProps>;
  rowLabel: React.ComponentType<{
    category: CategoryType;
    direction: TransactionDirection;
    onClick: () => void;
    children: ReactNode;
  }>;
}>;

export type CashflowTableCategorySectionProps = {
  section: CashflowTableCategorySectionPreset | CashflowTableCategorySectionSpec;
  slots?: CashflowTableCategorySectionSlots;
};

export function CashflowTableCategorySection(
  props: CashflowTableCategorySectionProps,
): JSX.Element;
```

## Usage example

### Current callers
```tsx
<TableBody>
  <CashflowTableCategorySection section="income" />
</TableBody>

<TableBody>
  <CashflowTableCategorySection section="costs" />
</TableBody>
```

### Future visual variant
```tsx
<CashflowTableCategorySection
  section={{
    id: "income",
    label: tt("cashflowTable.rows.income"),
    icon: <IconArrowUpRight />,
    iconSx: { color: "success.main" },
    direction: "IN",
    defaultExpanded: true,
    summaryColorMode: "none",
    ariaLabels: {
      expand: tt("cashflowTable.accessibility.expandIncome"),
      collapse: tt("cashflowTable.accessibility.collapseIncome"),
    },
    getSummaryValue: (period) => period.income,
    getVisibleCategories: ({ categoryFilter }) => categoryFilter.income,
    getCategoryValue: (period, category) => period.incomeCategories.get(category) ?? 0,
  }}
  slots={{
    summaryValueCell: DenseSummaryValueCell,
  }}
/>
```

If you need backward compatibility, keep the old names as thin wrappers:

```ts
export const CashflowTableIncomeCategories = () => (
  <CashflowTableCategorySection section="income" />
);
export const CashflowTableCostsCategories = () => (
  <CashflowTableCategorySection section="costs" />
);
```

## Hidden internals

- A private `SECTION_PRESETS` map holds the current `income` and `costs` defaults.
- `section="income"` / `section="costs"` gets normalized into one resolved spec object.
- The render path stays generic:
  - `CashflowCategory` handles expand/collapse state
  - `CashflowCategoryHeader` renders the header row
  - `CashflowTableSummaryValueCell` renders period totals
  - `CashflowCategoryDataRow`-style logic renders category rows
- The trigger text should stop branching on `"income" | "costs"` directly; instead it consumes `ariaLabels` from the resolved spec.
- Existing click/open-detail behavior stays internal, so callers don’t have to know about `useOpenCategoryDetail`.
- If you keep the old component names, they become one-line adapters.

## Trade-offs

**Pros**
- One public component instead of two almost-identical ones.
- Current callers stay simple.
- Future variants can change labels, icons, colors, trigger copy, and even cell rendering without adding new siblings.
- The interface is deep: callers see a small surface, while the implementation hides the table mechanics.

**Cons**
- More abstraction than two concrete components.
- Slightly more type complexity because of the spec + slots model.
- Slot APIs can become a mini-framework if you add too many escape hatches.
- If a future variant needs a totally different table body layout, you may eventually need a `body` slot or render prop.

## Bottom line

This is the shape I’d ship:  
**one public component, preset-driven for today, slot-driven for future visual variants.**  
It keeps the common path tiny while leaving enough room to evolve without multiplying components.