# EduManage - School Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/mrabukust-cmd/EduManage/actions/workflows/ci.yml/badge.svg)](https://github.com/mrabukust-cmd/EduManage/actions)

EduManage is a comprehensive, multi-role School Management System featuring a cross-platform **Flutter** client (Android, iOS, Web, Desktop) and a high-performance **Node.js/Express** REST API backend with real-time Firebase support.

---

## Key Features

- **Multi-Role Dashboards**: Tailored experiences for Administrators, Teachers, Students, and Parents.
- **REST API + Firebase Dual Support**: Clean, modular API architecture with JWT authentication, query search/pagination, and persistent token caching.
- **Dark Mode & Dynamic Theming**: Complete Material 3 dark palette with `themeModeProvider` support for light, dark, and system theme switching.
- **Standardized UI Feedback**: Responsive `AppToast` floating snackbars and dismissible `AppBanner` alert widgets for consistent user feedback.
- **Robust Form Validation Engine**: Centralized `Validators` suite with email, password, phone, postal code, credit card (Luhn checksum), amount/currency, numeric bounds, score, GPA, URL, sanitizers, and composite rule chaining.
- **CSV Data Export Engine**: RFC 4180 compliant `CsvExporter` for students roster, fee collections, attendance, and exam grades with injection attack protection.
- **DateTime & Formatting Utilities**: Centralized `DateTimeHelper` for ISO parsing, human relative timestamps (`timeAgo`), academic term ranges (`isDateInRange`), session labels (`formatAcademicYear`), fiscal quarters, week boundaries, and deadline calculations.

