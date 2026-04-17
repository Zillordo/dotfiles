1. **Interface signature**

I’d expose one compound root, `CashflowTableCell`, with MUI-style `slots` / `slotProps`, plus semantic child subcomponents for the value and accessories:

```ts
type CashflowTableCellTone = "neutral" | "balance" | "final";

type CashflowTableCellProps = {
  columnIndex: number;
  dateFrom: string;
  isBold?: boolean;

  // Semantic, not palette-based. Maps internally to the current color behavior.
  semanticTone?: CashflowTableCellTone;

  // Optional override; if omitted, the root keeps the current "select period" click behavior.
  onClick?: () => void;

  // Structural overrides only.
  slots?: {
    root?: React.ElementType;
    contentWrapper?: React.ElementType;
    accessoriesWrapper?: React.ElementType;
  };

  slotProps?: {
    root?: TableCellProps;
    contentWrapper?: BoxProps;
    accessoriesWrapper?: BoxProps;
  };

  children: ReactNode;
};

declare const CashflowTableCell: React.FC<CashflowTableCellProps> & {
  Value: {
    Amount: React.FC<{ value: number }>;
    CurrencyAmount: React.FC<{ value: number | null; currency: string }>;
    Custom: React.FC<{ children: ReactNode }>;
  };

  Accessory: {
    Progress: React.FC<{ value: number }>;
    Quality: React.FC<{ balanceQuality: BalanceQuality | null }>;
    Custom: React.FC<{ position?: "start" | "end" | "bottom"; children: ReactNode }>;
  };
};
```

2. **Usage example**

```tsx
// Former CashflowTableCellComponent
<CashflowTableCell
  columnIndex={index}
  dateFrom={period.dateFrom}
  semanticTone="balance"
  isBold
>
  <CashflowTableCell.Value.Amount value={period.netBalance} />
  {period.progressPercentage != null && (
    <CashflowTableCell.Accessory.Progress value={period.progressPercentage} />
  )}
</CashflowTableCell>

// Former CashflowTableSummaryValueCellComponent
<CashflowTableCell
  columnIndex={index}
  dateFrom={period.dateFrom}
  semanticTone="final"
  isBold
>
  <CashflowTableCell.Accessory.Quality
    balanceQuality={period.finalBalance?.balanceQuality ?? null}
  />
  <CashflowTableCell.Value.CurrencyAmount
    value={period.finalBalance?.value ?? null}
    currency={currency}
  />
</CashflowTableCell>

// Income/cost summary cells would use:
// semanticTone="neutral"
// <CashflowTableCell.Value.CurrencyAmount ... />
```

3. **What this design hides internally**

- Column highlight state and the optimized selection subscription logic.
- The default click behavior that calls `setPeriod(dayjs(dateFrom))`.
- The actual color mapping for `neutral` / `balance` / `final`.
- The `TableCell` shell, border rules, cursor, background, and font-weight styling.
- The internal layout details (`Box`, alignment, spacing, `LinearProgress` placement).
- The formatting implementation details:
  - `formatCashflowAmount` for cashflow amounts
  - `CurrencyAmount` for currency summaries
  - `CashflowQualityIndicator` for quality badges

4. **Trade-offs of this approach**

- **Pros**
  - One root covers both current components and future cell variants.
  - Value types and accessories can grow without adding a pile of top-level props.
  - Keeps styling, click handling, and highlight logic fully internal.
  - Very aligned with MUI’s `slots` / `slotProps` pattern.

- **Cons**
  - More abstraction than two small dedicated components.
  - Consumers have to learn the compound child names and layout conventions.
  - Child classification/ordering is a bit more complex than a plain prop bag.
  - The API is slightly more verbose for the simplest cases.

- **Net**
  - This is a better “deep” API if you expect more cell subtypes, badges, indicators, sparklines, or other accessories later.