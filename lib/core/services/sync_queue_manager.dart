import 'dart:async';
import 'package:flutter/foundation.dart';
import '../events/event_bus.dart';
import 'network_service.dart';

/// Priority weighting for queued mutations.
enum SyncPriority {
  high, // e.g. Attendance, Exam results
  normal, // e.g. Notices, profile edits
  low, // e.g. Diagnostic metrics, read flags
}

/// Lifecycle status of an individual sync mutation.
enum SyncMutationStatus {
  pending,
  inFlight,
  completed,
  failed,
  conflict,
}

/// Strategy for resolving conflict during synchronization.
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  merge,
}

/// Represents an offline action or mutation queued for synchronization.
class SyncMutation {
  final String id;
  final String idempotencyKey;
  final String entityType; // e.g., 'attendance', 'grade', 'fee', 'notice'
  final String mutationType; // e.g., 'create', 'update', 'delete'
  final Map<String, dynamic> payload;
  final SyncPriority priority;
  final DateTime createdAt;
  int retryCount;
  final int maxRetries;
  SyncMutationStatus status;
  String? errorMessage;
  DateTime? lastAttemptedAt;

  SyncMutation({
    String? id,
    required this.idempotencyKey,
    required this.entityType,
    required this.mutationType,
    required this.payload,
    this.priority = SyncPriority.normal,
    DateTime? createdAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.status = SyncMutationStatus.pending,
    this.errorMessage,
    this.lastAttemptedAt,
  })  : id = id ?? _generateId(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  static String _generateId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final rand = (ms % 10000).toString().padLeft(4, '0');
    return 'mut_${ms}_$rand';
  }

  bool get canRetry => retryCount < maxRetries;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idempotencyKey': idempotencyKey,
      'entityType': entityType,
      'mutationType': mutationType,
      'payload': payload,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
      'status': status.name,
      'errorMessage': errorMessage,
      'lastAttemptedAt': lastAttemptedAt?.toIso8601String(),
    };
  }

  factory SyncMutation.fromMap(Map<String, dynamic> map) {
    return SyncMutation(
      id: map['id'] as String?,
      idempotencyKey: map['idempotencyKey'] as String,
      entityType: map['entityType'] as String,
      mutationType: map['mutationType'] as String,
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      priority: SyncPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => SyncPriority.normal,
      ),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      retryCount: (map['retryCount'] as int?) ?? 0,
      maxRetries: (map['maxRetries'] as int?) ?? 3,
      status: SyncMutationStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => SyncMutationStatus.pending,
      ),
      errorMessage: map['errorMessage'] as String?,
      lastAttemptedAt: map['lastAttemptedAt'] != null
          ? DateTime.parse(map['lastAttemptedAt'])
          : null,
    );
  }

  SyncMutation copyWith({
    SyncMutationStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? lastAttemptedAt,
    Map<String, dynamic>? payload,
  }) {
    return SyncMutation(
      id: id,
      idempotencyKey: idempotencyKey,
      entityType: entityType,
      mutationType: mutationType,
      payload: payload ?? this.payload,
      priority: priority,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
    );
  }

  @override
  String toString() =>
      'SyncMutation(id: $id, entity: $entityType, type: $mutationType, status: $status, retries: $retryCount/$maxRetries)';
}

/// Aggregated report resulting from a sync queue drain cycle.
class SyncBatchReport {
  final String batchId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int totalProcessed;
  final int succeededCount;
  final int failedCount;
  final int conflictsCount;
  final Duration duration;

  SyncBatchReport({
    required this.batchId,
    required this.startedAt,
    required this.completedAt,
    required this.totalProcessed,
    required this.succeededCount,
    required this.failedCount,
    required this.conflictsCount,
  }) : duration = completedAt.difference(startedAt);

  bool get isSuccess => failedCount == 0 && conflictsCount == 0;

  Map<String, dynamic> toMap() {
    return {
      'batchId': batchId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'totalProcessed': totalProcessed,
      'succeededCount': succeededCount,
      'failedCount': failedCount,
      'conflictsCount': conflictsCount,
      'durationMs': duration.inMilliseconds,
      'isSuccess': isSuccess,
    };
  }

  @override
  String toString() =>
      'SyncBatchReport(processed: $totalProcessed, ok: $succeededCount, failed: $failedCount, duration: ${duration.inMilliseconds}ms)';
}

/// Offline synchronization manager and mutation queue coordinator.
class SyncQueueManager with ChangeNotifier {
  static SyncQueueManager? _instance;

