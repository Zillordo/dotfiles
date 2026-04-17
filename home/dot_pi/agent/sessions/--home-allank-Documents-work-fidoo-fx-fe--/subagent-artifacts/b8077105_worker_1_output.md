## 1. Interface signature

A flexible, renderer-driven interface could be centered around a single shared shell component plus a typed renderer config:

```ts
import type { ReactNode } from "react";
import type { SxProps, Theme } from "@mui/material/styles";

export type CashflowTableCellColorMode = "none" | "balance" | "final";

export type CashflowTableCellRenderContext = {
  periodIndex: number;
  columnIndex: number;
  isSelected: boolean;
};

export type CashflowTableCellBaseProps = {
  periodIndex: number;
  columnIndex: number;
  dateFrom: string | Date;
  onClick?: () => void;
  colorMode?: CashflowTableCellColorMode;
  bold?: boolean;
  sx?: SxProps<Theme>;
  className?: string;
};

export type CashflowTableCellRenderer<TValue> = (args: {
  value: TValue;
  context: CashflowTableCellRenderContext;
}) => ReactNode;

export type CashflowTableCellProps<TValue> = CashflowTableCellBaseProps & {
  value: TValue;
  renderValue: CashflowTableCellRenderer<TValue>;
};

export function CashflowTableCell<TValue>(
  props: CashflowTableCellProps<TValue>
): JSX.Element;
```

If you want to preserve the current two call patterns while still maximizing flexibility, you can layer convenience prop aliases on top of this shell:

```ts
export type CashflowTableNumericCellProps = CashflowTableBaseProps & {
  value: number;
  renderValue: (args: {
    value: number;
    context: CashflowTableCellRenderContext;
  }) => ReactNode;
};

export type CashflowTableSummaryCellProps = CashflowTableBaseProps & {
  value: number | null;
  renderValue: (args: {
    value: number | null;
    context: CashflowTableCellRenderContext;
  }) => ReactNode;
};
```

But the core design is the single generic shell that only knows:
- it is a clickable period cell,
- it handles selection/highlight,
- it resolves default click behavior,
- it applies the shared MUI TableCell styling,
- it delegates the actual content to a renderer.

---

## 2. Usage example

### Net balance row

```tsx
<CashflowTableCell<number>
  periodIndex={periodIndex}
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  value={amount}
  colorMode="balance"
  bold
  renderValue={({ value }) => (
    <NumericValueWithProgress value={value} progress={progress} />
  )}
/>
```

### Category row with custom click behavior

```tsx
<CashflowTableCell<number>
  periodIndex={periodIndex}
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  value={amount}
  colorMode="none"
  onClick={() => openCategoryDetails(categoryId, periodIndex)}
  renderValue={({ value }) => (
    <FormattedNumber value={value} />
  )}
/>
```

### Final balance row with quality indicator

```tsx
<CashflowTableCell<number | null>
  periodIndex={periodIndex}
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  value={summaryValue}
  colorMode="final"
  bold
  renderValue={({ value }) => (
    <CashflowSummaryValue
      value={value}
      currency={currency}
      quality={quality}
      showQualityIndicator
    />
  )}
/>
```

### Future renderer example

```tsx
<CashflowTableCell<string>
  periodIndex={periodIndex}
  columnIndex={columnIndex}
  dateFrom={dateFrom}
  value={status}
  renderValue={({ value }) => <StatusChip label={value} />}
/>
```

---

## 3. What this design hides internally

This interface keeps the following implementation details inside the shared cell component:

- **Column highlight logic**
  - `useIsColumnSelected(columnIndex)`

- **Default click behavior**
  - if `onClick` is provided, use it
  - otherwise call `setPeriod(dayjs(dateFrom))`

- **Clickable cell wiring**
  - `TableCell` click handler
  - pointer/cursor semantics
  - any accessibility wiring related to “interactive table cell”

- **Shared styling**
  - identical `TableCell sx`
  - row/column selected styling
  - bold and color mode application

- **Color mode interpretation**
  - `balance`
  - `final`
  - `none`

- **Memoization concerns**
  - the shell can own `memo`
  - renderer can remain a pure function
  - future wrappers can be memoized independently if needed

This keeps the content renderer focused only on “what to show,” not “how the cell behaves.”

---

## 4. Trade-offs of this approach

### Pros

- **Max flexibility**
  - supports arbitrary future content types, not just numeric or summary values
  - easy to add chips, icons, stacked content, progress bars, loaders, or custom layouts

- **Strong separation of concerns**
  - shared behavior stays in one shell component
  - cell-specific presentation stays in the renderer

- **Avoids over-generalizing too early**
  - one base abstraction, not a deep hierarchy of specialized components

- **Good migration path**
  - existing components can become thin wrappers around the new shell

- **Preserves performance mindset**
  - the shell can remain memoized
  - renderers can be stable and lightweight

### Cons

- **Slightly more abstract at call sites**
  - `renderValue` is more verbose than a dedicated component prop API

- **Type inference can be a bit more complex**
  - especially if you want strong typing for different renderers and value shapes

- **Renderer ownership is shifted to callers**
  - callers must understand they are responsible for the inner content structure

- **Less self-documenting than purpose-built components**
  - a `CashflowTableSummaryValueCellComponent` name tells you more immediately than a generic renderer shell

### Practical recommendation

For your case, I’d use this as the **shared internal interface** and keep small convenience wrappers for the current usages:

- `CashflowTableCellComponent` → wrapper for numeric/progress rendering
- `CashflowTableSummaryValueCellComponent` → wrapper for summary/currency/quality rendering

That gives you:
- one shared behavior layer,
- flexible future renderers,
- minimal churn for current callers,
- and no premature over-design.

If you want, I can also sketch the **exact wrapper API** for the two existing components so they both compile down to this shared interface cleanly.