1. **Interface signature**

```tsx
type CashflowTableValueCellProps = {
  column: CashflowColumn;
  dateFrom: string | Date;
  setPeriod: (period: dayjs.Dayjs) => void;

  isHighlighted?: boolean;
  bold?: boolean;
  colorMode?: "auto" | "positive-negative" | "neutral";
  onClick?: () => void;

  children: React.ReactNode;
};

export function CashflowTableValueCell(props: CashflowTableValueCellProps): JSX.Element;
```

Recommended pattern: make **one shared wrapper component** and keep the content-specific rendering outside it.

- `CashflowTableValueCell` = shared clickable/highlight-aware cell shell
- content stays as `children` so the wrapper doesn’t care whether the body is amount/progress-bar or currency/quality/null handling

If you want a slightly more opinionated API, allow an optional render hook:

```tsx
type CashflowTableValueCellProps = {
  column: CashflowColumn;
  dateFrom: string | Date;
  setPeriod: (period: dayjs.Dayjs) => void;
  isHighlighted?: boolean;
  bold?: boolean;
  colorMode?: "auto" | "positive-negative" | "neutral";
  onClick?: () => void;
  children: React.ReactNode;
};
```

2. **Usage example**

```tsx
<CashflowTableValueCell
  column={column}
  dateFrom={dateFrom}
  setPeriod={setPeriod}
  isHighlighted={isSelected}
  bold={isSummary}
  colorMode="positive-negative"
>
  <FormattedAmount value={amount} />
  {showProgressBar && <ProgressBar value={progress} />}
</CashflowTableValueCell>
```

```tsx
<CashflowTableValueCell
  column={column}
  dateFrom={dateFrom}
  setPeriod={setPeriod}
  isHighlighted={isSelected}
  bold={false}
  colorMode="auto"
>
  <CurrencyAmount value={amount} nullable />
  {quality && <QualityIndicator value={quality} />}
</CashflowTableValueCell>
```

3. **What this design hides internally**

The shared component should own all duplicated behavior:

- resolving the selected column / click target
- default click behavior: `setPeriod(dayjs(dateFrom))`
- common `TableCell` styling
- highlight state
- bold and color mode classes/variants
- click handling and pointer affordance

The two current components only differ in **cell contents**, so that logic stays as `children` composition or local render logic in the caller.

4. **Trade-offs of this approach**

**Pros**
- Minimal API surface: one exported component can replace both
- Strong decoupling: wrapper doesn’t know anything about amount formatting, progress bars, or quality indicators
- Easy migration: existing render logic can move in place with little churn
- Keeps duplication out of interaction/styling code

**Cons**
- Some semantics move to callers, so if both existing components also share content-specific helpers, those won’t be deduped automatically
- `children` can make the wrapper less explicit than specialized props
- If future variants need more built-in behavior than “clickable highlighted cell,” you may end up reintroducing a second wrapper or render-prop API

**Recommendation:** use **one shared wrapper + children**, not a “smart” polymorphic component. That gives the best balance of deduplication and low coupling while staying within the 1–3 exported API limit.