# LedgerFlow

LedgerFlow is a high-performance personal finance management application built with Flutter. It is designed to simplify daily expense and income tracking through a clean, intuitive interface and powerful on-device analytics. The project follows Clean Architecture principles and utilizes a NoSQL local database for fast, offline-first performance.

## Key Features

- **Dual-Stream Entry System**: Toggle seamlessly between Income and Expense logging with a single tap.
- **Custom Integrated Calculator**: A built-in arithmetic keypad that allows users to perform calculations directly within the amount field, eliminating the need to switch apps.
- **Dynamic Category Management**: Pre-defined categories for common expenses and the ability for users to create custom categories.
- **Visual Analytics Dashboard**:
  - **Monthly View**: Pie charts visualizing expenditure distribution across categories.
  - **Yearly Trends**: Line charts comparing total income versus total expenses over a 12-month period.
- **Search and Filter**: Advanced search functionality to find specific transactions by title, category, or date range.
- **Data Persistence**: Offline-first design using the Hive NoSQL database to ensure data remains secure on the user's device.

## Technical Stack

- **Framework**: Flutter
- **Programming Language**: Dart
- **Database**: Hive (NoSQL)
- **State Management**: Provider
- **Charts**: fl_chart
- **Utilities**:
  - intl (Date formatting)
  - uuid (Unique identifier generation)
---
## Connect With Me
I am a student developer passionate about building tech that solves real-world problems. Let's connect!

* **GitHub:** [github.com/sundramdotdev](https://github.com/sundramdotdev)
* **LinkedIn:** [linkedin.com/in/sundramdotdev](https://linkedin.com/in/sundramdotdev)

## Project Structure

```text
lib/
├── models/      # Data structures and Hive TypeAdapters
├── providers/   # State management logic for UI updates
├── screens/     # Main UI pages (Dashboard, Entry, History)
├── services/    # Database initialization and CRUD operations
├── widgets/     # Reusable UI components (Calculator, Charts)
└── main.dart    # Application entry point and Hive setup
