Below is a cohesive component-family design that keeps the table structure intact, reduces naming duplication, and fits the common “income/costs sections + summary rows” case while staying extensible.

---

## 1. Interface signature (types/methods)

### Core idea

Introduce one **table family namespace** with two main row patterns:

- **`Section`** for collapsible category groups like income/costs
- **`SummaryRow`** for non-collapsible totals like net/final balance

Keep the fixed label column width centralized in the family root so every row uses the same first-column layout.

### Proposed API

```tsx
// cashflow-table-family.tsx

export type CashflowTableFamilyProps = {
  labelColumnWidth?: string | number; // defaults to cashflowLayoutConfig.labelColumnWidth
  children: React.ReactNode;
};

export type CashflowSectionProps = {
  id: string;
  title: React.ReactNode;
  icon?: React.ReactNode;
  total: React.ReactNode;

  collapsible?: boolean;        // default true
  defaultOpen?: boolean;
  open?: boolean;               // controlled
  onOpenChange?: (open: boolean) => void;

  actions?: React.ReactNode;    // custom header actions
  children: React.ReactNode;    // category rows
};

export type CashflowRowProps = {
  label: React.ReactNode;
  value: React.ReactNode;

  onLabelClick?: () => void;
  onValueClick?: () => void;
  clickable?: boolean;          // shorthand for row/value interaction
  disabled?: boolean;
};

export type CashflowSummaryRowProps = {
  label: React.ReactNode;
  values: React.ReactNode[];    // supports 1+ value cells
  emphasize?: boolean;          // e.g. net/final balance styling
};

export type CashflowTableFamilyComponent = React.FC<CashflowTableFamilyProps> & {
  Section: React.FC<CashflowSectionProps>;
  Row: React.FC<CashflowRowProps>;
  SummaryRow: React.FC<CashflowSummaryRowProps>;

  // Optional small building blocks for rare customization
  Header?: React.FC<{
    title: React.ReactNode;
    icon?: React.ReactNode;
    total?: React.ReactNode;
    actions?: React.ReactNode;
  }>;
  LabelCell?: React.FC<{
    children: React.ReactNode;
    width?: string | number;
  }>;
  ValueCell?: React.FC<{
    children: React.ReactNode;
    align?: "left" | "right";
  }>;
};
```

### Semantic mapping

- **`CashflowTableFamily`** = top-level layout/context provider for width and shared styling
- **`CashflowTableFamily.Section`** = replaces `CashflowTableCategorySection`
- **`CashflowTableFamily.Row`** = replaces `CashflowCategoryDataRow`
- **`CashflowTableFamily.SummaryRow`** = replaces `CashflowTableSummary` / `CashflowTableSummaryValueCell`
- Small internal primitives can still exist, but are not the main public API

---

## 2. Usage example (how caller uses it)

```tsx
<CashflowTableFamily labelColumnWidth={cashflowLayoutConfig.labelColumnWidth}>
  <CashflowTableFamily.Section
    id="income"
    title="Income"
    icon={<IncomeIcon />}
    total={incomeTotal}
    defaultOpen
  >
    <CashflowTableFamily.Row
      label="Sales"
      value={salesValue}
      onLabelClick={() => openDetails("sales")}
      onValueClick={() => openDetails("sales")}
      clickable
    />
    <CashflowTableFamily.Row
      label="Other income"
      value={otherIncomeValue}
    />
  </CashflowTableFamily.Section>

  <CashflowTableFamily.Section
    id="costs"
    title="Costs"
    icon={<CostsIcon />}
    total={costTotal}
    defaultOpen
    actions={<AddCostButton />}
  >
    <CashflowTableFamily.Row
      label="Payroll"
      value={payrollValue}
      clickable
      onValueClick={() => openDetails("payroll")}
    />
    <CashflowTableFamily.Row
      label="Rent"
      value={rentValue}
    />
  </CashflowTableFamily.Section>

  <CashflowTableFamily.SummaryRow
    label="Net balance"
    values={[netBalanceValue]}
    emphasize
  />

  <CashflowTableFamily.SummaryRow
    label="Final balance"
    values={[finalBalanceValue]}
    emphasize
  />
</CashflowTableFamily>
```

### Optional more explicit variant

If you want to optimize for the most common page shape even more, expose a convenience composition:

```tsx
<CashflowTableFamily labelColumnWidth={cashflowLayoutConfig.labelColumnWidth}>
  <CashflowTableFamily.Section ... />
  <CashflowTableFamily.Section ... />
  <CashflowTableFamily.SummaryRow ... />
  <CashflowTableFamily.SummaryRow ... />
</CashflowTableFamily>
```

This is already readable without requiring separate “category” vs “summary” modules.

---

## 3. What this design hides internally

This interface lets the implementation absorb the current module split and normalize it behind one consistent family:

### Internals hidden from callers

- **TableRow/TableCell structure**
  - Callers do not manage row/cell composition directly.
  - Family components render the required table layout under the hood.

- **Shared first-column width**
  - `labelColumnWidth` is applied consistently in one place.
  - No duplicated width logic in section/header/summary components.

- **Header composition**
  - Icon, title, total, toggle button, and custom actions can all be assembled internally.
  - The caller only supplies semantic inputs.

- **Collapsible state management**
  - Controlled/uncontrolled open state can be handled inside `Section`.
  - The existing collapse behavior stays, but the API is simpler.

- **Detail-click handling**
  - `Row` can route clicks on label/value cells to the same underlying behavior.
  - Future variants like “label opens detail, value opens edit” can be supported without changing the overall family shape.

- **Summary row cell styling**
  - First label cell, value cell alignment, and emphasis styling are unified.
  - Existing `CashflowTableSummaryValueCell` becomes an internal primitive or compatibility layer.

- **Naming duplication**
  - “Category”, “Summary”, “DataRow”, “Trigger”, “Rows”, etc. can be collapsed into a smaller public vocabulary:
    - `Section`
    - `Row`
    - `SummaryRow`

---

## 4. Trade-offs of this approach

### Pros

- **Much cleaner caller API**
  - The common case becomes obvious: two sections plus summary rows.
- **Less naming noise**
  - Removes redundant “category” vs “summary” vocabulary at the public surface.
- **Stable table layout**
  - The fixed label column width is guaranteed by the family root.
- **Flexible for future variants**
  - `actions`, controlled `open`, and per-cell click handlers cover likely future needs.
- **Easy migration path**
  - Existing components can be adapted internally without a big rewrite.

### Cons

- **Slightly more abstraction**
  - A family root plus nested components is more abstract than raw table pieces.
- **Less low-level control by default**
  - Very custom layouts may need escape hatches or internal primitives.
- **Requires a careful migration**
  - Existing imports from category/summary modules may need compatibility exports.
- **Potentially broader component responsibility**
  - If the family grows too much, it could become “too smart” unless internal primitives stay private.

### Why this is a good fit here

This codebase’s dominant shape is predictable:
- 2 collapsible sections: income and costs
- 2 summary rows: net balance and final balance

So the API should optimize for that shape first, while still allowing:
- custom section actions
- click-to-open detail rows
- future summary variations
- controlled/uncontrolled collapse behavior

---

If you want, I can also propose:
1. a **migration mapping** from the current component names to the new family API, or  
2. a **concrete TSX implementation plan** with minimal internal wrappers and compatibility exports.