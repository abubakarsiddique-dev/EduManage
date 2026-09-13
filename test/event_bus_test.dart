import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/events/event_bus.dart';

void main() {
  group('EventBus & AppEvent Architecture Suite', () {
    late EventBus bus;

    setUp(() {
      bus = EventBus(maxHistorySize: 5, sync: true);
      EventBus.reset(customInstance: bus);
    });

    tearDown(() async {
      await bus.dispose();
    });

    test('AppEvent generates default unique ID and UTC timestamp', () {
      final event = SystemNotificationEvent(
        title: 'System Alert',
        message: 'Scheduled maintenance at midnight',
      );

      expect(event.id, startsWith('evt_'));
      expect(event.timestamp.isUtc, isTrue);
      expect(event.eventName, equals('SystemNotificationEvent'));
      expect(event.severity, equals('info'));
      expect(event.toString(), contains('SystemNotificationEvent'));
    });

    test('AuthEvent tracks authentication state transitions', () {
      final loginEvent = AuthEvent(
        type: AuthEventType.login,
        userId: 'admin_001',
        role: 'admin',
        metadata: {'ip': '192.168.1.1'},
      );

      expect(loginEvent.eventName, equals('AuthEvent.login'));
      expect(loginEvent.userId, equals('admin_001'));
      expect(loginEvent.role, equals('admin'));
      expect(loginEvent.metadata?['ip'], equals('192.168.1.1'));
    });

    test('AttendanceEvent computes attendance percentage accurately', () {
      final attEvent = AttendanceEvent(
        classId: 'class_101',
        className: 'Grade 10 - A',
        date: DateTime.utc(2026, 9, 13),
        presentCount: 24,
        totalCount: 30,
        recordedBy: 'teacher_002',
      );

      expect(attEvent.attendancePercentage, equals(80.0));
      expect(attEvent.eventName, equals('AttendanceEvent'));
    });

    test('FeePaymentEvent and GradeSubmissionEvent carry correct domain payload', () {
      final fee = FeePaymentEvent(
        feeId: 'fee_10',
        studentId: 'student_99',
        amount: 250.0,
        paymentMethod: 'Bank Transfer',
        status: 'verified',
      );

      final grade = GradeSubmissionEvent(
        studentId: 'student_99',
        subject: 'Mathematics',
        term: 'Term 1',
        marks: 92.5,
        grade: 'A',
      );

      expect(fee.amount, equals(250.0));
      expect(fee.status, equals('verified'));
      expect(grade.subject, equals('Mathematics'));
      expect(grade.marks, equals(92.5));
    });

    test('EventBus publishes to all subscribers on raw stream', () async {
      final received = <AppEvent>[];
      final sub = bus.stream.listen(received.add);

      bus.publish(SystemNotificationEvent(title: 'Notice 1', message: 'Hello'));
      bus.publish(AuthEvent(type: AuthEventType.logout, userId: 'user_1'));

      expect(received.length, equals(2));
      expect(received.first, isA<SystemNotificationEvent>());
      expect(received.last, isA<AuthEvent>());

      await sub.cancel();
    });

    test('EventBus on<T>() filters streams by exact event type', () async {
      final authEvents = <AuthEvent>[];
      final feeEvents = <FeePaymentEvent>[];

      final authSub = bus.on<AuthEvent>().listen(authEvents.add);
      final feeSub = bus.on<FeePaymentEvent>().listen(feeEvents.add);

      bus.publish(AuthEvent(type: AuthEventType.login, userId: 'user_42'));
      bus.publish(FeePaymentEvent(
        feeId: 'f1',
        studentId: 's1',
        amount: 100,
        paymentMethod: 'Cash',
        status: 'paid',
      ));
      bus.publish(SystemNotificationEvent(title: 'Ignore me', message: 'test'));

      expect(authEvents.length, equals(1));
      expect(authEvents.first.userId, equals('user_42'));
      expect(feeEvents.length, equals(1));
      expect(feeEvents.first.amount, equals(100));

      await authSub.cancel();
      await feeSub.cancel();
    });

    test('EventBus maintains history buffer and respects maxHistorySize eviction', () {
      for (int i = 1; i <= 7; i++) {
        bus.publish(SystemNotificationEvent(
          title: 'Event $i',
          message: 'Message $i',
        ));
      }

      // Max history size was set to 5 in setUp
      expect(bus.history.length, equals(5));
      expect((bus.history.first as SystemNotificationEvent).title, equals('Event 3'));
      expect((bus.history.last as SystemNotificationEvent).title, equals('Event 7'));
    });

    test('historyOf<T>() returns type-filtered past events with limit support', () {
      bus.publish(AuthEvent(type: AuthEventType.login, userId: 'u1'));
      bus.publish(SystemNotificationEvent(title: 'N1', message: 'm1'));
      bus.publish(AuthEvent(type: AuthEventType.tokenRefreshed, userId: 'u1'));
      bus.publish(AuthEvent(type: AuthEventType.logout, userId: 'u1'));

      final allAuth = bus.historyOf<AuthEvent>();
      expect(allAuth.length, equals(3));
      expect(allAuth.map((e) => e.type), equals([
        AuthEventType.login,
        AuthEventType.tokenRefreshed,
        AuthEventType.logout,
      ]));

      final limitedAuth = bus.historyOf<AuthEvent>(limit: 2);
      expect(limitedAuth.length, equals(2));
      expect(limitedAuth.first.type, equals(AuthEventType.tokenRefreshed));
      expect(limitedAuth.last.type, equals(AuthEventType.logout));
    });

    test('clearHistory purges replay buffer completely', () {
      bus.publish(SystemNotificationEvent(title: 'T', message: 'M'));
      expect(bus.history.length, equals(1));

      bus.clearHistory();
      expect(bus.history.isEmpty, isTrue);
    });

    test('EventBus singleton instance is accessible globally and re-settable', () {
      final global = EventBus.instance;
      expect(global, isNotNull);

      final custom = EventBus(maxHistorySize: 10);
      EventBus.reset(customInstance: custom);
      expect(identical(EventBus.instance, custom), isTrue);
    });
  });
}
