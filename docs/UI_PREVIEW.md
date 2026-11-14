# UI preview

Run `flutter pub get`, then `flutter run -d chrome`. Click Login; credentials are not checked. Arabic is the default, and the language control switches to English.

## Example content

Edit `lib/preview/data/preview_data.dart` for sample products, users, invoices, refunds, expenses, and stock summaries. Dates are relative to startup. Feature view specifications under `lib/features/<feature>/presentation/views/` contain the six ERP workspaces' example records. Chart examples live in `lib/preview/data/feature_chart_examples.dart`.

Navigation, tabs, filters, searches, dialogs, and cart controls are interactive. Sales starts with two sample items. Reloading restores all examples. Save, checkout, refund, restock, delete, image selection, print, share, backup, and restore show localized preview feedback. PDF rendering supports the existing document preview widgets only.

Checkout requires an invoice branch. It starts with the active branch when one is selected and opens an unsaved receipt or A4 preview with the chosen branch and payment method. The checkout choice does not change the workspace branch.

Analytics groups reporting into Overview, Sales & Invoices, Inventory, Purchasing, Finance, and Operations. Sales and expense figures use the selected date range and branch. Inventory, user roles, and ERP record status charts are snapshots; they are labeled separately from period figures. The charts and summary values use the same local examples as the corresponding workspaces.

## Theme and layout

Original assets are preserved. Settings > Appearance customizes primary, secondary, accent, navigation, page background, and surface colors in memory. Reset restores the original palette. No preferences are saved.

The shell uses a drawer below 1024px. New module records switch from tables to cards below 900px or at large text scales. Forms wrap and scroll to fit available space. Shared motion widgets respect reduced-motion settings.

## Verification

The debug web build and static analysis were checked. Manual browser review covered Arabic/English, compact layouts down to 320px, desktop layouts, module navigation, detail/form previews, charts, and appearance controls. A local Material surface around the shared chart ExpansionTile prevents Flutter's hidden ListTile background/ink assertion.

No tests were created or run. Native Windows compilation requires the missing Visual Studio desktop C++ toolchain; other native platforms need their respective host toolchains.

Unused source files were identified by following imports from `lib/main.dart`. Obsolete business infrastructure, unused dependencies, temporary refactor scripts, unused bundled SDK copies, and empty source directories were removed. Original assets and platform runners are retained.
