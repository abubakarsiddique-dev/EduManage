import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/events/event_bus.dart';
import 'package:school_management_system/core/services/network_service.dart';
import 'package:school_management_system/core/services/sync_queue_manager.dart';

void main() {
  group('SyncMutation Unit Tests', () {
    test('serializes and deserializes map accurately', () {
      final mutation = SyncMutation(
        idempotencyKey: 'idempotent_123',
        entityType: 'attendance',
        mutationType: 'create',
        payload: {'classId': 'cls_1', 'presentCount': 25},
        priority: SyncPriority.high,
        maxRetries: 4,
      );

      final map = mutation.toMap();
      expect(map['idempotencyKey'], 'idempotent_123');
      expect(map['entityType'], 'attendance');
      expect(map['mutationType'], 'create');
      expect(map['priority'], 'high');
      expect(map['maxRetries'], 4);
      expect(map['status'], 'pending');

      final fromMap = SyncMutation.fromMap(map);
      expect(fromMap.id, mutation.id);
      expect(fromMap.idempotencyKey, mutation.idempotencyKey);
      expect(fromMap.entityType, mutation.entityType);
      expect(fromMap.payload['classId'], 'cls_1');
      expect(fromMap.priority, SyncPriority.high);
    });

    test('copyWith produces updated mutation state without side effects', () {
      final mutation = SyncMutation(
        idempotencyKey: 'key_1',
        entityType: 'grade',
        mutationType: 'update',
        payload: {'marks': 88},
      );

      final updated = mutation.copyWith(
        status: SyncMutationStatus.completed,
        retryCount: 1,
        errorMessage: 'temp warning',
      );

      expect(updated.id, mutation.id);
      expect(updated.status, SyncMutationStatus.completed);
      expect(updated.retryCount, 1);
      expect(updated.errorMessage, 'temp warning');
      expect(mutation.status, SyncMutationStatus.pending);
    });
  });

  group('SyncQueueManager Operations Suite', () {
    late EventBus testEventBus;
    late SyncQueueManager manager;

    setUp(() {
      testEventBus = EventBus();
      manager = SyncQueueManager(eventBus: testEventBus, autoSyncOnConnect: false);
    });

    tearDown(() async {
      manager.dispose();
      await testEventBus.dispose();
    });

    test('enqueue adds mutations and orders by priority', () {
      manager.enqueue(
        idempotencyKey: 'key_normal',
        entityType: 'notice',
        mutationType: 'create',
        payload: {'title': 'Sports Day'},
        priority: SyncPriority.normal,
      );

      manager.enqueue(
        idempotencyKey: 'key_high',
        entityType: 'attendance',
        mutationType: 'create',
        payload: {'classId': 'cls_a'},
        priority: SyncPriority.high,
      );

      manager.enqueue(
        idempotencyKey: 'key_low',
        entityType: 'metric',
        mutationType: 'create',
        payload: {'metric': 'fps'},
        priority: SyncPriority.low,
      );

      expect(manager.totalCount, 3);
      expect(manager.pendingCount, 3);

      final pending = manager.pendingMutations;
      expect(pending[0].priority, SyncPriority.high);
      expect(pending[1].priority, SyncPriority.normal);
      expect(pending[2].priority, SyncPriority.low);
    });

    test('enqueue deduplicates identical idempotency keys', () {
      manager.enqueue(
        idempotencyKey: 'attendance_grade10_2026-09-14',
        entityType: 'attendance',
        mutationType: 'create',
        payload: {'present': 20},
      );

      // Same key, updated payload
      manager.enqueue(
        idempotencyKey: 'attendance_grade10_2026-09-14',
        entityType: 'attendance',
        mutationType: 'create',
        payload: {'present': 24},
      );

      expect(manager.totalCount, 1);
      expect(manager.pendingMutations.first.payload['present'], 24);
    });

    test('processQueue completes mutations and generates batch report', () async {
      manager.enqueue(
        idempotencyKey: 'tx_1',
        entityType: 'fee',
        mutationType: 'create',
        payload: {'amount': 500},
      );

      manager.enqueue(
        idempotencyKey: 'tx_2',
        entityType: 'grade',
        mutationType: 'create',
        payload: {'grade': 'A'},
      );

      manager.customSyncDispatcher = (mutation) async => true;

      final report = await manager.processQueue();

      expect(report.totalProcessed, 2);
      expect(report.succeededCount, 2);
      expect(report.failedCount, 0);
      expect(report.isSuccess, isTrue);
      expect(manager.completedCount, 2);
      expect(manager.pendingCount, 0);

      // Verify event bus captured life-cycle events in history
      final historyEvents = testEventBus.historyOf<SyncEvent>();
      expect(historyEvents.any((e) => e.type == SyncEventType.syncStarted), isTrue);
      expect(historyEvents.any((e) => e.type == SyncEventType.batchCompleted), isTrue);
      expect(historyEvents.any((e) => e.type == SyncEventType.queueDrained), isTrue);
    });

    test('processQueue handles retries and transitions to failed on maxRetries', () async {
      manager.enqueue(
        idempotencyKey: 'failing_key',
        entityType: 'attendance',
        mutationType: 'create',
        payload: {'class': 'A'},
        maxRetries: 2,
      );

      // Fail dispatcher
      manager.customSyncDispatcher = (m) async => false;

      // Attempt 1: retryCount becomes 1, remains pending
      var report = await manager.processQueue();
      expect(report.failedCount, 1);
      expect(manager.pendingCount, 1);
      expect(manager.pendingMutations.first.retryCount, 1);

      // Attempt 2: retryCount becomes 2, reaches maxRetries, marks failed
      report = await manager.processQueue();
      expect(report.failedCount, 1);
      expect(manager.pendingCount, 0);
      expect(manager.failedCount, 1);
      expect(manager.allMutations.first.status, SyncMutationStatus.failed);

      // Reset failed mutations
      final retried = manager.retryAllFailed();
      expect(retried, 1);
      expect(manager.pendingCount, 1);
      expect(manager.pendingMutations.first.retryCount, 0);
    });

    test('processQueue flags conflict when server returns conflict exception', () async {
      manager.enqueue(
        idempotencyKey: 'conflict_key',
        entityType: 'fee',
        mutationType: 'update',
        payload: {'status': 'paid'},
      );

      manager.customSyncDispatcher = (m) async {
        throw Exception('HTTP 409 conflict: record modified by another admin');
      };

      final report = await manager.processQueue();
      expect(report.conflictsCount, 1);
      expect(manager.allMutations.first.status, SyncMutationStatus.conflict);
    });

    test('clearCompleted and removeById purge target items', () async {
      manager.enqueue(
        idempotencyKey: 'key_1',
        entityType: 'notice',
        mutationType: 'create',
        payload: {},
      );
      manager.enqueue(
        idempotencyKey: 'key_2',
        entityType: 'notice',
        mutationType: 'create',
        payload: {},
      );

      manager.customSyncDispatcher = (m) async => true;
      await manager.processQueue();
      expect(manager.completedCount, 2);

      final cleared = manager.clearCompleted();
      expect(cleared, 2);
      expect(manager.totalCount, 0);
    });

    test('NetworkService binding triggers auto-sync upon connection restoration', () async {
      final network = NetworkService();
      manager.autoSyncOnConnect = true;
      manager.bindNetworkService(network);

      manager.enqueue(
        idempotencyKey: 'auto_sync_test',
        entityType: 'grade',
        mutationType: 'create',
        payload: {'grade': 'B'},
      );

      expect(manager.pendingCount, 1);

      // Simulate ping restoration
      network.customPingHandler = ({Duration timeout = const Duration(seconds: 4)}) async => 45;
      await network.verifyConnectivity();

      // Manager should have auto-drained the queue
      expect(manager.pendingCount, 0);
      expect(manager.completedCount, 1);

      manager.unbindNetworkService();
    });
  });
}
