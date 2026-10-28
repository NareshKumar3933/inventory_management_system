# Inventory Management System

A simple inventory app for Web/Desktop made with Flutter.

This README is written for non-technical users first, so you can understand:
- what the app does,
- what each screen means,
- how stock is updated,
- and how to run the project on Web.

## What This App Does

This app helps you manage product stock in 4 simple steps:

1. Add products in `Products`.
2. Record stock changes in `Movements`.
3. Monitor totals and alerts in `Dashboard`.
4. Download reports from `Export`.

## How the App Works (Simple)

Think of it like a digital stock register.

- `Products`: your master item list.
- `Movements`: every stock change record.
- `Dashboard`: quick business summary.
- `Export`: download CSV files for reports.

### Stock Rules

- `Stock In`: increases quantity.
- `Stock Out`: decreases quantity.
- `Adjustment`: sets the quantity to an exact value.
- Quantity can never go below `0`.

### Initial Quantity vs Minimum Level

- `Initial Quantity`: stock you have when creating a product.
- `Minimum Level`: warning threshold (low-stock alert line).

Example: if quantity is `50` and minimum level is `10`, alert starts when stock is `10` or less.

## Screen-by-Screen

### Dashboard

Shows:
- Total products
- Total stock units
- Low-stock count
- Recent movements
- Stock by category chart

### Products

You can:
- Create product
- Edit product
- Deactivate/reactivate
- Delete product
- Search and filter

Important validations:
- SKU must be unique.
- Required fields must be filled.

### Movements

You can record:
- Stock In
- Stock Out
- Adjustment

When saved:
- product quantity updates automatically,
- movement history is stored.

### Export

Download:
- Product CSV
- Movement CSV

## First Launch Behavior

On first app run, demo/sample data is inserted automatically so you can test quickly.

## Data Storage (Important)

This app uses **Hive** local database.

- Data is saved locally on your machine/browser profile.
- If browser storage is cleared, data will be removed.
- If you run in incognito/private mode, data may not persist.

## How To Run on Web (Step-by-Step)

### 1. Install Requirements

- Flutter SDK
- Chrome browser

Check Flutter:

```bash
flutter doctor
```

### 2. Open Project Folder

```bash
cd f:\StudioProjects\inventory_management
```

### 3. Install Packages

```bash
flutter pub get
```

### 4. Run in Chrome

```bash
flutter run -d chrome
```

### 5. Stop App

In terminal, press:

```text
Ctrl + C
```

## Run on Desktop (Optional)

```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## Build Commands

```bash
flutter build web
flutter build windows
flutter build macos
flutter build linux
```

## Helpful Commands

```bash
flutter analyze
flutter test
```

## Technical Stack

- Flutter
- GetX
- Hive
- DataTable2
- fl_chart
- intl

## Project Structure

```text
lib/
  core/        # constants, theme, utils
  data/        # models + services
  features/    # dashboard, products, movements, export
  routes/      # app pages + bindings
  main.dart
```

## Version

`1.0.0`
