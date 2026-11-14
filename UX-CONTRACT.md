# UX Contract

## Product context
Bayaa phase-one frontend for retail staff. Arabic RTL and English LTR; local dates and EGP. The user requests UI-only previews, preserved assets/default theme, responsive layouts and no tests. Source: README.md, docs/FRONTEND_ARCHITECTURE.md and current user instructions.

## Canonical UI Map

| Capability | Canonical owner | Source of truth | Allowed variants | Verification |
|---|---|---|---|---|
| Table Selection | WorkspaceDataTable | Selection is not needed; no bulk writes in this phase | sortable, paginated | docs/UI_REFINEMENT.md |
| Select/Listbox | Flutter DropdownButtonFormField | Material keyboard/focus contract | authored Material popup | docs/UI_REFINEMENT.md |
| Date | Flutter showDatePicker | Active locale, local calendar date | Material calendar | docs/UI_REFINEMENT.md |
| Form | Flutter Form/TextFormField, existing product dialogs | Preview-only submit; preserve typed values | create/edit preview | docs/UI_REFINEMENT.md |
| Scrollbar | Flutter ScrollView | Responsive page overflow and bounded horizontal table overflow | vertical page/horizontal table | docs/UI_REFINEMENT.md |
| Toast | shared/feedback/preview_action.dart | Localized preview feedback | informational | docs/UI_REFINEMENT.md |
| CRUD | Feature dialogs and shared preview_action | No record mutation, persistence, or transactions | view/edit preview/cancel | docs/UI_REFINEMENT.md |

## Behavior
Navigation and filters work locally. No business operation is connected. Queries remain transient widget/controller state by explicit phase-one scope. Clearing search is immediate. Reset clears search and filters. Cards link to details; mobile transformations retain meaningful actions. Tables paginate and sort copies without mutating example records. No selection or bulk-action UI is presented.

Dialogs use maintained Material modal semantics, keyboard dismissal and focus behavior. Icon controls have localized tooltips. Secret input is masked by default and supports an explicit visibility toggle. No credentials are validated or stored. No test files or test commands are permitted by the user.
