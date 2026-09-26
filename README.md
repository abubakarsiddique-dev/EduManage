# 🎓 EduManage — School Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**EduManage** is a multi-role school management platform built as a Final Year Project. It pairs a cross‑platform **Flutter + Firebase** client with an optional **Node.js/Express REST API** backend, giving Admins, Teachers, Students, and Parents dedicated dashboards for attendance, exams, fees, timetables, and communication.

> Package name: `school_management_system` · Backend: [`edumanage-backend`](./edumanage-backend)

---

## 📱 Overview

The Flutter app is the primary product — it talks directly to **Firebase** (Auth, Firestore, Storage, Cloud Messaging) for real-time data. The Node.js backend in `edumanage-backend/` is a separate, self-contained REST API with its own JWT auth and file-based JSON store; it powers a set of analytics-heavy modules (grade curving, timetable collision checks, leave-impact simulation, system backups) that are documented in its own [backend README](./edumanage-backend/README.md).

### Roles
| Role | Highlights |
|---|---|
| **Admin** | Manage students, teachers, classes, fees, notices; approve pending registrations |
| **Teacher** | Attendance, assignments, exam results, timetable |
| **Student** | View attendance, assignments, results, fees, notices |
| **Parent** | Track linked children's attendance, results, fees, and notifications |

---

## ✨ Features

**Core**
- Role-based authentication with an admin approval flow for new Teacher/Student/Parent sign-ups
- Real-time Firestore-backed dashboards for all four roles
- Attendance marking and history (daily/monthly views)
- Assignments: distribution, deadlines, and submissions
- Exam results and academic records
- Fee invoicing, receipt upload, and admin verification
- Notices & announcements with push notifications (FCM + local notifications)
- Class timetable management
- Dark mode with full Material 3 theming (`themeModeProvider`)
- PDF report generation and CSV data export
- Role-tinted UI: Admin (sky blue), Teacher (emerald), Student (violet)

**Academic analytics engines** (`lib/core/utils/`)
- `GpaCalculator` — 4.0-scale GPA/CGPA with academic standing classification (Dean's List → Academic Probation)
- `ExamAssessmentEngine` — cohort statistics (mean, median, mode, std. dev., IQR), Z/T-scores, percentile ranks, and four grade-curving strategies (anchor-to-max, linear boost, square root, bell curve)
- `SecurityHelper` — input sanitization, XSS/SQL-injection pattern detection, PII masking (email, phone, national ID)
- `AppLogger` — structured, severity-leveled logging with an in-memory ring buffer for diagnostics

**Backend (`edumanage-backend/`, optional REST API)**
- JWT auth with role-based access control (RBAC) and a granular permission matrix
- Exam scheduling, grade submission, and non-destructive curving simulations
- Timetable collision guard (teacher/room/section overlap detection)
- Student leave applications with attendance-deficit impact analysis
- Bulk student admission with atomic rollback
- System snapshot/backup engine with SHA-256 checksum verification
- Audit logging, sliding-window rate limiting, and health/integrity probes

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Client framework | Flutter 3.x, Dart `^3.11.5` |
| State management | `flutter_riverpod` ^3.3.2 |
| Routing | `go_router` ^17.3.0 |
| Backend-as-a-service | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging` |
| Local persistence | `shared_preferences`, `flutter_local_notifications` |
| Charts / PDF | `fl_chart`, `pdf` |
| Media | `image_picker`, `cached_network_image`, `flutter_svg`, `lottie` |
| REST API | Node.js, Express 4, `jsonwebtoken`, `bcryptjs`, `helmet`, `morgan`, `cors` |
| API data store | File-based JSON (`data/edumanage.db.json`) — lightweight, not intended as a production database |

---

## 🗂️ Project Structure

```
school_management_system/
├── lib/
│   ├── core/               # Theme, router, constants, shared utils & engines
│   │   ├── theme/          # AppColors, AppTextStyles, AppTheme
│   │   ├── router/          # go_router configuration
│   │   ├── utils/           # GpaCalculator, ExamAssessmentEngine, SecurityHelper, AppLogger...
│   │   └── widgets/         # Reusable buttons, text fields, dropdowns
│   ├── data/                # Repositories, models, services (notifications, roll numbers...)
│   └── features/            # Feature-first screens
│       ├── auth/             # Login, register, approval flow
│       ├── admin/            # Students, teachers, classes, fees, notices, reports
│       ├── teacher/          # Attendance, assignments, results
│       ├── parents/          # Fee tracking, notifications
│       └── shared/           # Profile, notifications, help, about, legal
├── firebase_options.dart      # FlutterFire-generated config (project: edumanage-1b145)
└── edumanage-backend/         # Standalone Node/Express REST API (see its own README)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.38.4` (stable channel), Dart `>=3.11.5`
- Node.js `>=18` (only needed if you're running the backend)
- A Firebase project (or use the one already wired up in `firebase_options.dart` for local development)

### Run the Flutter app
```bash
git clone https://github.com/mrabukust-cmd/EduManage.git
cd EduManage
flutter pub get
flutter run
```
> `firebase_options.dart` already points at a live Firebase project for development. To use your own project, run `flutterfire configure` and it will be regenerated.

### Run the backend API (optional)
```bash
cd edumanage-backend
npm install
cp .env.example .env
npm run dev      # auto-reloading dev server
# or: npm start   # production
npm test          # runs the automated test suites
```
Default `.env` values: `PORT=5000`, `JWT_EXPIRES_IN=7d`, `CORS_ORIGIN=*`.

### Demo login (backend, seeded data)
```
Email:    admin@edumanage.edu
Password: Password@123
```

---

## 🧪 Testing

- **Backend**: `npm test` runs Node's built-in test runner across the suites in `edumanage-backend/tests/` (auth, exams, timetable conflicts, leaves, bulk enrollment, RBAC, backups, and more).
- **Flutter**: `flutter test` runs the client-side unit tests.

---

## 🤝 Contributing

Contribution guidelines, commit conventions, and architecture rules for both the Flutter client and the Node backend are documented in [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## 📄 License

Released under the [MIT License](./LICENSE).
