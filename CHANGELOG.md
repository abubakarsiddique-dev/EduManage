# Changelog

All notable changes to the **EduManage** system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.8.0] - 2026-09-16

### Added
- **ExamAssessmentEngine & Grade Analytics**: Client-side statistical evaluation engine (`ExamAssessmentEngine`) in Flutter computing comprehensive cohort metrics (mean, median, mode, sample standard deviation, IQR, variance, min/max). Provides standardized scoring (Z-score, T-score, mid-rank percentile ranks), multi-component weighted assessment aggregation (quizzes, midterms, finals), academic standing classifications (Summa Cum Laude, Magna Cum Laude, Cum Laude, Academic Probation), and multi-strategy curving (anchorToMax, linearBoost, squareRoot, and Gaussian bell curving).
- **Exam Management & Automated Curving API**: Express backend exam suite (`/api/v1/exams`) supporting exam scheduling, boundary-validated grade submissions (`0 <= score <= maxScore`), real-time cohort statistics (`/statistics`), and non-destructive grade curving simulations (`/curve`) with role-based access control.
- **AttendanceForecastingEngine & Threshold Trajectory**: Predictive attendance engine (`AttendanceForecastingEngine`) in Flutter analyzing historical presence logs to project best-case and worst-case end-of-term attendance percentages. Computes maximum allowable future absences before breaching statutory 75% institutional thresholds, calculates consecutive recovery streak requirements for students in deficit, and assesses post-leave risk impacts (`LeaveImpactAssessment`).
- **Student Leave Management API**: Enterprise student leave workflow module in Express (`/api/v1/leaves`) supporting multi-day leave applications with ISO date validation, teacher/admin review and approval workflows with reviewer remarks, student-scoped access controls, and integrated attendance deficit impact simulation (`/impact/:studentId`).
- **Expanded Automated Test Coverage**: Total backend test coverage expanded to 113 passing automated tests across 19 suites, and Flutter client unit test coverage expanded to 193 passing test cases with 0 static analysis warnings (306 automated tests total).

---

## [1.7.0] - 2026-09-15

### Added
- **ScheduleConflictEngine & Timetable Intelligence**: Client-side scheduling intelligence engine (`ScheduleConflictEngine`) in Flutter detecting teacher double-booking, room overlap, and class section collisions. Computes instructor teaching workload distribution with daily period thresholds and overload alerts, and provides automated available gap window discovery for smart timetable rescheduling.
- **Timetable Collision Guard & Schedule Validation API**: Express backend scheduling engine with automated conflict prevention, rejecting conflicting timetable insertions and updates with `409 Conflict` unless explicitly overridden via `allowConflict`. Exposes `POST /api/v1/timetable/validate`, `GET /api/v1/timetable/conflicts`, and `GET /api/v1/timetable/workload/:teacherId`.
- **FeeLedgerCalculator & Tuition Financing Suite**: Client-side financial ledger engine in Flutter (`FeeLedgerCalculator`) supporting percentage and fixed scholarship discounts (`FeeDiscount`), configurable late penalty policies (`LatePenaltyPolicy`) with grace period enforcement, compounding/flat daily fines, and maximum liability caps. Generates deterministic multi-installment schedules (`FeeInstallment`) with exact sum preservation.
- **Batch Student Admission & Bulk Ingestion API**: Enterprise high-throughput bulk enrollment module in Express (`/api/v1/students/bulk-validate`, `/api/v1/students/bulk-enroll`) with schema validation, email syntax checking, intra-batch duplicate detection, and database uniqueness guards. Supports atomic rollback transactions and best-effort partial enrollment modes.
- **Expanded Automated Test Coverage**: Total backend test coverage expanded to 95 passing automated tests across 17 suites, and Flutter client unit test coverage expanded to 171 passing test cases with 0 static analysis warnings.

---

## [1.6.0] - 2026-09-14

### Added
- **OfflineSyncEngine & Mutation Queue**: Client-side offline synchronization engine (`SyncQueueManager`) with priority weighting (`high`, `normal`, `low`), idempotency key deduplication, exponential retry backoff, and conflict resolution strategies (`serverWins`, `clientWins`, `merge`). Integrates directly with `NetworkService` for automatic background queue draining and emits `SyncEvent` lifecycle updates via `EventBus`.
- **Dynamic RBAC Permission Matrix & Policy Enforcer**: Granular permission catalog covering 19 domain operations across academics, finance, attendance, and administration. Features role-to-permission resolution, least-privilege matrix, user-specific override grants/revocations, and `requirePermissions` middleware with security audit logging (`/api/v1/rbac/permissions`, `/roles`, `/evaluate`, `/overrides`).
- **Institutional Report Document Formatter**: Production document generator (`ReportDocumentFormatter`) producing official student academic transcripts, fee payment receipts, and attendance certifications. Features dual render engines (ASCII text/markdown tables and print-ready HTML with CSS `@media print` styling), FNV-1a deterministic verification checksums, and built-in XSS input sanitization via `SecurityHelper`.
- **Institutional Reporting & Performance Analytics API**: REST analytics module (`/api/v1/reports/academic`, `/attendance`, `/financial`) aggregating term-wide scores, pass/fail ratios, grade distribution buckets, top performers, attendance rates, chronic absenteeism alerts (<75%), fee reconciliation, and collection efficiency metrics.
- **Race-Condition-Proof Database Seeding**: Thread-safe idempotent database seeding architecture preventing duplicate record inserts and test pollution during parallel automated test runs.
- **Expanded Automated Test Coverage**: Total backend test coverage expanded to 83 passing automated tests across 15 suites, and Flutter client unit test coverage expanded to 151 passing test cases with 0 static analysis warnings.

