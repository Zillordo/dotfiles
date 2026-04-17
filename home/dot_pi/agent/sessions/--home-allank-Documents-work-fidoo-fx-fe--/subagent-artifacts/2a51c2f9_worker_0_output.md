Below is a **lean interface design** for `useCashflowTimePeriodFilter` that keeps the public API small while preserving the behavior you described.

---

## 1) Interface signature (types/methods)

```ts
type CashflowTimePeriodFilterOptions = {
  columnCount: number;
  minDate: string | undefined; // BE-provided lower bound
  maxDate: string | undefined; // BE-provided upper bound
  companyId: string;
};

type CashflowTimePeriodFilterState = {
  dateFrom: string;
  dateTo: string;
  interval: "1W" | "1M";
  selectedDay: string; // ISO date string for easier testing/serialization
  canGoPrevious: boolean;
  canGoNext: boolean;
  minDate: string;
  maxDate: string;
};

type CashflowTimePeriodFilterActions = {
  setPeriod: (day: string, interval?: "1W" | "1M") => void;
  navigate: (direction: "prev" | "next") => void;
};

type UseCashflowTimePeriodFilterResult = {
  state: CashflowTimePeriodFilterState;
  actions: CashflowTimePeriodFilterActions;
};
```

If you want to go even smaller, collapse this to **one method**:

```ts
type UseCashflowTimePeriodFilterResult = {
  state: CashflowTimePeriodFilterState;
  update: (change: {
    period?: { day?: string; interval?: "1W" | "1M" };
    navigate?: "prev" | "next";
  }) => void;
};
```

But the best balance is usually the **2-method version** above.

---

## 2) Usage example (how caller uses it)

```ts
const { state, actions } = useCashflowTimePeriodFilter({
  columnCount: 12,
  minDate: settings.minDate,
  maxDate: settings.maxDate,
  companyId,
});

return (
  <>
    <CashflowChart
      dateFrom={state.dateFrom}
      dateTo={state.dateTo}
      interval={state.interval}
    />

    <PeriodToolbar
      selectedDay={state.selectedDay}
      interval={state.interval}
      canGoPrevious={state.canGoPrevious}
      canGoNext={state.canGoNext}
      onPrevious={() => actions.navigate("prev")}
      onNext={() => actions.navigate("next")}
      onDayChange={(day) => actions.setPeriod(day)}
      onIntervalChange={(interval) => actions.setPeriod(state.selectedDay, interval)}
    />
  </>
);
```

For tests, this shape is also simpler to assert:

```ts
expect(result.current.state.dateFrom).toBe("2025-01-01");
expect(result.current.state.canGoNext).toBe(true);
```

---

## 3) What this design hides internally

This interface intentionally hides:

- **URL query param sync** via `nuqs`
- **session storage persistence** through the internal period-state helper
- **clamping logic** for `selectedDay` against bounds
- **date-range recalculation** when:
  - `columnCount` changes
  - interval changes
  - bounds change
- **navigation math** for previous/next period
- **visible-range checks** to decide whether changing the selected day should move the chart window
- **default fallback bounds** when BE dates are not available yet
- **Dayjs-specific implementation details** from callers

So callers only deal with a compact “state + actions” surface.

---

## 4) Trade-offs of this approach

### Pros
- **Small API surface**: easy for chart/table components to consume
- **Better testability**: one state object is easier to snapshot/assert
- **Less coupling**: callers don’t need to know about session storage or query params
- **Future-proof**: internal sync strategy can change without breaking consumers

### Cons
- **Slightly less explicit** than returning individual fields
- Callers must destructure `state`/`actions`, which adds one extra layer
- If many components only need one field, the grouped return may feel heavier
- A single `navigate(direction)` method is less self-documenting than separate `goToPreviousPeriod` / `goToNextPeriod`

---

### Recommendation

Given your constraint to **minimize method count**, I’d recommend:

- **`state` object**
- **`actions` object with only 2 methods**:
  - `setPeriod(...)`
  - `navigate("prev" | "next")`

That keeps the hook ergonomic while still covering all current behaviors.

If you want, I can also turn this into a **concrete TypeScript interface proposal** matching your existing naming conventions (`maxDateRangeFrom`, `canGoToPreviousPeriod`, etc.) so it can be dropped into the codebase with minimal changes.