- **Attendance Management**: Class attendance marking, student percentage tracking, and monthly reports.
- **Assignments & Submissions**: Assignment distribution, deadline reminders, and file submission workflows.
- **Fee Management**: Invoice generation, receipt upload, admin verification, and fee collection analytics.
- **ExamAssessmentEngine & Grade Analytics**: Client-side statistical evaluation engine in Flutter (`ExamAssessmentEngine`) computing cohort distribution metrics (mean, median, mode, sample standard deviation, IQR), standardized Z/T-scores, weighted assessment aggregation, honors classifications, and four curving models (anchorToMax, linearBoost, squareRoot, bellCurve).
- **Exam Management & Automated Curving API**: Express backend exam suite (`/api/v1/exams`) supporting exam scheduling, boundary-validated grade submissions (`0 <= score <= maxScore`), real-time cohort statistics, and non-destructive grade curving simulations.
- **AttendanceForecastingEngine & Threshold Trajectory**: Predictive attendance engine (`AttendanceForecastingEngine`) in Flutter analyzing historical presence logs to project best-case/worst-case end-of-term attendance, maximum allowable future absences before breaching 75% statutory threshold, and deficit recovery streak requirements.
- **Student Leave Management API**: Enterprise student leave workflow module in Express (`/api/v1/leaves`) supporting multi-day leave applications with ISO date validation, teacher/admin review and approval workflows, student-scoped access controls, and integrated attendance deficit impact simulation (`/impact/:studentId`).
- **ScheduleConflictEngine & Timetable Intelligence**: Client-side scheduling intelligence engine (`ScheduleConflictEngine`) in Flutter detecting teacher double-booking, room overlap, and class section collisions, computing workload distribution and open gap discovery.
- **Timetable Collision Guard & Schedule Validation API**: Express backend scheduling engine with automated conflict prevention, rejecting conflicting timetable slots with `409 Conflict` (`/api/v1/timetable/validate`, `/conflicts`, `/workload/:teacherId`).
- **FeeLedgerCalculator & Tuition Financing Suite**: Client-side financial ledger engine in Flutter (`FeeLedgerCalculator`) supporting percentage/fixed scholarship discounts, configurable late penalty policies, and multi-installment schedules with exact sum preservation.
- **Batch Student Admission & Bulk Ingestion API**: Enterprise high-throughput bulk enrollment module in Express (`/api/v1/students/bulk-validate`, `/api/v1/students/bulk-enroll`) with schema validation, intra-batch duplicate checks, and atomic/partial enrollment modes.
- **OfflineSyncEngine & Mutation Queue**: Client-side offline synchronization engine (`SyncQueueManager`) with priority weighting (`high`, `normal`, `low`), idempotency key deduplication, exponential retry backoff, and conflict resolution (`serverWins`, `clientWins`, `merge`).
- **Dynamic RBAC Permission Matrix & Policy Enforcer**: Granular capability system with 19 operation permissions, least-privilege matrix, custom user override grants/revocations, and `requirePermissions` middleware with security audit logging.
- **Institutional Report Document Formatter**: Production document generator (`ReportDocumentFormatter`) producing official student academic transcripts, fee payment receipts, and attendance certifications with dual rendering (ASCII tables and print-ready HTML with CSS `@media print` styling).
- **Institutional Reporting & Performance Analytics API**: REST analytics module (`/api/v1/reports/academic`, `/attendance`, `/financial`) aggregating term-wide scores, pass/fail ratios, grade distribution buckets, top performers, attendance rates, chronic absenteeism alerts (<75%), fee reconciliation, and collection efficiency metrics.
- **Academic Grading & GPA Scales**: `GradeScaleModel` domain suite establishing continuous GPA bounds ($4.0$ scale), descriptive outcomes, and score matching algorithms.
- **Academic Calendar & Term Forecasting**: `AcademicCalendarHelper` computing active session milestones, term progress percentages, and deadline countdowns.
- **Statistical Analytics & Descriptive Metrics**: `MathStatsHelper` computing class averages, median distribution, sample standard deviation, and boundary-interpolated percentiles.
- **Functional Collection Extensions**: `EduIterableX` utilities providing type-safe chunking (`chunk`), key-based deduplication (`distinctBy`), and predicate-based bipartite splitting (`partition`).
- **Portal Navigation Breadcrumbs**: `BreadcrumbHelper` parsing route hierarchies into capitalized navigation items for admin and student portals.
- **System Error Taxonomy & Resolution**: `AppErrorCodes` providing centralized error mappings for authentication, network timeouts, and permissions.
- **Notification Channel Infrastructure**: `AppNotificationChannels` defining category metadata and urgency priorities across mobile push alert channels.
- **Campus Transportation & Transit Routing**: `SchoolBusRouteModel` and `GeoDistanceHelper` providing Haversine distance, geofencing, driver contacts, and waypoint tracking.
- **Library Catalog & Issue Circulations**: `LibraryBookModel` tracking book volume availability, shelf positions, and automated overdue penalty calculations.
- **Bell Schedule & Recess Timing Engine**: `BellScheduleModel` structuring class period durations, timetable sequencing, and interval alerts.
- **Staff Attendance & Biometric Audit**: `StaffAttendanceModel` auditing teacher arrival punctuality, worked duration, and check-in/out transitions.
- **Curriculum & Syllabus Progress Tracker**: `SyllabusTopicModel` tracking chapter progress percentage, completed lessons, and syllabus completion states.
- **Campus Events & Academic Calendar**: `SchoolEventModel` scheduling sports days, parent-teacher conferences, and assemblies with audience segmentation.
- **Asset Inventory & Hardware Depreciation**: `InventoryAssetModel` managing laboratory and IT hardware lifecycle, condition auditing, and straight-line depreciation.
- **Smart Query Parsing & File Validation**: `SearchQueryParser` tokenizing queries with key-value tag filters, and `FileTypeHelper` validating homework file uploads.
- **EventBus & Reactive AppEvent Architecture**: Decoupled, type-safe publish-subscribe event dispatcher in Flutter with specialized domain events (`AuthEvent`, `AttendanceEvent`, `FeePaymentEvent`, `GradeSubmissionEvent`, `SystemNotificationEvent`, `SyncEvent`), FIFO history replay buffer, and isolated error handling.
- **Automated Database Snapshots & Backups**: Automated system snapshot engine with recursive deterministic JSON serialization, SHA-256 cryptographic verification, tamper detection, and administrative restore endpoints.
- **Universal SearchFilterEngine**: Client-side collection query pipeline with multi-field tokenized search, composable `FilterPredicate` rules, multi-level sorting, facet counts, and pagination.
- **Notification Templating & Dispatch Engine**: Educational template renderer (`FEE_DUE_REMINDER`, `ASSIGNMENT_POSTED`, `ATTENDANCE_ABSENT_ALERT`, `EXAM_RESULT_PUBLISHED`) with parameter interpolation, multi-channel routing (`IN_APP`, `EMAIL`, `SMS`), batch queuing, and delivery stats.
- **MemoryCache & CacheManager**: High-performance client-side caching with configurable TTL, LRU eviction, tag-based invalidation, and hit/miss statistics.
- **Academic Analytics Engine**: Attendance streak calculation, linear regression grade trajectory analysis, academic risk detection, and class percentile ranking.
- **Backend Audit Logging & Security Trail**: Structured audit logging middleware tracking administrative events, actor metadata, client IP, execution duration, and payload redaction.
- **Database Relational Integrity Probes**: Deep relational integrity validator verifying foreign key references, detecting orphaned fees, and providing `/api/v1/health/integrity` diagnostic endpoints.
- **Structured Telemetry & Logging**: Configurable `AppLogger` utility with severity levels, ring buffer caching, and diagnostic exports.
- **Security & Data Sanitization**: `SecurityHelper` suite protecting against XSS, SQL injection, and providing automated PII masking for emails, phones, and IDs.
- **Academic GPA & Honors Engine**: Precision `GpaCalculator` supporting 4.0 weighted scale, SGPA, CGPA, and honors/standing evaluation.
- **Smart Notification Categorization**: Dynamic `NotificationHelper` for urgency classification, badge counters, and category color mapping.
- **Network Reachability Monitoring**: `NetworkService` supporting latency evaluation and real-time connectivity state management.
- **API Security & Rate Limiting**: In-memory sliding window rate limiter protecting endpoints against brute-force and request flooding.
- **Backend Health & Liveness Probes**: System health endpoint `/api/v1/health` with process memory metrics and `/api/v1/health/ping` liveness probe.

