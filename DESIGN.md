---
version: alpha
name: Bayaa ERP
description: A bilingual retail console with compact invoice cards and image-led product shelves.
colors:
  primary: '#1E3A8A'
  secondary: '#2563EB'
  accent: '#F97316'
  sidebar: '#182E45'
  background: '#F8FAFC'
  surface: '#FFFFFF'
typography:
  sans:
    fontFamily: Cairo
rounded:
  DEFAULT: '12px'
  lg: '16px'
spacing:
  control-gap: '8px'
  card-gap: '12px'
  page-padding: '24px'
components:
  button: {}
  card: {}
  dialog: {}
  table: {}
---
# Bayaa design system

## Overview

### Creative North Star
A retail counter workspace: numbered invoice tickets, a browsable product shelf, and a clearly bounded current order. The user's supplied invoice photograph defines card/filter hierarchy; the original Bayaa brand defines colors and assets.

### Product context and register
Retail staff preview a phase-one ERP on desktop, tablet, and phone. Product register, Arabic RTL and English LTR, Cairo typography and Egyptian currency. All examples are local; operational actions show preview feedback. Existing asset files remain unchanged. Avoid importing the reference's green branding, tiny text, or unrelated warranty features.

### Token ownership/runtime mapping
`lib/shared/theme/theme_controller.dart` owns the original palette. `app_colors.dart` exposes roles; `app_theme.dart` and `brand_palette.dart` notify widgets when appearance changes. This file documents intent and mirrors those defaults; it does not generate a second token source.

## Colors
Navy frames the workspace and monetary hierarchy, secondary blue identifies navigation/actions, orange identifies the main create/order action. White bounded surfaces sit on the pale page. Text and border roles derive from AppColors. Refunds/errors retain red and labels; stock warnings use text and amber.

## Typography
Cairo for Arabic and English. Page headings 22–26px, monetary values 18–24px, record names 14–16px, dense table labels 11–12px. Numeric columns align consistently; long names wrap or ellipsize with details available.

## Layout
The existing shell uses a drawer below1024px. Content adapts to its available width. Summary tiles wrap into two columns on narrow layouts. Product cards target220px and invoice cards210px; phones show a single column. Full pages scroll, including filters, so controls cannot consume the entire viewport. Tables scroll horizontally and paginate in their own shared surface. Forms account for keyboard insets.

## Elevation & Depth
Hairline borders define list/filter/card surfaces. Hover/focus tints signal actions; reserve shadows for dialogs and the original branded login treatment.

## Shapes
Cards14–16px, pills7px, controls8px. Keep the existing shell shape and original logos.

## Components

### Foundational visual states
Material focus/hover/pressed states; explicit no-results guidance and filter reset; shared skeletons; localized preview feedback. No fake network status or operational success.

### Buttons and actions
One orange create/order action where appropriate; navy/blue outline or text secondary actions. Destructive preview icons remain separated and labeled with tooltips.

### Navigation and data display
WorkspaceDataTable owns local sorting, pagination, alternating rows, numeric alignment, and horizontal overflow. Products and invoices default to card grids. Expense records transform to cards on narrow layouts.

### Forms and overlays
Flutter maintained Material dialogs, DropdownButtonFormField and showDatePicker own keyboard/focus behavior. Search clears locally and restores focus. Editing preserves values until dismissal; submitting only previews an action.

### Iconography
Material outlined retail icons and existing Lucide icons; labels remain on primary actions, tooltips name icon-only controls.

### Motion
Shared skeleton/shimmer and Hero transitions reuse existing owners. Respect disableAnimations; no continuous ornamental motion.

### Content and data visualization
All figures are static examples or display-only aggregates of sample records. Chart panels remain available via the shell. Labels use the active locale; no unimplemented warranty or stock-write capabilities are implied.

## Current workspace refinements
The generic collapsible Insights strip is removed. Feature-owned charts remain inline; the dashboard financial comparison and seven-day trend occupy full-width cards. Dense product/invoice grids use six columns from1080px of available content width, fewer columns on smaller surfaces. CachedNetworkImage owns network images through AssetImageView; local brand assets remain asset-backed. WorkspaceDataTable, ERP records, and bounded legacy table adapters offer table/card views. The branch selector controls transient display scope and section visibility; it is a preview UI, not authorization enforcement.
