# Bayaa ERP — phase one frontend

## Scope

Preserve the original Bayaa assets, colors, typography, and visual identity.
Refactor every existing feature into consistent presentation folders and add
Customers, Suppliers, Purchases, Purchase Returns, Finance, and Stores/Warehouses.
Keep static examples. No authentication enforcement, persistence, transactions,
stock writes, printing, exports, or backend integrations. No test files.

## Boundaries

- `app/`: application composition, startup, navigation, responsive ERP shell.
- `shared/theme/`: original default palette and in-memory theme customization.
- `shared/layout/`: content-based breakpoints and adaptive page/table layouts.
- `shared/widgets/`: reusable cards, toolbars, tables, forms, skeletons, shimmer,
  and accessible motion primitives.
- `features/<feature>/presentation/`: screens, focused widgets, UI controllers,
  display models, and read-only source contracts.
- `preview/`: fresh example content and source implementations.

Widgets receive presentation values and callbacks. Source contracts keep UI
controllers independent of sample implementations. Shared ERP pages are composed
from typed view specifications rather than copied layouts. Each feature owns its
copy, table columns, detail sections, and form fields. Only UI state changes.

## Responsive and motion rules

Layouts adapt to available width, not operating-system names. Compact views use
drawers, stacked cards and full-width forms; wide views use navigation/sidebar,
tables and multi-column forms. Long content wraps or scrolls within bounded
regions. Respect safe areas, keyboard insets, RTL, text scaling, and reduced
motion. Hero transitions connect record cards and detail views. Shared skeleton
and shimmer widgets provide visual loading states without data operations.

## Theme

Bayaa's existing palette is the default. A shared appearance controller exposes
primary, secondary, accent, navigation and surface colors. Appearance controls
update all feature tokens in memory and offer Reset to Bayaa defaults. Assets
are never recolored. No preference storage is added in this phase.

## Verification

Use static analysis, a browser build, and manual UI checks across compact and
wide layouts in Arabic and English. Native builds require the relevant host
toolchain. Do not create or run tests, per the user's request.
