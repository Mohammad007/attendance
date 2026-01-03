# 📱 Laborbook - Offline Worker Management App

A **100% offline Flutter application** for managing workers, attendance, wages, and payments using **SQLite** database.

## ✨ Features

### 👤 Worker Management
- ✅ Add, edit, and delete workers
- ✅ Assign job types and daily wages
- ✅ Upload worker photos
- ✅ Activate/deactivate workers
- ✅ Search workers by name

### 📅 Attendance Management
- ✅ Daily attendance marking (Present/Absent/Half-day)
- ✅ Overtime hours tracking
- ✅ Calendar view
- ✅ Edit past attendance records
- ✅ Bulk attendance marking
- ✅ Attendance statistics

### 💰 Wage Calculation
- ✅ Automatic wage calculation based on attendance
- ✅ Half-day wage calculation (50% of daily wage)
- ✅ Overtime calculation (1.5x rate)
- ✅ Advance deduction
- ✅ Daily/weekly/monthly summaries
- ✅ Balance tracking

### 💵 Payment Management
- ✅ Record cash payments
- ✅ Track advances
- ✅ Payment history
- ✅ Automatic balance calculation

### 📄 Reports & Wage Slips
- ✅ Generate professional wage slips (PDF)
- ✅ Attendance reports (PDF)
- ✅ Monthly worker reports
- ✅ Export to PDF
- ✅ Share via WhatsApp/Email

### 🔒 Security
- 🔄 App lock with PIN (Coming Soon)
- ✅ All data stored locally
- ✅ No internet required

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── database/
│   └── database_helper.dart           # SQLite database setup
├── models/
│   ├── worker.dart                    # Worker model
│   ├── attendance.dart                # Attendance model
│   ├── payment.dart                   # Payment model
│   └── settings.dart                  # Settings model
├── services/
│   ├── worker_service.dart            # Worker CRUD operations
│   ├── attendance_service.dart        # Attendance operations
│   ├── payment_service.dart           # Payment operations
│   ├── wage_calculation_service.dart  # Wage calculation logic
│   └── pdf_service.dart               # PDF generation
├── providers/
│   ├── worker_provider.dart           # Worker state management
│   ├── attendance_provider.dart       # Attendance state management
│   └── payment_provider.dart          # Payment state management
└── screens/
    ├── dashboard_screen.dart          # Main dashboard
    ├── workers_list_screen.dart       # Workers list
    ├── attendance_screen.dart         # Attendance marking
    ├── wage_summary_screen.dart       # Wage summary
    └── reports_screen.dart            # Reports
```

## 🗄️ Database Schema

### Workers Table
```sql
CREATE TABLE workers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  job_type TEXT NOT NULL,
  daily_wage REAL NOT NULL,
  join_date TEXT NOT NULL,
  photo_path TEXT,
  is_active INTEGER NOT NULL DEFAULT 1
);
```

### Attendance Table
```sql
CREATE TABLE attendance (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  worker_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  overtime_hours REAL DEFAULT 0,
  FOREIGN KEY (worker_id) REFERENCES workers (id) ON DELETE CASCADE
);
```

### Payments Table
```sql
CREATE TABLE payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  worker_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  payment_date TEXT NOT NULL,
  payment_type TEXT NOT NULL,
  note TEXT,
  FOREIGN KEY (worker_id) REFERENCES workers (id) ON DELETE CASCADE
);
```

### Settings Table
```sql
CREATE TABLE settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  language TEXT DEFAULT 'English',
  currency TEXT DEFAULT '₹',
  app_pin TEXT,
  theme_mode TEXT DEFAULT 'light'
);
```

## 🧰 Tech Stack

- **Framework:** Flutter 3.10+
- **Database:** SQLite (sqflite)
- **State Management:** Provider
- **PDF Generation:** pdf, printing
- **Date Handling:** intl
- **UI Components:** Material 3

## 📦 Dependencies

```yaml
dependencies:
  sqflite: ^2.3.0           # SQLite database
  path_provider: ^2.1.1     # File system paths
  provider: ^6.1.1          # State management
  intl: ^0.19.0             # Date formatting
  table_calendar: ^3.0.9    # Calendar widget
  image_picker: ^1.0.5      # Image selection
  pdf: ^3.10.7              # PDF generation
  printing: ^5.11.1         # PDF printing
  share_plus: ^7.2.1        # File sharing
  flutter_slidable: ^3.0.1  # Swipe actions
  flutter_speed_dial: ^7.0.0 # FAB menu
  flutter_secure_storage: ^9.0.0 # Secure storage
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10 or higher)
- Android Studio / VS Code
- Android SDK (for Android builds)

### Installation

1. **Clone or navigate to the project:**
   ```bash
   cd d:\App\attendance
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

## 💡 Usage

### Adding a Worker
1. Go to Dashboard → Workers
2. Tap the "+" button
3. Fill in worker details
4. Save

### Marking Attendance
1. Go to Dashboard → Attendance
2. Select date
3. Mark attendance for each worker
4. Save

### Calculating Wages
1. Go to Dashboard → Wages
2. Select worker
3. Choose date range
4. View calculated wages
5. Generate wage slip (PDF)

### Recording Payments
1. Open worker details
2. Tap "Add Payment"
3. Enter amount and type (Cash/Advance)
4. Save

## 🎨 UI Features

- ✅ Material 3 Design
- ✅ Light & Dark mode support
- ✅ Gradient cards
- ✅ Smooth animations
- ✅ Responsive layout
- ✅ Large, touch-friendly buttons
- ✅ Icon-based navigation

## 📊 Wage Calculation Formula

```
Base Wage = Total Days × Daily Wage
Overtime Wage = (Overtime Hours / 8) × Daily Wage × 1.5
Gross Wage = Base Wage + Overtime Wage
Net Wage = Gross Wage - Total Advances
Balance = Net Wage - Total Paid
```

### Attendance Types
- **Present:** 100% of daily wage
- **Half-day:** 50% of daily wage
- **Absent:** 0% of daily wage
- **Overtime:** 1.5x rate (per hour)

## 🔮 Upcoming Features

- [ ] Multi-language support (Hindi, Tamil, Telugu)
- [ ] App lock with PIN
- [ ] Backup to SD card
- [ ] Import/Export database
- [ ] Bluetooth data transfer
- [ ] QR code-based data sharing
- [ ] Worker self-service portal
- [ ] Biometric authentication

## 📱 Supported Platforms

- ✅ Android 5.0+ (API 21+)
- 🔄 iOS (Coming Soon)
- 🔄 Windows (Coming Soon)

## 🐛 Troubleshooting

### Database not created
```bash
flutter clean
flutter pub get
flutter run
```

### Build errors
```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

## 📄 License

This project is for personal/commercial use.

## 👨‍💻 Developer

Built with ❤️ using Flutter

## 📞 Support

For issues or questions, please check the documentation or create an issue.

---

**Version:** 1.0.0  
**Last Updated:** December 2025
