# Task for worker

Design an interface for merging two React components in provider-bw/libs/bw-react-cockpit cashflow table: CashflowTableCellComponent and CashflowTableSummaryValueCellComponent.

Requirements and constraints same as provided.

For THIS design, optimize for the most common current cases and minimal call-site churn. Keep the public interface close to the existing props and make the merged API easy to migrate to from the current two components. Still hide highlight/click/color/styling internals.

Output format: 1. Interface signature 2. Usage example 3. What this design hides internally 4. Trade-offs of this approach