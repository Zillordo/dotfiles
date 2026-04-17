# Task for worker

Design an interface for refactoring the duplication between CashflowTableCell.tsx and CashflowTableSummaryValueCell.tsx in bw-react-cockpit cashflow table.

Requirements:
- Both components render clickable, highlight-aware cashflow table value cells.
- Both share column selection, default click behavior from dateFrom via setPeriod(dayjs(dateFrom)), common TableCell styling, bold/color modes.
- One variant renders formatted amount with optional progress bar; the other renders currency amount plus optional quality indicator and nullable value handling.
- Recommend an interface to remove duplication without over-coupling content rendering.

Constraint for this design: Minimize method/component count - aim for 1-3 exported APIs max.

Output format:
1. Interface signature
2. Usage example
3. What this design hides internally
4. Trade-offs of this approach