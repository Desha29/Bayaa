# crazy_phone_pos

**Crazy Phone POS** is a local desktop Point of Sale (POS) system built with **Flutter**.  
It is designed for mobile phone shops to handle daily sales, inventory, and notifications in a clean and professional way.

---

## ✨ Features
- 📊 **Dashboard**: Quick overview of sales, products, low stock, and notifications.  
- 💰 **Sales (Cashier Screen)**: Scan QR/Barcode to add products, manage cart, and checkout easily.  
- 📦 **Product Management**: Add, edit, delete, and search products with stock levels.  
- ⚠️ **Out of Stock Page**: Dedicated page to track low and out-of-stock items.  
- 🔔 **Notifications**: Local alerts when stock is low or products are unavailable.  
- 👥 **Multi-user support**: Different roles for **Admin** (manage system, products, users) and **Cashier** (sales only).  
- ⚙️ **Settings**: Manage store info, users, and local database backup/restore.  
- 💻 **Offline-First**: Works locally without internet using SQLite/Hive.  

---

## 🖥️ Tech Stack
- [Flutter](https://flutter.dev/) (Desktop – Windows/Linux/MacOS)  
- [Bloc / Cubit](https://bloclibrary.dev) for state management  
- [Hive](https://docs.hivedb.dev) for local database  
- Local notifications  
- QR/Barcode scanner integration  

---

## 🚀 Getting Started

### Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install)  
- Set up Flutter for **desktop development** (enable Windows/Linux/MacOS support).  

### Run the project
```bash
# Clone the repository
git clone https://github.com/Desha29/crazy_phone_pos.git

# Enter the project folder
cd crazy_phone_pos

# Get dependencies
flutter pub get

# Run the app (desktop)
flutter run -d windows   # for Windows
flutter run -d linux     # for Linux
flutter run -d macos     # for MacOS