  /// Global singleton accessor.
  static SyncQueueManager get instance => _instance ??= SyncQueueManager();

  /// Reset global instance (useful for unit testing).
  static void reset({SyncQueueManager? customInstance}) {
    _instance?.dispose();
    _instance = customInstance;
  }

  final EventBus _eventBus;
  final List<SyncMutation> _queue = [];
  final List<SyncBatchReport> _batchHistory = [];
  bool _isSyncing = false;
  bool autoSyncOnConnect;
  ConflictResolutionStrategy conflictStrategy;
  VoidCallback? _networkListener;
  NetworkService? _boundNetworkService;

  /// Custom dispatcher plug for testing or direct API dispatching.
  Future<bool> Function(SyncMutation mutation)? customSyncDispatcher;

  SyncQueueManager({
    EventBus? eventBus,
    this.autoSyncOnConnect = true,
    this.conflictStrategy = ConflictResolutionStrategy.serverWins,
  }) : _eventBus = eventBus ?? EventBus.instance;

  bool get isSyncing => _isSyncing;
  List<SyncMutation> get allMutations => List.unmodifiable(_queue);
  List<SyncBatchReport> get batchHistory => List.unmodifiable(_batchHistory);

  int get totalCount => _queue.length;
  int get pendingCount => _queue.where((m) => m.status == SyncMutationStatus.pending).length;
  int get inFlightCount => _queue.where((m) => m.status == SyncMutationStatus.inFlight).length;
  int get completedCount => _queue.where((m) => m.status == SyncMutationStatus.completed).length;
  int get failedCount => _queue.where((m) => m.status == SyncMutationStatus.failed).length;

  List<SyncMutation> get pendingMutations {
    return _queue.where((m) => m.status == SyncMutationStatus.pending).toList()
      ..sort(_comparePriority);
  }

  /// Priority comparator: High (0) > Normal (1) > Low (2). If same priority, oldest first.
  int _comparePriority(SyncMutation a, SyncMutation b) {
    final priorityComparison = a.priority.index.compareTo(b.priority.index);
    if (priorityComparison != 0) return priorityComparison;
    return a.createdAt.compareTo(b.createdAt);
  }

  /// Enqueues a mutation. If an item with the same [idempotencyKey] is already pending,
  /// it is deduplicated (or updated) rather than creating a duplicate request.
  SyncMutation enqueue({
    required String idempotencyKey,
    required String entityType,
    required String mutationType,
    required Map<String, dynamic> payload,
    SyncPriority priority = SyncPriority.normal,
    int maxRetries = 3,
  }) {
    // Check if an existing mutation with the same idempotency key is active
    final existingIndex = _queue.indexWhere(
      (m) =>
          m.idempotencyKey == idempotencyKey &&
          (m.status == SyncMutationStatus.pending || m.status == SyncMutationStatus.inFlight),
    );

    if (existingIndex >= 0) {
      final existing = _queue[existingIndex];
      final updated = existing.copyWith(payload: payload);
      _queue[existingIndex] = updated;
      notifyListeners();
      return updated;
    }

    final mutation = SyncMutation(
      idempotencyKey: idempotencyKey,
      entityType: entityType,
      mutationType: mutationType,
      payload: payload,
      priority: priority,
      maxRetries: maxRetries,
    );

    _queue.add(mutation);
    notifyListeners();

    _eventBus.publish(
      SyncEvent(
        type: SyncEventType.mutationQueued,
        mutationId: mutation.id,
        entityType: mutation.entityType,
        pendingCount: pendingCount,
      ),
    );

    return mutation;
  }

  /// Manually binds to a [NetworkService] to automatically drain queue when connectivity is restored.
  void bindNetworkService(NetworkService networkService) {
    unbindNetworkService();
    _boundNetworkService = networkService;

    _networkListener = () {
      if (autoSyncOnConnect &&
          !_isSyncing &&
          networkService.state.isOnline &&
          pendingCount > 0) {
        processQueue();
      }
    };

    networkService.addListener(_networkListener!);
  }

  /// Unbinds current network service listener.
  void unbindNetworkService() {
    if (_boundNetworkService != null && _networkListener != null) {
      _boundNetworkService!.removeListener(_networkListener!);
      _boundNetworkService = null;
      _networkListener = null;
    }
  }

