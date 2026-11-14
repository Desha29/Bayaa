# Bayaa ERP — frontend preview

Flutter presentation-only retail ERP, preserving Bayaa's original assets, default colors, and Arabic/English interface.

## Run

```powershell
flutter pub get
flutter run -d chrome
```

Click Login to enter the preview. No credentials are required. Windows builds require the Visual Studio desktop C++ toolchain.

## Included

Dashboard, Sales, Invoices, Customers, Products, Stock Summary, Low Stock, Stores/Warehouses, Purchases, Purchase Returns, Suppliers, Finance, Expenses, Analytics, Notifications, and Settings.

Each workspace includes example charts. Shared widgets provide responsive tables/cards, record details, forms, skeletons, shimmer, and Hero transitions. Appearance settings customize six color roles in memory and restore the original Bayaa palette.

Navigation, filters, searches, dialogs, and cart controls work locally. Save, payment, refund, export, printing, backup, and delete actions only show preview feedback. No backend or business persistence is connected.

## Code organization

- `lib/app/`: startup, dependency composition, module navigation, responsive shell.
- `lib/shared/`: theme, layout, feedback, localization, reusable presentation widgets.
- `lib/features/`: focused presentation screens, widgets, controllers, display models, and read-only source contracts.
- `lib/preview/`: static examples and read-only sample sources.

See [preview usage](docs/UI_PREVIEW.md) and [frontend architecture](docs/FRONTEND_ARCHITECTURE.md).

The [Superdesign customer workspace reference](https://p.superdesign.dev/draft/7a719fe9-16e5-43ec-a11c-27ce8e109e0f) supports the shared ERP interface direction. The Flutter implementation retains the original local brand assets.

No test files are included or required for this phase, as requested.
