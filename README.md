<p align="center">
  <img src="assets/images/Icon_app.png" alt="Bayaa POS logo" width="120" />
</p>

<h1 align="center">Bayaa POS</h1>

<p align="center">
  <strong>An offline-first point-of-sale and retail-management desktop application.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Desktop-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Desktop" />
  <img src="https://img.shields.io/badge/Dart-3.6+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3.6 or later" />
  <img src="https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows" />
  <img src="https://img.shields.io/badge/Database-SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
</p>

## Overview

Bayaa POS is a Flutter desktop application for retail businesses that need dependable checkout, stock control, invoices, refunds, reporting, and user access management—without relying on an internet connection or external server.

The application stores its data locally in SQLite, supports Arabic and English interfaces, and is designed for fast day-to-day work at the counter.

## Highlights

- **Offline-first** — sales and inventory data remain on the local machine.
- **Fast checkout** — barcode scanner support, product search, cart editing, and price validation.
- **Arabic and English** — localized UI with right-to-left support for Arabic.
- **Role-based access** — separate Manager and Cashier capabilities.
- **Invoices and refunds** — A4 invoices, 80 mm receipts, partial refunds, and stock restoration.
- **Operational visibility** — sales, profit, inventory, notifications, sessions, and audit history.

## Core capabilities

| Area | What it provides |
| --- | --- |
| Sales | Barcode or manual product lookup, cart management, quantity control, price validation, and checkout. |
| Invoices | Searchable invoice history, PDF preview, printing, A4 invoices, and 80 mm thermal receipts. |
| Refunds | Item-level partial refunds linked to their original invoice, with automatic stock restocking. |
| Inventory | Product and category management, stock levels, restocking, low-stock alerts, and stock valuation. |
| Reports | Daily reports, sales and refund analysis, top products, session history, and stock summaries. |
| Administration | User roles, store information, backup and restore, activity logging, and application settings. |

## Roles and permissions

| Capability | Manager | Cashier |
| --- | :---: | :---: |
| POS checkout and invoice viewing | ✓ | ✓ |
| Partial refunds | ✓ | ✓ |
| Product management | ✓ | ✓ |
| Stock alerts and notifications | ✓ | ✓ |
| Invoice deletion and bulk deletion | ✓ | — |
| Reports, analytics, and session history | ✓ | — |
| User management and data backup/restore | ✓ | — |

## Screenshots

| Login | Sales workspace |
| :---: | :---: |
| ![Login screen](Screenshots/login.png) | ![Sales screen](Screenshots/sales.png) |

| Dashboard | Invoice management |
| :---: | :---: |
| ![Manager dashboard](Screenshots/Manger/manger_dashboard.png) | ![Manager invoices](Screenshots/Manger/manger_invoices.png) |

| Inventory | Daily reporting |
| :---: | :---: |
| ![Product management](Screenshots/Manger/manger_product.png) | ![Daily report](Screenshots/Manger/daliy_report1.png) |

More application views are available in the [`Screenshots`](Screenshots) directory.

## Technology

| Concern | Technology |
| --- | --- |
| Desktop framework | Flutter and Dart |
| State management | BLoC / Cubit (`flutter_bloc`) |
| Local storage | SQLite (`sqflite_common_ffi`) |
| Dependency injection | GetIt |
| Documents | `pdf` and `printing` |
| Analytics visualizations | `fl_chart` |
| Desktop window controls | `window_manager` |
| Localization | Flutter localization with Arabic RTL support |

## Architecture

The codebase uses a feature-first structure with shared infrastructure in `core` and business capabilities grouped by feature.

```text
lib/
├── main.dart                 Application startup and desktop configuration
├── core/                     Shared services, UI components, theme, security, and data helpers
│   ├── data/                 SQLite, persistence, backup, and shared models
│   ├── di/                   Dependency injection configuration
│   ├── localization/         Locale selection and translation helpers
│   ├── logging/              Application and crash logging
│   └── session/              Shift and active-session management
├── features/
│   ├── auth/                 Login, users, and roles
│   ├── dashboard/            Navigation shell and dashboard
│   ├── invoice/              Invoice history, printing, and refunds
│   ├── products/             Product and category management
│   ├── sales/                Checkout, cart, and barcode workflows
│   ├── sessions/             Shift history and daily reports
│   ├── settings/             Store settings, users, and data management
│   └── stock*/               Stock alerts and stock summary
└── l10n/                     Arabic and English translations
```

## Data and reliability

Bayaa POS creates and maintains its SQLite database locally. It includes backup and restore support, checkpointing, and an activity log for operational events such as sales, refunds, restocks, user activity, and session changes.

Main data groups include store settings, users, products, categories, shifts, sales, sale items, and activity logs.

## Getting started

### Prerequisites

- Windows 10 or later
- Flutter SDK compatible with Dart `^3.6.1`
- Visual Studio 2022 with the **Desktop development with C++** workload

### Run locally

```bash
git clone https://github.com/Desha29/Bayaa.git
cd Bayaa
flutter pub get
flutter run -d windows
```

On first launch, choose a safe location for the application data. Bayaa POS creates and manages its local data files there.

### Build a release

```bash
flutter build windows --release
```

The Windows release is created under:

```text
build/windows/x64/runner/Release/
```

## Contributing

1. Fork the repository.
2. Create a focused branch.
3. Make and verify your changes.
4. Open a pull request with a clear description of the change.

## License

This project is proprietary software. All rights reserved.

<p align="center">
  Built with Flutter by <a href="https://github.com/Desha29">Desha29</a>
</p>
