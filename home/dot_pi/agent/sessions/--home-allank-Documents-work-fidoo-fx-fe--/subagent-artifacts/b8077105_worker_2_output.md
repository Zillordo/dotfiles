1. **Interface signature**

```ts
type CashflowTablePeriodCellProps = {
  columnIndex: number;
  dateFrom: Dayjs;
  period?: {
    /** Simple numeric display */
    kind: 'numeric';
    value: number;
    isBold?: boolean;
    showProgress?: boolean;
    progressValue?: number;
  } | {
    /** Summary display with currency / optional quality indicator */
    kind: 'summary';
    value: number | null;
    isBold?: boolean;
    showQualityIndicator?: boolean;
  };

  /** Optional external click handler; defaults to period selection */
  onClick?: (dateFrom: Dayjs) => void;

  /** Optional override for special cases; defaults based on period type */
  colorMode?: 'balance' | 'final' | 'none';
};
```

Suggested component name:

```ts
<CashflowTablePeriodCell ... />
```

---

2. **Usage example**

```tsx
// Net balance row
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={{
    kind: 'numeric',
    value: balance,
    isBold: true,
    showProgress: true,
    progressValue: balanceRatio,
  }}
  colorMode="balance"
/>

// Category data row
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={{
    kind: 'numeric',
    value: amount,
  }}
  onClick={handleOpenCategoryDetails}
  colorMode="none"
/>

// Final balance row
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={{
    kind: 'summary',
    value: finalBalance,
    isBold: true,
    showQualityIndicator: true,
  }}
  colorMode="final"
/>

// Income / costs categories
<CashflowTablePeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={{
    kind: 'summary',
    value: total,
    isBold: true,
  }}
  colorMode="none"
/>
```

---

3. **What this design hides internally**

This single interface can encapsulate:

- `useIsColumnSelected(columnIndex)` highlight logic
- default click behavior:
  - use `onClick(dateFrom)` if provided
  - otherwise select period with `setPeriod(dayjs(dateFrom))`
- shared `TableCell` styling and selected-column appearance
- shared `colorMode` rendering rules
- formatting differences between:
  - plain numeric value + optional progress bar
  - compact currency value + optional quality indicator
- null handling for summary values
- memoization boundaries so callers don’t need to manage them

---

4. **Trade-offs of this approach**

**Pros**
- Best fit for current usage: one component covers all known callers.
- Call sites stay small and readable.
- Easy migration path: replace both existing components with one prop-driven wrapper.
- Hides internal click/highlight/style complexity.
- Preserves a simple default path for the common case.

**Cons**
- Still slightly polymorphic because of `period.kind`.
- The prop object introduces some shape branching, so the API is not as minimal as a fully specialized component.
- If more period variants appear later, the union may need extension.

**Why this is a good compromise**
- It avoids over-generalizing into many low-level props.
- It keeps the common cases ergonomic.
- It still leaves room to grow without forcing multiple sibling components back into the codebase.