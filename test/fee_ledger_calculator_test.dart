import 'package:flutter_test/flutter_test.dart';
import 'package:school_management_system/core/utils/fee_ledger_calculator.dart';
import 'package:school_management_system/data/models/fee_model.dart';

void main() {
  group('FeeDiscount Calculations', () {
    test('computes percentage-based deduction accurately', () {
      const discount = FeeDiscount(
        label: 'Academic Merit 25%',
        type: DiscountType.percentage,
        value: 25.0,
      );

      expect(discount.computeDeduction(10000.0), 2500.0);
      expect(discount.computeDeduction(0.0), 0.0);
    });

    test('computes fixed-amount deduction clamped to base amount', () {
      const discount = FeeDiscount(
        label: 'Sibling Concession',
        type: DiscountType.fixedAmount,
        value: 1500.0,
      );

      expect(discount.computeDeduction(5000.0), 1500.0);
      // If base is lower than fixed discount, clamped to base
      expect(discount.computeDeduction(1000.0), 1000.0);
    });
  });

  group('LatePenaltyPolicy Evaluation', () {
    const policy = LatePenaltyPolicy(
      gracePeriodDays: 5,
      dailyRate: 100.0,
      isPercentage: false,
      maxPenaltyCap: 1000.0,
    );

    test('accrues zero penalty within grace period', () {
      final dueDate = DateTime(2026, 9, 1);
      final evalDate = DateTime(2026, 9, 5); // 4 days after due date (< 5 day grace)

      final penalty = policy.calculateAccruedPenalty(
        outstandingAmount: 2000.0,
        dueDate: dueDate,
        evaluationDate: evalDate,
      );

      expect(penalty, 0.0);
    });

    test('accrues daily flat penalty past grace period', () {
      final dueDate = DateTime(2026, 9, 1);
      final evalDate = DateTime(2026, 9, 10); // 9 days after due date. Overdue days = 9 - 5 = 4 days

      final penalty = policy.calculateAccruedPenalty(
        outstandingAmount: 2000.0,
        dueDate: dueDate,
        evaluationDate: evalDate,
      );

      expect(penalty, 400.0); // 4 * 100.0
    });

    test('enforces maximum penalty cap', () {
      final dueDate = DateTime(2026, 8, 1);
      final evalDate = DateTime(2026, 9, 15); // 45 days overdue

      final penalty = policy.calculateAccruedPenalty(
        outstandingAmount: 5000.0,
        dueDate: dueDate,
        evaluationDate: evalDate,
      );

      expect(penalty, 1000.0); // Clamped to maxPenaltyCap
    });
  });

  group('Installment Schedule Generator', () {
    test('generates equal tranches with exact total sum preservation', () {
      final plan = FeeLedgerCalculator.generateInstallmentSchedule(
        totalAmount: 10000.0,
        numberOfInstallments: 3,
        firstDueDate: DateTime(2026, 10, 1),
        intervalDays: 30,
      );

      expect(plan.length, 3);
      expect(plan[0].amount, 3333.0);
      expect(plan[1].amount, 3333.0);
      expect(plan[2].amount, 3334.0); // Remainder adjustment

      final sum = plan.fold<double>(0.0, (acc, item) => acc + item.amount);
      expect(sum, 10000.0);

      expect(plan[0].dueDate, DateTime(2026, 10, 1));
      expect(plan[1].dueDate, DateTime(2026, 10, 31));
    });
  });

  group('FeeLedgerCalculator Comprehensive Reconciliation', () {
    test('calculates net fees, scholarship discount, and status for fully paid student', () {
      final ledger = FeeLedgerCalculator.calculateLedger(
        studentId: 'std_01',
        studentName: 'Ahmad Khan',
        grossTuition: 8000.0,
        discounts: [
          const FeeDiscount(
            label: 'Sports Scholarship',
            type: DiscountType.percentage,
            value: 20.0,
          ),
        ],
        totalPaid: 6400.0, // 8000 - 1600 = 6400
        dueDate: DateTime(2026, 9, 30),
        evaluationDate: DateTime(2026, 9, 15),
      );

      expect(ledger.grossTuition, 8000.0);
      expect(ledger.totalDiscount, 1600.0);
      expect(ledger.netTuition, 6400.0);
      expect(ledger.totalPaid, 6400.0);
      expect(ledger.totalOutstandingBalance, 0.0);
      expect(ledger.accruedPenalty, 0.0);
      expect(ledger.status, FeeStatus.paid);
    });

    test('calculates overdue status and penalty for delinquent tuition', () {
      final ledger = FeeLedgerCalculator.calculateLedger(
        studentId: 'std_02',
        studentName: 'Sara Ali',
        grossTuition: 10000.0,
        totalPaid: 2000.0,
        dueDate: DateTime(2026, 8, 1),
        evaluationDate: DateTime(2026, 9, 1), // 31 days overdue (7 day grace = 24 billable days)
        penaltyPolicy: const LatePenaltyPolicy(
          gracePeriodDays: 7,
          dailyRate: 50.0,
          maxPenaltyCap: 2000.0,
        ),
      );

      expect(ledger.netTuition, 10000.0);
      expect(ledger.totalPaid, 2000.0);
      expect(ledger.accruedPenalty, 1200.0); // 24 days * 50 = 1200
      expect(ledger.totalOutstandingBalance, 8000.0 + 1200.0);
      expect(ledger.status, FeeStatus.overdue);
    });
  });
}
