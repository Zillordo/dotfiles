# Task for worker

Design an interface for refactoring the duplication between MonthPicker.tsx and WeekPicker.tsx in bw-react-cockpit cashflowFilterControls.

Requirements:
- Both consume selectedDay/maxDateRangeFrom/maxDateRangeTo from time period controls, track local value and view state, and render StaticCalendar with range props.
- Differences are views/openTo, calendar sizing, change callback semantics (month when view===month vs week when view===day), and WeekPicker custom day slot behavior.
- Recommend an interface to share common controlled-calendar logic while allowing mode-specific configuration and optional custom day renderer.

Constraint for this design: Take inspiration from a headless hook + thin view paradigm.

Output format:
1. Interface signature
2. Usage example
3. What this design hides internally
4. Trade-offs of this approach