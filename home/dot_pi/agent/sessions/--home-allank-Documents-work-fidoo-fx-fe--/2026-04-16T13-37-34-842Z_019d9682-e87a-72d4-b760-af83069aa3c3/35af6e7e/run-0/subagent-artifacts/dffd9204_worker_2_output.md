1. **Interface signature**

```ts
type CashflowRowShellProps = {
  // shared sizing / layout
  labelColumnWidth?: number;
  className?: string;

  // shared cell composition
  label: React.ReactNode;
  value: React.ReactNode;

  // shared styling hooks
  labelCellProps?: React.ComponentProps<typeof TableCell>;
  valueCellProps?: React.ComponentProps<typeof TableCell>;

  // row-level customization
  rowProps?: React.ComponentProps<typeof TableRow>;
  labelRowProps?: React.ComponentProps<typeof TableRow>;
};

type CashflowCategoryRowProps = CashflowRowShellProps & {
  // category-specific behavior
  expanded?: boolean;
  onToggleExpanded?: () => void;
  isExpandable?: boolean;

  // category-specific affordances
  icon?: React.ReactNode;
  clickableLabel?: boolean;

  // wrapper / grouping support
  rowsWrapper?: React.ReactNode;
  children?: React.ReactNode;
};

function CashflowRowShell(props: CashflowRowShellProps): JSX.Element;
function CashflowCategoryRow(props: CashflowCategoryRowProps): JSX.Element;
```

A more composable variant, if you want stronger separation, is:

```ts
type CashflowRowLabelProps = {
  label: React.ReactNode;
  labelColumnWidth?: number;
  bordered?: boolean;
  background?: string;
  className?: string;
};

type CashflowRowShellProps = {
  row: React.ReactNode;
  labelCell: React.ReactNode;
  valueCell: React.ReactNode;
};

type CashflowCategoryBehaviorProps = {
  expanded?: boolean;
  onToggleExpanded?: () => void;
  icon?: React.ReactNode;
  clickableLabel?: boolean;
  rowsWrapper?: React.ReactNode;
};
```

---

2. **Usage example**

### Shared shell used by both components

```tsx
<CashflowRowShell
  label="Revenue"
  value={<Amount value={12345} />}
  labelColumnWidth={cashflowLayoutConfig.labelColumnWidth}
  labelCellProps={{ sx: { borderRight: 0, backgroundColor: "transparent" } }}
  valueCellProps={{ sx: { borderLeft: 0 } }}
/>
```

### Category row with expansion behavior

```tsx
<CashflowCategoryRow
  label="Operating Expenses"
  value={<Amount value={-5400} />}
  labelColumnWidth={cashflowLayoutConfig.labelColumnWidth}
  expanded={expanded}
  onToggleExpanded={() => setExpanded((v) => !v)}
  isExpandable
  icon={<ChevronIcon expanded={expanded} />}
  clickableLabel
  rowsWrapper={<Box sx={{ pl: 2 }}>{children}</Box>}
/>
```

### Category rows can still reuse the shared shell internally

```tsx
function CashflowCategoryRow(props: CashflowCategoryRowProps) {
  return (
    <>
      <CashflowRowShell
        label={
          <CategoryLabel
            icon={props.icon}
            clickable={props.clickableLabel}
            onClick={props.onToggleExpanded}
          >
            {props.label}
          </CategoryLabel>
        }
        value={props.value}
        labelColumnWidth={props.labelColumnWidth}
        labelCellProps={props.labelCellProps}
        valueCellProps={props.valueCellProps}
        rowProps={props.rowProps}
      />
      {props.expanded ? props.rowsWrapper : null}
    </>
  );
}
```

---

3. **What this design hides internally**

This interface keeps the shared implementation details private while exposing only the compositional surface:

- **Shared label-cell styling**
  - `cashflowLayoutConfig.labelColumnWidth`
  - border handling
  - background handling
  - consistent padding/alignment across both row types

- **Table structure details**
  - exact `TableRow` / `TableCell` arrangement
  - whether label/value live in separate cells or are wrapped with helper components
  - any conditional `sx` merging or default cell props

- **Category-specific mechanics**
  - expansion state wiring
  - trigger handling for row click / label click
  - icon placement and toggle affordance
  - wrapper rendering for nested rows
  - any special interaction states like hover, active, or expandable cursor styles

- **Styling policy**
  - the interface accepts overrides, but the component decides the default visual contract

This is especially useful if you later add other row variants like:
- subtotal rows
- empty-state rows
- group headers
- drilldown rows
- computed summary rows

---

4. **Trade-offs of this approach**

### Pros
- **High flexibility**
  - supports many row types without locking everything into “category” semantics
- **Strong reuse**
  - shared label-cell styling stays in one place
- **Composable category behavior**
  - expansion, icons, click behavior, and wrappers can be layered on top
- **Better long-term scalability**
  - easy to add new row variants without duplicating TableRow/TableCell boilerplate

### Cons
- **More props**
  - the interface can grow if every customization is passed directly
- **Potentially less opinionated**
  - callers may need to assemble more pieces themselves
- **Need for clear defaults**
  - without good defaults, the API can feel too low-level
- **Possible abstraction leakage**
  - if `TableRow`/`TableCell` props are passed through too directly, the interface can become tightly coupled to the underlying UI library

### Practical recommendation
Use a **two-layer design**:
1. a **shared low-level `CashflowRowShell`** for row/cell composition
2. a **higher-level `CashflowCategoryRow`** that composes expansion and interaction behavior on top

That gives you flexibility without forcing category-specific concerns into the shared primitive.