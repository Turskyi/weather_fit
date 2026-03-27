# WeatherFit — Copilot Instructions

These rules apply to every interaction with GitHub Copilot in this project.
To add a new rule, say: **"Add this to the project rules: <your rule>"** and
the agent will append it to this file.

---

## Scope & Changes

- Only change what was explicitly requested. Do not refactor, rename, or
  "improve" surrounding code that was not mentioned.
- Do not add extra features, fallback handling, or "nice to have" extras
  unless asked.

## Dart / Flutter Style

- Follow the existing code style in the file being edited. Do not introduce
  new patterns or styles.
- Prefer explicit `else` over early return (guard clause). When an `if` block
  returns, always use an explicit `else` for the remaining branch — do not fall
  through:

  ```dart
  // ✅ preferred
  if (selectedLocation.isEmpty) {
    return true;
  } else {
    return selectedLocation.isSamePlaceAs(location);
  }

  // ❌ avoid
  if (selectedLocation.isEmpty) {
    return true;
  }
  return selectedLocation.isSamePlaceAs(location);
  ```

- Prefer positive condition checks over negated guard clauses.
  Avoid `if (!condition) return;` when the same logic can be written as a
  positive `if` with explicit `else`.

- Prefer `else if` over nesting `if` inside `else` when branches are
  mutually exclusive.

- Use `final` for all local variables that are not reassigned.
- Prefer named parameters for widget constructors.
- Use `const` constructors and `const` widgets wherever possible.
- Do not add `// ignore:` comments — fix the issue properly instead.
- Do not suppress analyzer warnings; resolve them cleanly.

## State Management (Bloc)

- Use Bloc patterns already established in the project — do not introduce new
  state management approaches.
- Dispatch events rather than calling methods directly on Blocs.
- Do not read `context` across `async` gaps — capture needed values before
  `await`, then guard with `if (mounted)`.

## Platform / Responsive Layout

- The project targets watch (extra-small), phone (narrow), and wide
  (tablet/desktop/web).
- `isExtraSmallScreen` and `isWearDevice` are the canonical checks for
  Wear OS / watch layouts.
- `kWideLayoutBreakpoint` is the canonical threshold for wide layouts.
- Navigation arrows between locations are shown only on watch and wide screens;
  phones use swipe.

## File & Import Hygiene

- Remove unused imports immediately when refactoring.
- Use one class per file and name the file after that class.
- Do not create Markdown summary files after making changes.

## Validation Before Completion

- Before saying a task is complete, always run `flutter analyze .`.
- Address all analyzer problems introduced by the task before reporting
  completion.

---

_Last updated by agent on 2026-03-27._
