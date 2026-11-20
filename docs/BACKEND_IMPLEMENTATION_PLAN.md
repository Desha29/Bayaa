# Bayaa Backend and Database Implementation Plan

## Goal

Move Bayaa from a presentation-only ERP preview to a secure, branch-aware retail system while preserving its Flutter UI, Arabic/English support, and existing visual identity. Build business workflows as small vertical slices so every persisted action has clear rules and an auditable result.

## Current project boundary

Bayaa currently contains frontend screens and in-memory preview interactions for dashboard, POS and sales, invoices, products and categories, stock summary and alerts, branches and warehouses, customers, suppliers, purchases and purchase returns, expenses, finance, analytics, notifications, and settings. Preview records are examples; they are not a production database or a migration source of truth. Keep the UI usable while backend work is introduced feature by feature.

## Proposed architecture

- **Client:** Flutter remains responsible for presentation, local form state, navigation, responsive layouts, and rendering receipts and reports.
- **Application backend:** Start with one modular backend, divided into identity, catalog, inventory, sales, purchasing, finance, and reporting areas. Keep business rules on the server and expose stable, documented operations to Flutter.
- **Database:** Use PostgreSQL as the authoritative store for related branch, product, stock, invoice, payment, purchase, and finance records.
- **File storage:** Store product images and any later attachments in private object storage; persist metadata and access paths in the database.
- **Reporting:** Build analytics from persisted business records and branch-scoped queries. Do not persist chart presentation values as business facts.

This is a starting recommendation. Choose the backend host and API style after confirming deployment region, ownership, expected offline use, and operations capacity. Avoid splitting into microservices during the first implementation.

## Core data model

Use UUID primary keys, explicit foreign keys, timestamps, and organization/branch scope where applicable. Add indexes for common lookups such as barcode, SKU, invoice number, branch, status, and business date.

| Domain | Initial records |
|---|---|
| Organization and access | organizations, branches, warehouses, users, memberships, roles, permissions |
| Catalog | products, categories, product-category links or parent categories, units, product units, barcodes, image metadata |
| Inventory | stock movements, current stock balances, stock transfers, adjustments, receiving records |
| Sales | invoices, invoice lines, customers, payments, refunds, sales returns |
| Purchasing | suppliers, purchase orders, purchase lines, receipts, purchase returns |
| Finance | expense categories, expenses, cash/bank accounts, financial transactions, journal entries |
| Platform | audit events, notification records, numbering sequences, business settings |

Use integer minor units for money values, with an explicit currency code. Store quantity using a deliberate decimal precision based on product units. Keep invoice and stock history traceable to their source record and branch.

## Business rules to settle before implementation

1. Is Bayaa for one company or multiple organizations?
2. Which roles can view or change each branch, approve discounts, void invoices, issue refunds, adjust stock, and edit catalog records?
3. Can checkout sell below available stock? Can stock be backdated or adjusted after a period closes?
4. What currency, tax, invoice numbering, receipt fields, and fiscal requirements apply in each operating region?
5. Must POS work offline? If yes, which operations may queue locally and how will conflicts be resolved?
6. Are customer/vendor balances and finance summaries sufficient initially, or is a full double-entry accounting ledger required?

Record answers and unresolved assumptions before creating production migrations.

## Critical invariants

- The backend checks both user permission and branch membership on every request; a selected branch in the UI is never treated as authorization.
- A completed sale writes its invoice, lines, payment records, and stock movements in one database transaction.
- Stock changes are represented by append-only movements. Corrections use reversing or adjusting movements with a reason and actor.
- A return or refund references its original sale and cannot exceed the eligible quantity or amount under the approved return policy.
- A purchase receipt changes stock only for quantities actually received; a purchase return links to the original receipt or purchase.
- Transfers create paired movements from the source and destination locations and cannot silently create or lose stock.
- Finalized invoice numbers are unique within the agreed numbering scope. Voids and refunds retain history instead of erasing posted records.
- Important actions write an audit event containing actor, timestamp, branch, action, and target record.
- Retrying a network request must not create a duplicate invoice, payment, receipt, or stock movement; define idempotency keys for posting operations.

## Delivery phases

### Phase 0 — Requirements and domain audit

- Review the Flutter screens, preview models, navigation, and current UI contracts.
- Map each visible action to a future command, query, or UI-only action.
- Confirm the six business-rule questions above, tax and receipt requirements, deployment region, and role matrix.
- Deliver: domain glossary, workflow diagrams, endpoint/API boundary proposal, data ownership map, and a prioritized migration plan.

