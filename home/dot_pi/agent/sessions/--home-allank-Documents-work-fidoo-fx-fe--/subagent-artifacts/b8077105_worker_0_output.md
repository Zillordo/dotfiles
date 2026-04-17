## 1. Interface signature

```ts
type CashflowTablePeriodCellProps = {
  columnIndex: number;
  dateFrom: string | Date;
  setPeriod: (period: dayjs.Dayjs) => void;

  value: number | null;
  currency?: string;

  variant: "number" | "summary";
  colorMode?: "balance" | "final" | "none";

  bold?: boolean;
  onClick?: () => void;

  progress?: {
    value: number;
    maxValue: number;
  };

  qualityIndicator?: {
    quality: CashflowQuality;
    // whatever the existing indicator needs
  };

  sx?: SxProps<Theme>;
};
```

A single public component:

```ts
function CashflowTablePeriodCell(props: CashflowTablePeriodCellProps): JSX.Element;
```

### Behavioral contract

- If `onClick` is provided, it is used.
- Otherwise clicking the cell calls `setPeriod(dayjs(dateFrom))`.
- `useIsColumnSelected(columnIndex)` controls highlight state internally.
- `variant="number"` renders the current “simple formatted number” layout.
- `variant="summary"` renders the current “compact currency amount” layout.
- `value === null` is allowed only for `variant="summary"` and renders the empty/null-safe state.
- `colorMode` defaults to `"none"`.
- `bold` controls typography weight for both variants.
- `progress` is only relevant for `variant="number"`.
- `qualityIndicator` is only relevant for `variant="summary"`.

---

## 2. Usage example

### Net balance row
```tsx
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  setPeriod={setPeriod}
  value={netBalance}
  variant="number"
  colorMode="balance"
  bold
/>
```

### Category row with custom click behavior
```tsx
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  setPeriod={setPeriod}
  value={amount}
  variant="number"
  colorMode="none"
  onClick={() => openDetails(categoryId, dateFrom)}
/>
```

### Final balance row
```tsx
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  setPeriod={setPeriod}
  value={finalBalance}
  currency={currency}
  variant="summary"
  colorMode="final"
  bold
  qualityIndicator={{ quality: finalQuality }}
/>
```

### Income / costs category rows
```tsx
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  setPeriod={setPeriod}
  value={summaryValue}
  currency={currency}
  variant="summary"
  colorMode="none"
  bold
/>
```

---

## 3. What this design hides internally

This component should encapsulate all shared implementation details:

- `useIsColumnSelected(columnIndex)` highlight logic
- default click behavior based on `setPeriod(dayjs(dateFrom))`
- MUI `TableCell` structure and shared `sx`
- shared hover/selected/clickable affordances
- all `colorMode` styling branches
- formatting differences between numeric and summary/currency rendering
- optional progress bar rendering
- optional quality indicator rendering
- null handling for summary values

In other words, callers only choose:
- which visual variant they want
- what to display
- whether they want custom click handling

---

## 4. Trade-offs of this approach

### Pros
- **One public component** satisfies the minimization constraint.
- Keeps all shared behavior in one place.
- Easy migration path from both existing components.
- Call sites stay small and explicit.
- Good fit for memoization, since the prop surface is stable and predictable.

### Cons
- The prop type becomes a bit “union-ish” and less elegant.
- `variant` introduces some conditional prop semantics:
  - `progress` makes sense only for `"number"`
  - `qualityIndicator` / `currency` make sense only for `"summary"`
- Slightly more validation burden in TypeScript and at call sites.
- If the two renderers diverge later, the single component may become too broad.

### Why this is still a good fit here
The current components are already highly overlapping in:
- click behavior
- selection highlight
- TableCell styling
- color mode logic

So a single public wrapper is the right level of abstraction now, while still allowing the internal render paths to remain separate and focused.

If you want, I can also sketch a **prop union type** that makes the `variant` constraints stricter in TypeScript without adding more public components.