---

## [1.5.0] - 2026-09-13

### Added
- **EventBus & Reactive AppEvent Architecture**: Decoupled, type-safe publish-subscribe event dispatcher in Flutter with specialized domain events (`AuthEvent`, `AttendanceEvent`, `FeePaymentEvent`, `GradeSubmissionEvent`, `SystemNotificationEvent`), FIFO history replay buffer, and isolated subscriber error handling.
- **Automated System Snapshot & Backup Engine**: Production snapshot management service in Express with recursive deterministic serialization, SHA-256 cryptographic checksums, tampering detection, point-in-time collection restoration, and administrative endpoints (`GET/POST /api/v1/system/backups`, `/verify`, `/restore`).
- **Universal SearchFilterEngine**: Client-side collection filtering pipeline with tokenized multi-field search, composable `FilterPredicate` rules (equals, inList, range, dateBetween, custom), multi-level sorting, categorical facet frequencies, and windowed pagination.
- **Notification Templating & Dispatch Engine**: Educational template renderer (`FEE_DUE_REMINDER`, `ASSIGNMENT_POSTED`, `ATTENDANCE_ABSENT_ALERT`, `EXAM_RESULT_PUBLISHED`) with parameter interpolation, fallback formatting, multi-channel routing (`IN_APP`, `EMAIL`, `SMS`), batch queuing, and delivery statistics.
- **Automated Test Expansion**: Added comprehensive test suites bringing backend test coverage to 65 passing automated tests across 13 suites and client unit tests to 138 passing test cases.

---

## [1.4.0] - 2026-09-12

### Added
- **MemoryCache & CacheManager Utility**: Generic client-side caching engine with configurable TTL expiration, LRU capacity eviction, tag-based bulk invalidation (`invalidateByTag`, `invalidateByTags`), and hit/miss efficiency metrics.
- **AcademicAnalytics Intelligence Engine**: Complete academic telemetry calculating attendance streaks, longest records, linear regression grade trajectory analysis with standard deviation, multi-factor academic risk profiles with remediation recommendations, and class percentile distributions.
- **Backend Audit Logging & Security Trail**: Structured audit logging middleware capturing administrative events, actor metadata, client IP, execution duration, and payload sanitization with `GET /api/v1/audit/logs` and `GET /api/v1/audit/summary`.
- **Database Relational Integrity Validator**: Deep integrity diagnostic service detecting broken foreign keys, orphaned fee invoices, duplicate user emails, and `/api/v1/health/integrity` live health probe.
- **Client Compiler & Static Analysis Cleanliness**: Resolved all compiler warnings and unused imports across client feature modules, achieving clean 0-warning static analysis.

---

## [1.3.0] - 2026-09-11

### Added
- **AppLogger Utility**: Structured logging suite with severity levels, in-memory ring buffer, and diagnostic log export.
- **SecurityHelper Suite**: Enterprise-grade sanitization, XSS/SQL injection prevention, PII masking (email, phone, national ID), and secure token generation.
- **GpaCalculator Engine**: Standard 4.0 GPA/CGPA computation, credit weighting, and academic standing honors classification.
- **NotificationHelper**: Smart categorization, priority determination, unread counter badges, and category theme color mapping.
- **NetworkService**: Network reachability monitor, latency classification (fast, slow, offline), and ChangeNotifier reactive state.
- **Backend Health & Diagnostics**: Enhanced `/api/v1/health` with memory metrics and added `/api/v1/health/ping` liveness probe.
- **Technical Documentation**: Added `docs/UTILITIES_AND_HEALTH_SPEC.md` covering all utility suites and endpoints.

---

## [1.2.0] - 2026-09-10

### Added
- **DateTimeHelper Utility Suite**: Centralized date formatting (`formatIsoDate`, `formatDisplayDate`, `formatFullDateTime`), relative timestamps (`timeAgo`), and deadline difference calculation in Flutter.
- **Academic Models Validation Suite**: Unit and edge-case testing for `ClassModel`, `TimetableModel`, and `NoticeModel`.
- **Automated GitHub Actions CI**: Added `.github/workflows/ci.yml` running Flutter analyze/tests and Node.js backend integration test suites.
- **Project Documentation**: Added comprehensive `CONTRIBUTING.md` standards and `docs/ARCHITECTURE.md` system blueprint.

### Changed
- Refactored notice model parsing and test coverage.
- Updated project documentation and navigation links.

---

## [1.1.0] - 2026-09-09

### Added
- **Node.js Express REST API**: Production-ready backend server with JWT authentication, role verification, and rate limiting.
- **CSV Data Exporter**: RFC 4180 compliant CSV export engine for students roster, fee collections, attendance, and exam grades with injection attack mitigation.
- **Material 3 Dynamic Theming**: Complete dark mode palette with `themeModeProvider` state switching.
- **Validation Engine**: Robust `Validators` suite with composite rule chaining, email, password, phone, GPA, and amount validation.
- **Standardized UI Feedback**: Responsive `AppToast` floating snackbars and dismissible `AppBanner` alerts.

---

## [1.0.0] - 2026-09-08

### Added
- Initial release of EduManage School Management System.
- Multi-role portals for Administrators, Teachers, Students, and Parents.
- Academic modules: Classes, Timetable, Notices, and Attendance.
- Finance module: Invoices, receipt upload, and fee payment verification.
- Results module: Subject grading, GPA calculation, and report generation.
