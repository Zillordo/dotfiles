## 1. Interface signature

Keep `CashflowTableCell` as the canonical merged component. Keep `CashflowTableSummaryValueCell` as a thin compatibility wrapper so current callers don’t have to move all at once.

```ts
type CashflowTableCellBaseProps = {
  columnIndex: number;
  dateFrom: string;
  isBold?: boolean;
  colorMode?: "balance" | "final" | "none";
  onClick?: () => void;
};

type CashflowTableCellNumericProps = CashflowTableCellBaseProps & {
  value: number;
  progressPercentage?: number;
};

type CashflowTableCellSummaryProps = CashflowTableCellBaseProps & {
  value: number | null;
  currency: string;
  balanceQuality?: BalanceQuality | null;
};

export type CashflowTableCellProps =
  | CashflowTableCellNumericProps
  | CashflowTableCellSummaryProps;

export function CashflowTableCell(props: CashflowTableCellProps): JSX.Element;
export function CashflowTableSummaryValueCell(
  props: CashflowTableCellSummaryProps,
): JSX.Element;
```

Summary mode is inferred from `currency`; no new `variant` prop is needed.

## 2. Usage example

```tsx
// common numeric cell: net balance / category values
<CashflowTableCell
  value={period.netBalance}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="balance"
/>

// summary cell: final balance / income / costs totals
<CashflowTableCell
  value={period.finalBalance?.value ?? null}
  currency={currency}
  balanceQuality={period.finalBalance?.balanceQuality ?? null}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="final"
/>

// during migration, current summary imports can keep using the wrapper:
<CashflowTableSummaryValueCell
  value={period.costs}
  currency={currency}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="none"
/>
```

## 3. What this design hides internally

- Column highlight state and `aria-selected`
- Default click behavior (`dateFrom -> setPeriod(dayjs(dateFrom))`)
- Any border/cursor/background styling
- Theme color mapping for `balance`, `final`, and `none`
- Numeric formatting vs currency formatting
- The summary-only extras:
  - `CashflowQualityIndicator`
  - compact `CurrencyAmount`
- The plain-cell extra:
  - `LinearProgress` for `progressPercentage`
- MUI layout details (`TableCell`, `Box`, spacing, alignment)
- Rerender/memoization strategy

In short: callers express business intent, not table mechanics.

## 4. Trade-offs of this approach

- **Very low churn:** current `CashflowTableCell` callers stay basically unchanged, and summary callers can keep the old export while you migrate.
- **Close to existing props:** the merged API is mostly just the union of the two current prop sets.
- **A little implicit:** summary mode is selected by `currency` rather than an explicit `variant`.
- **Slightly more TypeScript complexity:** one union instead of two separate components.
- **One component owns two render paths:** that’s fine here, but if a third visual mode appears later, you may want a more explicit split.

This is the smallest-change merge that still keeps the public API shallow and hides the styling/click/highlight internals.