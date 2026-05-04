/// Utility for formatting financial voucher sums into English words (e.g. "Five Thousand Rupees Only").
class CurrencyWordConverter {
  CurrencyWordConverter._();

  static const List<String> _units = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen'
  ];

  static const List<String> _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  /// Converts an integer amount into written words appended with 'Rupees Only'.
  static String convertToRupees(int amount) {
    if (amount == 0) return 'Zero Rupees Only';
    if (amount < 0) return 'Negative ${convertToRupees(amount.abs())}';

    final words = _convertChunk(amount);
    return '$words Rupees Only'.trim();
  }

  static String _convertChunk(int n) {
    if (n < 20) {
      return _units[n];
    } else if (n < 100) {
      final unit = _units[n % 10];
      return '${_tens[n ~/ 10]}${unit.isNotEmpty ? ' $unit' : ''}';
    } else if (n < 1000) {
      final rem = n % 100;
      final rest = rem > 0 ? ' ${_convertChunk(rem)}' : '';
      return '${_units[n ~/ 100]} Hundred$rest';
    } else if (n < 100000) {
      final rem = n % 1000;
      final rest = rem > 0 ? ' ${_convertChunk(rem)}' : '';
      return '${_convertChunk(n ~/ 1000)} Thousand$rest';
    } else if (n < 10000000) {
      final rem = n % 100000;
      final rest = rem > 0 ? ' ${_convertChunk(rem)}' : '';
      return '${_convertChunk(n ~/ 100000)} Lakh$rest';
    } else {
      final rem = n % 10000000;
      final rest = rem > 0 ? ' ${_convertChunk(rem)}' : '';
      return '${_convertChunk(n ~/ 10000000)} Crore$rest';
    }
  }
}