  /// Processes the pending queue in batches ordered by priority and timestamp.
  Future<SyncBatchReport> processQueue({int maxBatchSize = 25}) async {
    if (_isSyncing) {
      return SyncBatchReport(
        batchId: 'in_progress',
        startedAt: DateTime.now().toUtc(),
        completedAt: DateTime.now().toUtc(),
        totalProcessed: 0,
        succeededCount: 0,
        failedCount: 0,
        conflictsCount: 0,
      );
    }

    _isSyncing = true;
    final startedAt = DateTime.now().toUtc();
    final batchId = 'batch_${startedAt.millisecondsSinceEpoch}';

    _eventBus.publish(
      SyncEvent(
        type: SyncEventType.syncStarted,
        pendingCount: pendingCount,
      ),
    );

    final toProcess = pendingMutations.take(maxBatchSize).toList();
    int succeeded = 0;
    int failed = 0;
    int conflicts = 0;

    for (final mutation in toProcess) {
      mutation.status = SyncMutationStatus.inFlight;
      mutation.lastAttemptedAt = DateTime.now().toUtc();
      notifyListeners();

      try {
        bool dispatchSuccess = false;

        if (customSyncDispatcher != null) {
          dispatchSuccess = await customSyncDispatcher!(mutation);
        } else {
          // Default mock handler for environment testing
          dispatchSuccess = true;
        }

        if (dispatchSuccess) {
          mutation.status = SyncMutationStatus.completed;
          mutation.errorMessage = null;
          succeeded++;
        } else {
          _handleMutationFailure(mutation, 'Server responded with failure');
          failed++;
        }
      } catch (err) {
        final errorMsg = err.toString();
        if (errorMsg.contains('conflict') || errorMsg.contains('409')) {
          mutation.status = SyncMutationStatus.conflict;
          mutation.errorMessage = errorMsg;
          conflicts++;
        } else {
          _handleMutationFailure(mutation, errorMsg);
          failed++;
        }
      }

      notifyListeners();
    }

    _isSyncing = false;
    final completedAt = DateTime.now().toUtc();

    final report = SyncBatchReport(
      batchId: batchId,
      startedAt: startedAt,
      completedAt: completedAt,
      totalProcessed: toProcess.length,
      succeededCount: succeeded,
      failedCount: failed,
      conflictsCount: conflicts,
    );

    _batchHistory.add(report);
    if (_batchHistory.length > 50) {
      _batchHistory.removeAt(0);
    }

    _eventBus.publish(
      SyncEvent(
        type: SyncEventType.batchCompleted,
        pendingCount: pendingCount,
        metadata: report.toMap(),
      ),
    );

    if (pendingCount == 0 && toProcess.isNotEmpty) {
      _eventBus.publish(
        SyncEvent(
          type: SyncEventType.queueDrained,
          pendingCount: 0,
        ),
      );
    }

    notifyListeners();
    return report;
  }

  void _handleMutationFailure(SyncMutation mutation, String reason) {
    mutation.retryCount++;
    mutation.errorMessage = reason;

    if (mutation.canRetry) {
      mutation.status = SyncMutationStatus.pending;
    } else {
      mutation.status = SyncMutationStatus.failed;
      _eventBus.publish(
        SyncEvent(
          type: SyncEventType.mutationFailed,
          mutationId: mutation.id,
          entityType: mutation.entityType,
          pendingCount: pendingCount,
          errorMessage: reason,
        ),
      );
    }
  }

  /// Retries all failed mutations by resetting their retry counter and status to pending.
  int retryAllFailed() {
    int count = 0;
    for (final mutation in _queue) {
      if (mutation.status == SyncMutationStatus.failed ||
          mutation.status == SyncMutationStatus.conflict) {
        mutation.status = SyncMutationStatus.pending;
        mutation.retryCount = 0;
        mutation.errorMessage = null;
        count++;
      }
    }
    if (count > 0) {
      notifyListeners();
    }
    return count;
  }

  /// Removes completed mutations from memory.
  int clearCompleted() {
    final initial = _queue.length;
    _queue.removeWhere((m) => m.status == SyncMutationStatus.completed);
    final removed = initial - _queue.length;
    if (removed > 0) notifyListeners();
    return removed;
  }

  /// Purges all items from the queue.
  void clearAll() {
    _queue.clear();
    notifyListeners();
  }

  /// Removes a single mutation by ID.
  bool removeById(String id) {
    final initial = _queue.length;
    _queue.removeWhere((m) => m.id == id);
    final removed = _queue.length != initial;
    if (removed) notifyListeners();
    return removed;
  }

  @override
  void dispose() {
    unbindNetworkService();
    super.dispose();
  }
}