### Phase 1 — Backend foundation and access

- Create environment configuration, schema migration process, authentication, organizations, branches, memberships, role checks, and audit history.
- Define API error shapes, pagination, date/time conventions, currency handling, and request idempotency.
- Deliver: authenticated branch-scoped read path for a small settings/profile slice, plus staging deployment and backup policy.

### Phase 2 — Product catalog

- Persist products, categories/subcategories, units, barcodes, prices, active status, and image metadata.
- Connect product and category screens to server queries and commands while retaining the current layout.
- Deliver: search, filtering, create/edit, duplicate barcode handling, and development-only seed catalog.

### Phase 3 — Inventory

- Add warehouse stock balances, movement ledger, receiving, adjustments, and branch/warehouse transfers.
- Define concurrency behavior for simultaneous checkouts and receiving.
- Deliver: stock summary and low-stock screens backed by the ledger, with a reconciliation report.

### Phase 4 — POS, invoices, and returns

- Add branch-aware checkout, invoice numbering, line pricing, discounts/tax policy, payment methods, and receipt data.
- Persist sale posting atomically with stock movements and payments; connect refunds and returns to the original invoice.
- Deliver: invoice list/details, 80 mm and A4 receipt rendering from saved invoices, and documented void/refund rules.

### Phase 5 — Purchasing, suppliers, and expenses

- Add supplier records, purchase orders, received quantities, purchase returns, and expense posting.
- Link receiving to stock movements and finance entries according to the confirmed accounting scope.
- Deliver: branch-scoped purchasing and expenses with audit history and clear status transitions.

### Phase 6 — Finance and analytics

- Implement cash/bank activity and balances; add a journal ledger if required by the accounting decision.
- Replace sample charts with server-side aggregates that honor branch, date, and access filters.
- Deliver: reconciliation views, consistent dashboard totals, and traceable analytics definitions.

### Phase 7 — Notifications, migration, and rollout

- Persist notification events and read state; specify the events that trigger notifications.
- Map preview examples to development seed data only. Import real operational data through a separately reviewed mapping and reconciliation process.
- Deliver: migration rehearsal, backup restore verification, access review, production rollout checklist, and support runbook.

## Frontend integration approach

- Keep widgets dependent on typed feature-facing repositories or services instead of direct database details.
- Add loading, empty, validation, success, and recoverable error states without changing the established Bayaa theme.
- Replace one feature's preview source at a time; preserve the same screen contracts until the live source is ready.
- Do not show a successful save/payment result until the backend confirms the operation.
- Keep local sample data isolated from production configuration and visibly identified as demo content.

## Developer tools for this repository

### Floorplan — architecture blueprint and code map

Use the user-requested [Floorplan repository](https://github.com/haydenschmitty/floorplan) as a development-time architecture tool. It can generate a blueprint from this plan before backend code exists, then map the Flutter and backend repositories and trace screen-to-endpoint flows as implementation proceeds. It is not a Bayaa runtime dependency and does not implement business rules or the database.

In Codex, add the `haydenschmitty/floorplan` marketplace and install its `floorplan` plugin, then use `$floorplan` with this plan as the blueprint source. After backend code is added, ask Codex to update the floorplan from the code. The generated map is intended to remain outside Git; keep the plan in `docs/` as the reviewed source of requirements.

Useful map flows to request:

- POS checkout → branch authorization → invoice posting → payment → stock movement → receipt preview
- Purchase order → receipt → stock movement → supplier balance
- Sales return → refund → inventory restock decision → finance activity
- Branch selector → authorization scope → analytics and stock queries

The repository README describes the tool's code scanning and blueprint workflow. Its documented language list does not specifically call out Dart, so check Flutter coverage in the generated map and manually review Dart paths if they are not represented.

## Completion criteria for backend rollout

- Each persisted write has an agreed permission, validation rule, audit event, and failure response.
- Branch-level reads and writes are checked on the server and verified with accounts from different roles/branches.
- Sale, receiving, transfer, and return operations preserve stock and financial invariants under retries and failures.
- Preview data cannot leak into production, and production data can be backed up and restored.
- Existing responsive Arabic/English UI remains usable across the supported screen sizes.
- No feature reports success before its persisted operation is confirmed.

## Explicit exclusions for this planning change

This document does not connect a backend, create database migrations, change UI behavior, or create test files. Those are implementation steps after the business rules and deployment choices are confirmed.
