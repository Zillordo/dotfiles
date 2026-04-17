# Task for worker

Design an interface for the hook `useCashflowTimePeriodFilter` in `/home/allank/Documents/work/fidoo-fx-fe/provider-bw/libs/bw-react-cockpit/src/lib/hooks/useCashflowTimePeriodFilter.ts`.

Requirements:
- The hook manages selected period state for cashflow charts.
- Inputs: column count, BE-provided min/max date bounds, companyId.
- Outputs currently include dateFrom/dateTo, interval (1W/1M), selectedDay, setters, previous/next navigation, canNavigate booleans, and min/max bounds.
- It synchronizes URL query params + session storage through an internal period-state helper.
- It clamps selected dates to bounds and recalculates visible date range when interval/columns/bounds change.
- Callers are likely chart/table components and tests.

Constraints for this design:
- Optimize for the most common case — a chart component that only needs to render a window and let the user move period-by-period.

Output format:
1. Interface signature (types/methods)
2. Usage example (how caller uses it)
3. What this design hides internally
4. Trade-offs of this approach