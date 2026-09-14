import 'dart:async';

/// Base abstract class for all events dispatched through the [EventBus].
abstract class AppEvent {
  /// Unique identifier for the event instance.
  final String id;

  /// UTC timestamp of when the event occurred.
  final DateTime timestamp;

  /// Optional metadata or extra context for the event.
  final Map<String, dynamic>? metadata;

  AppEvent({
    String? id,
    DateTime? timestamp,
    this.metadata,
  })  : id = id ?? _generateEventId(),
        timestamp = timestamp ?? DateTime.now().toUtc();

  /// Descriptive name representing this event.
  String get eventName;

  static String _generateEventId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'evt_${now.toRadixString(36)}';
  }

  @override
  String toString() => '$eventName(id: $id, timestamp: ${timestamp.toIso8601String()})';
}

/// Authentication state changes (login, logout, session expiration).
enum AuthEventType { login, logout, sessionExpired, tokenRefreshed }

class AuthEvent extends AppEvent {
  final AuthEventType type;
  final String? userId;
  final String? role;

  AuthEvent({
    required this.type,
    this.userId,
    this.role,
    super.id,
    super.timestamp,
    super.metadata,
  });

  @override
  String get eventName => 'AuthEvent.${type.name}';
}

/// Attendance submission or update event.
class AttendanceEvent extends AppEvent {
  final String classId;
  final String className;
  final DateTime date;
  final int presentCount;
  final int totalCount;
  final String recordedBy;

  AttendanceEvent({
    required this.classId,
    required this.className,
    required this.date,
    required this.presentCount,
    required this.totalCount,
    required this.recordedBy,
    super.id,
    super.timestamp,
    super.metadata,
  });

  double get attendancePercentage =>
      totalCount > 0 ? (presentCount / totalCount) * 100 : 0.0;

  @override
  String get eventName => 'AttendanceEvent';
}

/// Fee payment recording or verification event.
class FeePaymentEvent extends AppEvent {
  final String feeId;
  final String studentId;
  final double amount;
  final String paymentMethod;
  final String status;

  FeePaymentEvent({
    required this.feeId,
    required this.studentId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    super.id,
    super.timestamp,
    super.metadata,
  });

  @override
  String get eventName => 'FeePaymentEvent';
}

/// Academic grade or exam score submission event.
class GradeSubmissionEvent extends AppEvent {
  final String studentId;
  final String subject;
  final String term;
  final double marks;
  final String grade;

  GradeSubmissionEvent({
    required this.studentId,
    required this.subject,
    required this.term,
    required this.marks,
    required this.grade,
    super.id,
    super.timestamp,
    super.metadata,
  });

  @override
  String get eventName => 'GradeSubmissionEvent';
}

/// System broadcast notifications and diagnostic alerts.
class SystemNotificationEvent extends AppEvent {
  final String title;
  final String message;
  final String severity; // info, warning, error, success

  SystemNotificationEvent({
    required this.title,
    required this.message,
    this.severity = 'info',
    super.id,
    super.timestamp,
    super.metadata,
  });

  @override
  String get eventName => 'SystemNotificationEvent';
}

/// Synchronization events representing offline mutation queue state changes.
enum SyncEventType {
  mutationQueued,
  syncStarted,
  batchCompleted,
  mutationFailed,
  queueDrained,
}

class SyncEvent extends AppEvent {
  final SyncEventType type;
  final String? mutationId;
  final String? entityType;
  final int pendingCount;
  final String? errorMessage;

  SyncEvent({
    required this.type,
    this.mutationId,
    this.entityType,
    required this.pendingCount,
    this.errorMessage,
    super.id,
    super.timestamp,
    super.metadata,
  });

  @override
  String get eventName => 'SyncEvent.${type.name}';
}

/// Central publish-subscribe event bus enabling decoupled reactive communication
/// across feature modules, services, and presentation layers.
class EventBus {
  static EventBus? _instance;

  /// Global singleton accessor for application-wide event dispatching.
  static EventBus get instance => _instance ??= EventBus();

  /// Replaces or resets the global singleton instance (primarily for testing).
  static void reset({EventBus? customInstance}) {
    _instance?.dispose();
    _instance = customInstance;
  }

  final StreamController<AppEvent> _controller;
  final List<AppEvent> _history = [];
  final int maxHistorySize;

  EventBus({this.maxHistorySize = 50, bool sync = false})
      : _controller = StreamController<AppEvent>.broadcast(sync: sync);

  /// Raw stream of all events dispatched through this bus.
  Stream<AppEvent> get stream => _controller.stream;

  /// Returns an unmodifiable view of recent events buffered in memory.
  List<AppEvent> get history => List.unmodifiable(_history);

  /// Publishes a new [AppEvent] to all active subscribers and appends it to history.
  void publish(AppEvent event) {
    if (_controller.isClosed) return;

    if (maxHistorySize > 0) {
      if (_history.length >= maxHistorySize) {
        _history.removeAt(0);
      }
      _history.add(event);
    }

    _controller.add(event);
  }

  /// Listens specifically for events of type [T].
  Stream<T> on<T extends AppEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  /// Retrieves past buffered events of type [T] up to [limit].
  List<T> historyOf<T extends AppEvent>({int? limit}) {
    final filtered = _history.whereType<T>().toList();
    if (limit != null && limit < filtered.length) {
      return filtered.sublist(filtered.length - limit);
    }
    return filtered;
  }

  /// Clears the internal event replay buffer.
  void clearHistory() {
    _history.clear();
  }

  /// Closes the event stream controller and clears history.
  Future<void> dispose() async {
    _history.clear();
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
