# Task for worker

Design an interface for merging two React components in provider-bw/libs/bw-react-cockpit cashflow table: CashflowTableCellComponent and CashflowTableSummaryValueCellComponent.

Requirements and constraints same as provided.

For THIS design, take inspiration from compound components / slot-based MUI APIs. Prefer an interface that can grow to support multiple cell content subtypes and accessories without adding many top-level props. Still hide highlight/click/color/styling internals.

Output format: 1. Interface signature 2. Usage example 3. What this design hides internally 4. Trade-offs of this approach