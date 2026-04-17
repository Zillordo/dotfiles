I’d merge them into **one memoized public component**:

## 1) Interface signature

```ts
type CashflowCellColorMode = "balance" | "final" | "none";

type CashflowTablePeriodCellBaseProps = {
  columnIndex: number;
  dateFrom: string;
  isBold?: boolean;
  colorMode?: CashflowCellColorMode;
  onClick?: () => void; // overrides the default period-set behavior
};

export type CashflowTablePeriodCellProps =
  | (CashflowTablePeriodCellBaseProps & {
      kind: "amount"; // simple formatted number
      value: number;
      progressPercentage?: number;
    })
  | (CashflowTablePeriodCellBaseProps & {
      kind: "currency"; // compact currency amount
      value: number | null;
      currency: string;
      balanceQuality?: BalanceQuality | null;
    });

export function CashflowTablePeriodCell(
  props: CashflowTablePeriodCellProps,
): JSX.Element;
```

## 2) Usage example for current callers

```tsx
// net balance row
<CashflowTablePeriodCell
  kind="amount"
  value={period.netBalance}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="balance"
/>

// category data row
<CashflowTablePeriodCell
  kind="amount"
  value={getCategoryValue(period)}
  columnIndex={index}
  dateFrom={period.dateFrom}
  colorMode="none"
  onClick={() => openDetail(index)}
/>

// final balance row
<CashflowTablePeriodCell
  kind="currency"
  value={period.finalBalance?.value ?? null}
  balanceQuality={period.finalBalance?.balanceQuality ?? null}
  currency={currency}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="final"
/>

// income / costs headers
<CashflowTablePeriodCell
  kind="currency"
  value={period.income}
  currency={currency}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="none"
/>
```

## 3) Hidden internals

Keep all of this private inside the component:

- `useIsColumnSelected(columnIndex)` for highlight state
- default click behavior: `onClick ?? (() => setPeriod(dayjs(dateFrom)))`
- shared `TableCell` shell:
  - right alignment
  - pointer cursor
  - selected border/background behavior
  - bold weight
  - `aria-selected`
- shared color resolution for `balance / final / none`
  - `null` stays neutral
- branch rendering:
  - `kind="amount"` → `formatCashflowAmount(...)` + optional `LinearProgress`
  - `kind="currency"` → compact `CurrencyAmount` + optional `CashflowQualityIndicator`
- export as `memo(...)` to preserve current perf behavior

## 4) Trade-offs

**Pros**
- One public component, one shared style path
- No duplicated highlight/click/color logic
- Type-safe branching without over-generalizing
- Keeps the current memoization/perf mindset intact

**Cons**
- Slightly more verbose than two dedicated components because of `kind`
- The props union is a bit more complex to read at first
- If the two renderings diverge a lot later, wrappers may become easier to scan

**Why I’d pick this**
- It fits all current callers cleanly
- It hides all the implementation details you want hidden
- It stays focused on exactly two known render shapes instead of becoming a generic slot-based API

If you want, I can turn this into a migration plan for the existing files/imports next.