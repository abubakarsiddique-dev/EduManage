import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/fee_model.dart';

void main() {
  group('FeeModel Tests', () {
    test('status getters match correctly', () {
      const paidFee = FeeModel(
        id: 'f1',
        studentId: 's1',
        amount: 5000,
        status: FeeStatus.paid,
      );
      expect(paidFee.isPaid, isTrue);
      expect(paidFee.isPending, isFalse);

      const pendingFee = FeeModel(
        id: 'f2',
        studentId: 's2',
        amount: 4500,
        status: FeeStatus.pending,
      );
      expect(pendingFee.isPending, isTrue);
    });

    test('formattedAmount formats currency string', () {
      const fee = FeeModel(
        id: 'f1',
        studentId: 's1',
        amount: 12500,
      );
      expect(fee.formattedAmount, 'Rs. 12500');
    });

    test('equality checks identify identical fee objects', () {
      const f1 = FeeModel(id: 'fee1', studentId: 'std1', amount: 8000);
      const f2 = FeeModel(id: 'fee1', studentId: 'std1', amount: 8000);
      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
    });
  });
}
