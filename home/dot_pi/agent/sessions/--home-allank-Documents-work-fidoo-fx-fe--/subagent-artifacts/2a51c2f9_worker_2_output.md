1. **Interface signature (types/methods)**

```ts
type UseCashflowTimePeriodFilterOptions = {
  columnCount: number;
  companyId: string;
  minDate?: string; // BE-provided oldest allowed date
  maxDate?: string; // BE-provided latest allowed date
};

type UseCashflowTimePeriodFilterResult = {
  window: {
    from: string; // ISO date
    to: string;   // ISO date
  };

  period: {
    interval: "1W" | "1M";
    selectedDay: string; // ISO date
  };

  actions: {
    setInterval: (interval: "1W" | "1M") => void;
    setSelectedDay: (day: string) => void;
    setPeriod: (day: string, interval?: "1W" | "1M") => void;
    previous: () => void;
    next: () => void;
  };

  navigation: {
    canPrevious: boolean;
    canNext: boolean;
  };

  bounds: {
    minDate: string;
    maxDate: string;
  };
};

declare function useCashflowTimePeriodFilter(
  options: UseCashflowTimePeriodFilterOptions,
): UseCashflowTimePeriodFilterResult;
```

If you want a slightly more ergonomic version for consumers, I’d flatten the most common fields:

```ts
const {
  window,
  period,
  previous,
  next,
  canPrevious,
  canNext,
} = useCashflowTimePeriodFilter(...);
```

---

2. **Usage example (how caller uses it)**

```tsx
function CashflowChart({
  columnCount,
  companyId,
  minDate,
  maxDate,
}: {
  columnCount: number;
  companyId: string;
  minDate?: string;
  maxDate?: string;
}) {
  const {
    window,
    period,
    previous,
    next,
    canPrevious,
    canNext,
  } = useCashflowTimePeriodFilter({
    columnCount,
    companyId,
    minDate,
    maxDate,
  });

  return (
    <>
      <Chart
        from={window.from}
        to={window.to}
        interval={period.interval}
        selectedDay={period.selectedDay}
      />

      <button onClick={previous} disabled={!canPrevious}>
        Previous
      </button>
      <button onClick={next} disabled={!canNext}>
        Next
      </button>
    </>
  );
}
```

For tests, the caller can assert only the stable outputs it cares about:

```ts
expect(result.current.window.from).toBe("2026-01-01");
expect(result.current.navigation.canNext).toBe(true);
```

---

3. **What this design hides internally**

This interface intentionally hides:

- URL query param synchronization
- sessionStorage persistence
- fallback/default period restoration
- date clamping against min/max bounds
- recalculating the visible window when:
  - interval changes
  - column count changes
  - BE bounds arrive/shift
- the “selected day vs visible range” distinction
- period-state merge logic between URL, session, and React state
- internal Dayjs math and visible-range calculations

That keeps the hook focused on “give me a window and let me move it.”

---

4. **Trade-offs of this approach**

**Pros**
- Very easy for chart/table components to consume.
- Matches the common case: render a window, move period-by-period.
- Keeps persistence and URL sync out of component code.
- Still exposes enough for tests and advanced UI states.

**Cons**
- `selectedDay` remains conceptually separate from the visible window, which can be slightly confusing.
- Returning ISO strings is simple, but less convenient if callers want date arithmetic.
- Hiding the persistence layer makes advanced debugging a bit less transparent.
- If future consumers need finer control over navigation or clamping, they may want a lower-level hook or an additional “controller” API.

If you want, I can also propose a **second, more opinionated interface** optimized purely for charts, with an even smaller surface area.