Here’s a headless-hook + thin-view interface I’d recommend for sharing the MonthPicker / WeekPicker logic.

## 1. Interface signature

```ts
type CalendarMode = "month" | "week";

type ControlledCalendarState = {
  value: Date | null;
  viewDate: Date;
  setValue: (next: Date | null) => void;
  setViewDate: (next: Date) => void;
  onChange: (date: Date | null) => void;
};

type ControlledCalendarOptions = {
  selectedDay: Date | null;
  maxDateRangeFrom?: Date;
  maxDateRangeTo?: Date;

  mode: CalendarMode;

  /**
   * How the picker should initialize and render.
   */
  openTo: "month" | "day";
  views: Array<"day" | "month">;

  /**
   * Maps the raw calendar change into the controlled value.
   * Example:
   * - month picker: commit when view === "month"
   * - week picker: commit when view === "day"
   */
  resolveChange: (args: {
    date: Date | null;
    view: "day" | "month";
    currentValue: Date | null;
  }) => Date | null;

  /**
   * Optional custom day rendering for week picker or similar variants.
   */
  daySlot?: React.ComponentType<any>;

  /**
   * View-specific sizing and calendar props.
   */
  calendarProps?: Record<string, unknown>;
};

type ControlledCalendarHookResult = {
  value: Date | null;
  view: "day" | "month";
  setView: (view: "day" | "month") => void;
  handleChange: (date: Date | null, view: "day" | "month") => void;
  rangeProps: {
    minDate?: Date;
    maxDate?: Date;
  };
  calendarProps: {
    openTo: "day" | "month";
    views: Array<"day" | "month">;
    value: Date | null;
    onChange: (date: Date | null) => void;
    daySlot?: React.ComponentType<any>;
    [key: string]: unknown;
  };
};

declare function useControlledCalendar(
  options: ControlledCalendarOptions
): ControlledCalendarHookResult;
```

Thin view components:

```ts
type CalendarPickerViewProps = {
  hook: ControlledCalendarHookResult;
  onClose: () => void;
};

declare function MonthPickerView(props: CalendarPickerViewProps): JSX.Element;
declare function WeekPickerView(props: CalendarPickerViewProps): JSX.Element;
```

---

## 2. Usage example

### Month picker

```tsx
function MonthPicker(props: {
  selectedDay: Date | null;
  maxDateRangeFrom?: Date;
  maxDateRangeTo?: Date;
  onChange: (date: Date | null) => void;
  onClose: () => void;
}) {
  const calendar = useControlledCalendar({
    selectedDay: props.selectedDay,
    maxDateRangeFrom: props.maxDateRangeFrom,
    maxDateRangeTo: props.maxDateRangeTo,
    mode: "month",
    openTo: "month",
    views: ["month", "day"],
    resolveChange: ({ date, view }) => (view === "month" ? date : null),
  });

  return (
    <MonthPickerView
      hook={calendar}
      onClose={props.onClose}
    />
  );
}
```

### Week picker

```tsx
function WeekPicker(props: {
  selectedDay: Date | null;
  maxDateRangeFrom?: Date;
  maxDateRangeTo?: Date;
  onChange: (date: Date | null) => void;
  onClose: () => void;
}) {
  const calendar = useControlledCalendar({
    selectedDay: props.selectedDay,
    maxDateRangeFrom: props.maxDateRangeFrom,
    maxDateRangeTo: props.maxDateRangeTo,
    mode: "week",
    openTo: "day",
    views: ["day", "month"],
    resolveChange: ({ date, view }) => (view === "day" ? date : null),
    daySlot: WeekPickerDay,
    calendarProps: {
      sx: { width: 320, height: 340 },
    },
  });

  return (
    <WeekPickerView
      hook={calendar}
      onClose={props.onClose}
    />
  );
}
```

### Thin view implementation idea

```tsx
function MonthPickerView({ hook, onClose }: CalendarPickerViewProps) {
  return (
    <StaticCalendar
      {...hook.calendarProps}
      value={hook.value}
      onChange={(date) => hook.handleChange(date, hook.view)}
      minDate={hook.rangeProps.minDate}
      maxDate={hook.rangeProps.maxDate}
      onClose={onClose}
    />
  );
}
```

---

## 3. What this design hides internally

The hook would encapsulate the duplicated state and coordination logic, including:

- syncing `selectedDay` into local `value`
- tracking current calendar `view`
- computing `minDate` / `maxDate` from `maxDateRangeFrom` and `maxDateRangeTo`
- normalizing change handling so the caller only supplies a semantic `resolveChange`
- handling the “commit on month view” vs “commit on day view” distinction
- preserving local calendar state while the user navigates the picker
- injecting optional custom day renderer behavior for week mode
- packaging the props shape expected by `StaticCalendar`

This keeps the views mostly declarative and mode-specific.

---

## 4. Trade-offs of this approach

### Pros
- Strongly reduces duplication between MonthPicker and WeekPicker
- Makes the shared behavior easier to test in one place
- Keeps the UI components thin and focused on rendering
- Lets each picker vary only by configuration and small custom slots
- Fits the headless hook pattern well

### Cons
- The hook can become “configuration-heavy” if too many knobs get added
- Some logic that was obvious in each component may become less readable at first
- The `resolveChange` abstraction is flexible, but also slightly indirect
- Custom day rendering may still need mode-specific plumbing if `StaticCalendar` expects a very specific slot API

### Practical recommendation
Keep the shared hook narrow:
- state sync
- range derivation
- generic change/view handling

Then expose:
- a small render adapter for `StaticCalendar`
- optional slot overrides for week-specific behavior

That gives you reuse without turning the hook into a god-object.

If you want, I can also turn this into a more concrete TypeScript API shaped around the actual `StaticCalendar` props in bw-react-cockpit.