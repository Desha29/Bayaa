# 📂 Amr Store POS

**Local POS System for Mobile Store (Flutter Desktop)**  
A fast, offline-first, and feature-rich Point of Sale (POS) system built with **Flutter** for desktop environments.  
Amr Store POS helps mobile-phone shops manage **sales**, **stock**, **invoicing**, and **analytics** — all without requiring an internet connection.

---

## 🔍 Features

- 🖥️ **Desktop-optimized POS interface** for mobile-phone stores  
- 📦 **Inventory Management** — Add, edit, and track stock and product details  
- 📱 **Barcode Scanner Support** — Quickly find products using barcode input  
- 🌐 **Offline-First Architecture** — Works entirely offline with **Hive** local database  
- 💳 **Sales & Checkout System** — Create invoices, manage daily transactions  
- 📊 **Analytics & Reports** — View sales summaries and performance insights  
- 🔔 **Notifications** — Real-time updates and alerts  
- ⚙️ **Customizable Settings** — Adjust configurations for your shop  

---

## 🧱 Technology Stack

| Category | Technology |
|-----------|-------------|
| **Framework** | Flutter (Desktop) |
| **Language** | Dart |
| **Local Database** | Hive |
| **Architecture** | Feature-based modular structure |
| **PDF Reports** | Custom report generator |
| **State Management** | Cubit / Bloc |
| **Responsive UI** | Flutter Adaptive Layout |
| **Supported Platforms** | Windows, macOS, Linux |

---

## 🧩 Project Structure

```
lib/
│
├── core/
│   ├── components/               # Reusable UI components
│   ├── constants/                # Static values and configurations
│   ├── di/                       # Dependency injection setup
│   ├── error/                    # Error handling and exceptions
│   ├── functions/                # Common helper functions
│   ├── theme/                    # App themes, colors, and text styles
│   └── utils/                    # Utilities (PDF generator, Hive helper, validators)
│
├── features/
│   ├── arp/                      # Analytics & Reporting
│   ├── auth/                     # Authentication
│   ├── dashboard/                # Dashboard UI
│   ├── invoice/                  # Invoice creation and management
│   ├── notifications/            # Notification system
│   ├── products/                 # Product CRUD operations
│   ├── sales/                    # Sales and checkout process
│   ├── settings/                 # Settings and preferences
│   └── stock/                    # Stock and inventory management
│
├── main.dart                     # Application entry point
└── ...
```

---

## ⚙️ Installation & Setup

### 🧾 Prerequisites
- Flutter SDK (latest version with desktop support)
- Dart 3.x or higher
- Android Studio, VS Code, or any preferred IDE

### 🧭 Installation Steps
```bash
# Clone the repository
git clone https://github.com/Desha29/crazy_phone_pos.git

# Navigate into the project
cd crazy_phone_pos

# Get all dependencies
flutter pub get

# Run the desktop app
flutter run -d windows   # or -d macos / -d linux depending on your OS
```

---

## 🧠 Keywords

`desktop-app` `hive` `offline-first` `local-database` `flutter` `inventory-management` `barcode-scanner` `pos-system` `amr-store`

---

## 📸 Screenshots

> *(Add screenshots or GIFs of the dashboard, product list, and sales screens here.)*

Example layout suggestions:
- Dashboard view  
- Product management screen  
- POS (sales) interface  
- Invoice report  

---

## 🧾 License

This project is licensed under the **MIT License** — you’re free to use, modify, and distribute it with proper attribution.

---

## 👨‍💻 Author

**Desha29**  
[GitHub Profile →](https://github.com/Desha29)

---

## ⭐ Support

If you find this project useful:
- Give it a ⭐ on [GitHub](https://github.com/Desha29/crazy_phone_pos)
- Share feedback or issues via the repository’s [Issues](https://github.com/Desha29/crazy_phone_pos/issues) section.

---
