import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/currency_word_converter.dart';

void main() {
  group('CurrencyWordConverter Tests', () {
    test('convertToRupees formats single and double digits', () {
      expect(CurrencyWordConverter.convertToRupees(0), 'Zero Rupees Only');
      expect(CurrencyWordConverter.convertToRupees(5), 'Five Rupees Only');
      expect(CurrencyWordConverter.convertToRupees(25), 'Twenty Five Rupees Only');
      expect(CurrencyWordConverter.convertToRupees(100), 'One Hundred Rupees Only');
    });

    test('convertToRupees handles thousands and lakhs', () {
      expect(CurrencyWordConverter.convertToRupees(5000), 'Five Thousand Rupees Only');
      expect(CurrencyWordConverter.convertToRupees(12500), 'Twelve Thousand Five Hundred Rupees Only');
      expect(CurrencyWordConverter.convertToRupees(150000), 'One Lakh Fifty Thousand Rupees Only');
    });
  });
}
