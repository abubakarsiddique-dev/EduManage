import '../../data/models/fee_model.dart';

/// Type of financial concession or scholarship applied to fees.
enum DiscountType {
  percentage,
  fixedAmount,
}

/// Represents a discount, grant, or scholarship applied to institutional fees.
class FeeDiscount {
  final String label;
  final DiscountType type;
  final double value;

  const FeeDiscount({
    required this.label,
    required this.type,
    required this.value,
  });

  /// Calculates the absolute discount deduction against a gross amount.
  double computeDeduction(double baseAmount) {
    if (baseAmount <= 0 || value <= 0) return 0.0;

    double deduction = 0.0;
    switch (type) {
      case DiscountType.percentage:
        deduction = baseAmount * (value / 100.0);
        break;
      case DiscountType.fixedAmount:
        deduction = value;
        break;
    }

    return deduction.clamp(0.0, baseAmount);
  }

  @override
  String toString() =>
      'FeeDiscount($label: ${type == DiscountType.percentage ? "$value%" : "Rs. $value"})';
}

/// Policy configuring late fee penalties, grace periods, and maximum liability caps.
class LatePenaltyPolicy {
  final int gracePeriodDays;
  final double dailyRate;
  final bool isPercentage;
  final double maxPenaltyCap;

  const LatePenaltyPolicy({
    this.gracePeriodDays = 7,
    this.dailyRate = 50.0,
    this.isPercentage = false,
    this.maxPenaltyCap = 1500.0,
  });

  /// Computes accrued penalty on overdue balance given an evaluation date.
  double calculateAccruedPenalty({
    required double outstandingAmount,
    required DateTime dueDate,
    required DateTime evaluationDate,
  }) {
    if (outstandingAmount <= 0.0) return 0.0;

    final graceEnd = dueDate.add(Duration(days: gracePeriodDays));
    if (!evaluationDate.isAfter(graceEnd)) {
      return 0.0;
    }

    final overdueDays = evaluationDate.difference(dueDate).inDays - gracePeriodDays;
    if (overdueDays <= 0) return 0.0;

    double penalty = 0.0;
    if (isPercentage) {
      penalty = outstandingAmount * (dailyRate / 100.0) * overdueDays;
    } else {
      penalty = dailyRate * overdueDays;
    }

    return penalty.clamp(0.0, maxPenaltyCap);
  }
}

/// Represents an individual scheduled installment tranche.
class FeeInstallment {
  final int installmentNumber;
  final double amount;
  final DateTime dueDate;
  final double paidAmount;

  const FeeInstallment({
    required this.installmentNumber,
    required this.amount,
    required this.dueDate,
    this.paidAmount = 0.0,
  });

  bool get isPaid => paidAmount >= amount;
  double get remainingBalance => (amount - paidAmount).clamp(0.0, amount);

  FeeInstallment copyWith({
    int? installmentNumber,
    double? amount,
    DateTime? dueDate,
    double? paidAmount,
  }) {
    return FeeInstallment(
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}

/// Full financial breakdown and audit ledger for student fees.
class LedgerStatement {
  final String studentId;
  final String studentName;
  final double grossTuition;
  final List<FeeDiscount> discounts;
  final double totalDiscount;
  final double netTuition;
  final double totalPaid;
  final double accruedPenalty;
  final double totalOutstandingBalance;
  final FeeStatus status;
  final DateTime evaluationDate;

  const LedgerStatement({
    required this.studentId,
    required this.studentName,
    required this.grossTuition,
    required this.discounts,
    required this.totalDiscount,
    required this.netTuition,
    required this.totalPaid,
    required this.accruedPenalty,
    required this.totalOutstandingBalance,
    required this.status,
    required this.evaluationDate,
  });

  @override
  String toString() =>
      'LedgerStatement($studentName: Net Rs. ${netTuition.toStringAsFixed(2)}, Paid: Rs. ${totalPaid.toStringAsFixed(2)}, Due: Rs. ${totalOutstandingBalance.toStringAsFixed(2)}, Status: $status)';
}

/// Enterprise calculator for institutional tuition fees, tiered discounts,
/// installment financing schedules, and overdue interest/penalty accrual.
class FeeLedgerCalculator {
  /// Evaluates and generates a comprehensive financial ledger statement.
  static LedgerStatement calculateLedger({
    required String studentId,
    String studentName = '',
    required double grossTuition,
    List<FeeDiscount> discounts = const [],
    double totalPaid = 0.0,
    DateTime? dueDate,
    DateTime? evaluationDate,
    LatePenaltyPolicy penaltyPolicy = const LatePenaltyPolicy(),
  }) {
    final effectiveEvalDate = evaluationDate ?? DateTime.now();

    // 1. Calculate cumulative discounts
    double totalDiscount = 0.0;
    for (final discount in discounts) {
      totalDiscount += discount.computeDeduction(grossTuition);
    }
    totalDiscount = totalDiscount.clamp(0.0, grossTuition);

    // 2. Net tuition after concessions
    final netTuition = grossTuition - totalDiscount;

    // 3. Principal balance before penalties
    final principalDue = (netTuition - totalPaid).clamp(0.0, netTuition);

    // 4. Penalty accrual
    double accruedPenalty = 0.0;
    if (principalDue > 0.0 && dueDate != null) {
      accruedPenalty = penaltyPolicy.calculateAccruedPenalty(
        outstandingAmount: principalDue,
        dueDate: dueDate,
        evaluationDate: effectiveEvalDate,
      );
    }

    // 5. Total outstanding liability
    final totalOutstanding = principalDue + accruedPenalty;

    // 6. Determine fee status
    FeeStatus status;
    if (totalOutstanding <= 0.0 && netTuition > 0.0) {
      status = FeeStatus.paid;
    } else if (dueDate != null && effectiveEvalDate.isAfter(dueDate) && principalDue > 0.0) {
      status = FeeStatus.overdue;
    } else {
      status = FeeStatus.pending;
    }

    return LedgerStatement(
      studentId: studentId,
      studentName: studentName,
      grossTuition: grossTuition,
      discounts: discounts,
      totalDiscount: totalDiscount,
      netTuition: netTuition,
      totalPaid: totalPaid,
      accruedPenalty: accruedPenalty,
      totalOutstandingBalance: totalOutstanding,
      status: status,
      evaluationDate: effectiveEvalDate,
    );
  }

  /// Generates an installment payment schedule splitting total net tuition
  /// across tranches with precise decimal rounding to preserve the exact sum.
  static List<FeeInstallment> generateInstallmentSchedule({
    required double totalAmount,
    required int numberOfInstallments,
    required DateTime firstDueDate,
    int intervalDays = 30,
  }) {
    if (numberOfInstallments <= 0 || totalAmount <= 0.0) return [];

    final baseInstallment = (totalAmount / numberOfInstallments).floorToDouble();
    double allocated = baseInstallment * (numberOfInstallments - 1);
    final lastInstallment = totalAmount - allocated;

    final installments = <FeeInstallment>[];

    for (int i = 0; i < numberOfInstallments; i++) {
      final dueDate = firstDueDate.add(Duration(days: i * intervalDays));
      final amount = (i == numberOfInstallments - 1) ? lastInstallment : baseInstallment;

      installments.add(FeeInstallment(
        installmentNumber: i + 1,
        amount: amount,
        dueDate: dueDate,
      ));
    }

    return installments;
  }
}
