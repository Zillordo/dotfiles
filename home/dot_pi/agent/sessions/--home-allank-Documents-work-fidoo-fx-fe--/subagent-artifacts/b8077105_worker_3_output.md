1. **Interface signature**

```tsx
type CashflowPeriodCellRootProps = {
  columnIndex: number;
  dateFrom: string | Date;
  period: any;
  setPeriod: (period: any) => void;
  onClick?: () => void;
  children: React.ReactNode;
  sx?: SxProps<Theme>;
};

type CashflowPeriodCellProps = CashflowPeriodCellRootProps & {
  highlight?: boolean; // defaults to useIsColumnSelected(columnIndex)
  colorMode?: "none" | "balance" | "final";
  bold?: boolean;
};

type CashflowValueCellContentProps = {
  value: number | null;
  currency?: string;
  showProgress?: boolean;
  quality?: any;
};

declare function CashflowPeriodCell(props: CashflowPeriodCellProps): JSX.Element;
declare function CashflowPeriodCellContent(
  props: CashflowValueCellContentProps
): JSX.Element;
```

A more slot-based shape would be:

```tsx
type CashflowTableCellSlots = {
  Root: typeof CashflowPeriodCellRoot;
  Content: typeof CashflowTableCellContent;
};

type CashflowPeriodCellRootProps = {
  columnIndex: number;
  dateFrom: string | Date;
  onClick?: () => void;
  colorMode?: "none" | "balance" | "final";
  selected?: boolean;
  sx?: SxProps<Theme>;
  children: React.ReactNode;
};

type CashflowTableCellContentProps = {
  variant: "simple" | "summary";
  value: number | null;
  currency?: string;
  progress?: number;
  quality?: CashflowQuality;
  bold?: boolean;
};
```

2. **Usage example**

```tsx
<CashflowPeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={period}
  setPeriod={setPeriod}
  colorMode="balance"
>
  <CashflowPeriodCellContent
    variant="simple"
    value={netBalance}
    showProgress
  />
</CashflowPeriodCell>
```

```tsx
<CashflowPeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={period}
  setPeriod={setPeriod}
  colorMode="final"
>
  <CashflowPeriodCellContent
    variant="summary"
    value={finalBalance}
    currency={currency}
    quality={quality}
  />
</CashflowPeriodCell>
```

For custom row behavior:

```tsx
<CashflowPeriodCell
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  period={period}
  setPeriod={setPeriod}
  onClick={() => openDetails(rowId)}
>
  <CashflowPeriodCellContent variant="simple" value={categoryValue} />
</CashflowPeriodCell>
```

3. **What this design hides internally**

- Column highlight state via `useIsColumnSelected(columnIndex)`
- Default click handling:
  - custom `onClick` wins
  - otherwise `setPeriod(dayjs(dateFrom))`
- TableCell `sx` boilerplate and hover/selected styling
- `colorMode`-specific text/background treatment
- memoization concerns for the clickable shell
- layout differences between simple numeric and summary/currency rendering
- progress-bar / quality-indicator conditional logic
- null handling in the summary variant

4. **Trade-offs of this approach**

**Pros**
- Clean separation between behavior and content
- Flexible enough to support existing callers without duplicating shell logic
- Matches MUI/Radix-style composition well
- Reduces the risk of over-generalizing all cell content into one prop soup
- Preserves memoization opportunities: shell and content can memoize independently

**Cons**
- Slightly more verbose at call sites than a single monolithic component
- Requires callers to understand two pieces instead of one
- A slot-based API can feel heavier than the current simple component pair
- You may still need thin wrapper components for the four existing row types to keep usage ergonomic

If you want, I can turn this into a more concrete TypeScript API proposal with exact prop names aligned to your current codebase.