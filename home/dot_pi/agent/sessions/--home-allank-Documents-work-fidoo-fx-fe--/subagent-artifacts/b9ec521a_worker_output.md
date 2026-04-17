1. **Interface signature (types/methods)**

```ts
type CashflowTableCategoryVariant = "income" | "costs";
type CashflowTableSummaryVariant = "net" | "final";

type CashflowTableCategorySectionProps = {
  variant: CashflowTableCategoryVariant;
};

type CashflowTableSummaryRowProps = {
  variant: CashflowTableSummaryVariant;
};
```

Recommended component surface:

```tsx
<CashflowTableCategorySection variant="income" />
<CashflowTableCategorySection variant="costs" />

<CashflowTableSummaryRow variant="net" />
<CashflowTableSummaryRow variant="final" />
```

If you want to preserve existing exports, keep thin wrappers:

```tsx
<CashflowTableIncomeCategories />
<CashflowTableCostsCategories />
<CashflowTableNetBalanceRow />
<CashflowTableFinalBalanceRow />
```

backed internally by the two generic primitives above.

---

2. **Usage example (how caller uses it)**

Most common-case composition:

```tsx
<TableBody>
  <CashflowTableCategorySection variant="income" />
</TableBody>

<TableBody>
  <CashflowTableCategorySection variant="costs" />
</TableBody>

<TableBody>
  <CashflowTableSummaryRow variant="net" />
  <CashflowTableSummaryRow variant="final" />
</TableBody>
```

This keeps the top-level table very concise and matches the “two collapsible category sections + two summary rows” shape.

---

3. **What this design hides internally**

This API hides the repeated implementation details that are currently duplicated across the four call sites:

- translation keys for income vs costs labels
- icon selection and icon color
- direction (`IN` / `OUT`)
- category filtering source
- total field selection (`period.income` vs `period.costs`)
- row rendering differences for net vs final balance
- value-cell component differences (`CashflowTableCell` vs `CashflowTableSummaryValueCell`)
- nullability and balance-quality handling for final balance

In other words, the caller only chooses the semantic variant, while the component handles the rendering preset.

---

4. **Trade-offs of this approach**

**Pros**
- Very concise for the common case
- Preserves current rendering behavior
- Reduces duplicated naming between category and summary components
- Easier to scan at the table composition level
- Keeps future expansion possible via new variants

**Cons**
- The `variant` prop becomes a small abstraction layer, so individual behavior is less explicit at the call site
- A single generic component can feel slightly less discoverable than separate purpose-named components
- If the category and summary rows diverge heavily later, the shared abstraction may become too broad

**Best fit here**
This is a good trade because the codebase’s dominant shape is already fixed and repetitive: exactly two category sections and two summary rows. A variant-driven API matches that structure and optimizes for the most common case without changing what gets rendered.