I’d make this a single **memoized period-cell shell** plus one **component slot** for the visual content.

I’d avoid a `variant` enum because that would bake today’s two renderings into the API.  
I’d also avoid a raw render prop as the primary API here: a slot component is a little more verbose, but it’s better for hooks, memoization, and future renderers.

## 1) Interface signature

```ts
type CashflowTablePeriodCellColorMode = "balance" | "final" | "none";

type CashflowTablePeriodCellBaseProps = {
  value: number | null;
  columnIndex: number;
  dateFrom: string;
  isBold?: boolean;
  colorMode?: CashflowTablePeriodCellColorMode;
  onClick?: () => void;
};

type CashflowTablePeriodCellContentComponent<TContentProps extends object = {}> =
  React.ComponentType<{ value: number | null } & TContentProps>;

// `TContentProps` are forwarded to the slot component.
// `value` is reserved and always provided by the shell.
export type CashflowTablePeriodCellProps<TContentProps extends object = {}> =
  CashflowTablePeriodCellBaseProps & TContentProps & {
    Content: CashflowTablePeriodCellContentComponent<TContentProps>;
  };
```

Recommended public name for the shell: `CashflowTablePeriodCell`.

Current names can stay as thin presets/wrappers if you want compatibility:
- `CashflowTableCell` → `CashflowTablePeriodCell` + amount content
- `CashflowTableSummaryValueCell` → `CashflowTablePeriodCell` + compact-currency content

---

## 2) Usage example

```tsx
const AmountContent = memo(function AmountContent({
  value,
  progressPercentage,
}: {
  value: number | null;
  progressPercentage?: number;
}) {
  const { language } = useTT();

  if (value === null) return null;

  return (
    <Box>
      {formatCashflowAmount(value, language)}
      {progressPercentage !== undefined && (
        <LinearProgress
          variant="determinate"
          value={progressPercentage}
          sx={{
            mt: 0.5,
            height: 4,
            borderRadius: 1,
            backgroundColor: "action.hover",
            "& .MuiLinearProgress-bar": {
              backgroundColor:
                progressPercentage > 100 ? "warning.main" : "primary.main",
            },
          }}
        />
      )}
    </Box>
  );
});

const CompactCurrencyContent = memo(function CompactCurrencyContent({
  value,
  currency,
  balanceQuality,
}: {
  value: number | null;
  currency: string;
  balanceQuality?: BalanceQuality | null;
}) {
  if (value === null) return null;

  return (
    <Box
      sx={{
        minHeight: 24,
        display: "flex",
        alignItems: "center",
        justifyContent: "flex-end",
        gap: 0.5,
        width: "100%",
        whiteSpace: "nowrap",
      }}
    >
      <CashflowQualityIndicator
        balanceQuality={balanceQuality}
        size="sm"
        variant="icon"
      />
      <CurrencyAmount
        notation="compact"
        value={value}
        currency={currency}
        naturalPrecision
      />
    </Box>
  );
});

// NetBalanceRow / CategoryDataRow
<CashflowTablePeriodCell
  value={period.netBalance}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="balance"
  Content={AmountContent}
  progressPercentage={period.progressPercentage}
/>

// FinalBalanceRow / IncomeCategories / CostsCategories
<CashflowTablePeriodCell
  value={period.finalBalance?.value ?? null}
  columnIndex={index}
  dateFrom={period.dateFrom}
  isBold
  colorMode="final"
  Content={CompactCurrencyContent}
  currency={currency}
  balanceQuality={period.finalBalance?.balanceQuality ?? null}
/>

// CategoryDataRow override click, still same shell
<CashflowTablePeriodCell
  value={getCategoryValue(period)}
  columnIndex={index}
  dateFrom={period.dateFrom}
  colorMode="none"
  onClick={() => openDetail(index)}
  Content={AmountContent}
/>
```

---

## 3) What this design hides internally

The shell owns all of this, so callers never have to care:

- `useIsColumnSelected(columnIndex)` and `aria-selected`
- default click fallback: `onClick ?? (() => setPeriod(dayjs(dateFrom)))`
- the shared MUI `TableCell` chrome:
  - right alignment
  - pointer cursor
  - background/border behavior
  - bold font weight
  - selected-column border highlight
  - box sizing
- the shared color semantics:
  - `"balance"` = red/green/neutral
  - `"final"` = red only for negative
  - `"none"` = neutral
  - `null` = neutral
- the memoization/perf wiring for the hot table path

The content slot only deals with presentation:
- formatting
- indicators
- extra visuals
- hooks like `useTT`
- future renderer-specific layout

---

## 4) Trade-offs of this approach

**Pros**
- One shared shell removes the duplicated click/highlight/color/styling logic.
- Very flexible: any future period-cell renderer is just another `Content` component.
- Better memoization story than a raw render prop:
  - content can be a stable `memo(...)` component
  - content can use hooks
  - the shell stays cheap and focused
- Keeps the API small: one behavior shell, one slot.

**Cons**
- Slightly more boilerplate than two bespoke components.
- Each visual style becomes a small component, not just inline JSX.
- The shell still assumes this is a numeric period-cell domain; if you later need a completely different tone model, add a new shell rather than stretching this one.
- As with any memoized component, unstable inline props/handlers reduce the perf benefit.

**Bottom line:** this is the smallest practical public surface I’d use here: **one period-cell shell + one content slot component**, with the current two visuals implemented as memoized content components.