---

## Tech Stack

- **Frontend**: Flutter 3.x, Flutter Riverpod, GoRouter, HTTP, ResponsiveSizer
- **Backend**: Node.js, Express.js, JWT, Helmet, Morgan, Bcrypt, RateLimit
- **Architecture**: Clean Architecture, Repository Pattern, Type-Safe API Services

---

## Quick Start

1. Clone the repository: `git clone https://github.com/mrabukust-cmd/EduManage.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

---

## Documentation & Navigation

- **[System Architecture](docs/ARCHITECTURE.md)**: Deep-dive into client and server components, state management, and security model.
- **[REST API Specifications](docs/API_DOCUMENTATION.md)**: Complete endpoint contracts, request/response schemas, and Curl examples.
- **[Utilities & Health Monitoring](docs/UTILITIES_AND_HEALTH_SPEC.md)**: Specifications for security, logging, academic calculators, and health probes.
- **[Backend Guide](edumanage-backend/README.md)**: Setup and run instructions for the Express REST server.
- **[Contributing Guide](CONTRIBUTING.md)**: Standards, branch workflows, and conventional commit rules.
- **[Changelog](CHANGELOG.md)**: Full history of releases and milestone updates.

---

## Testing & Verification

Run automated test suites across both layers (total **306** automated tests with 100% pass rate):

```bash
# Flutter Test Suite (193 tests)
flutter test

# Backend API Tests (113 tests across 19 suites)
cd edumanage-backend && npm test
```
