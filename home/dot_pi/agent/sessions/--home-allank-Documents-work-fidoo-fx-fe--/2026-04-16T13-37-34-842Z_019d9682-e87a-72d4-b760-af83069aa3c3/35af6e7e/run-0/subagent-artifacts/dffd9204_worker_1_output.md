1. **Interface signature**

```ts
type CashflowCategorySectionProps = {
  titleKey: string;
  icon: ReactNode;
  iconColor: string;
  categoryType: "income" | "costs";
  periodTotalField: "incomeTotal" | "costTotal";
  transactionDirection: "in" | "out";
  filterCategories: CategoryType[]; // or whatever the current filter list type is
  periods: Period[];
  categories: CashflowCategory[];
  onTrigger?: () => void;
};
```

A terser, common-case-oriented wrapper API:

```ts
type CashflowCategorySectionConfig =
  | {
      kind: "income";
      titleKey: string;
      periods: Period[];
      categories: CashflowCategory[];
      onTrigger?: () => void;
    }
  | {
      kind: "costs";
      titleKey: string;
      periods: Period[];
      categories: CashflowCategory[];
      onTrigger?: () => void;
    };
```

with the internal implementation deriving the rest from `kind`.

---

2. **Usage example**

```tsx
<CashflowCategorySection
  kind="income"
  titleKey="cashflow.categories.income"
  periods={periods}
  categories={incomeCategories}
  onTrigger={handleToggleIncome}
/>

<CashflowCategorySection
  kind="costs"
  titleKey="cashflow.categories.costs"
  periods={periods}
  categories={costCategories}
/>
```

If you want maximum explicitness at the composition layer, keep a typed preset map:

```tsx
<CashflowCategorySection
  {...cashflowSectionPresets.income}
  periods={periods}
  categories={incomeCategories}
/>
```

---

3. **What this design hides internally**

The shared component should own:

- the section wrapper layout
- rendering the header title
- choosing the icon and icon color
- deriving the trigger behavior
- mapping summary cells across periods
- mapping category rows
- resolving the correct period total field
- selecting the correct filter list
- applying the transaction direction
- configuring `categoryType`-specific row behavior

In other words, the caller supplies only the minimal semantic choice: `income` vs `costs`.

---

4. **Trade-offs of this approach**

**Pros**
- Very terse callsites.
- Optimized for the most common case.
- Prevents duplicate wiring between the two current components.
- Keeps the “shape” of the API domain-focused instead of implementation-focused.

**Cons**
- Some flexibility is hidden behind `kind`, so uncommon variants may need escape hatches later.
- The internal preset mapping becomes a single source of truth, which is good but can grow into a “mini registry.”
- If income/costs diverge further, the shared interface may need extension or conditional props.

**Recommendation**

For this refactor, I’d use a **preset-driven discriminated union** (`kind: "income" | "costs"`) as the public interface, and keep a richer internal config map. It gives the best balance of readability, terseness, and maintainability for the common case.