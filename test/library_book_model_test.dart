import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/data/models/library_book_model.dart';

void main() {
  group('LibraryBookModel Tests', () {
    test('availability and issued copies calculation', () {
      const book = LibraryBookModel(
        id: 'b1',
        title: 'Concepts of Physics',
        author: 'H.C. Verma',
        isbn: '978-8177091878',
        totalCopies: 5,
        availableCopies: 2,
        lateFeePerDay: 15.0,
      );

      expect(book.isAvailable, isTrue);
      expect(book.issuedCopies, 3);
      expect(book.calculateFine(4), 60.0);
      expect(book.calculateFine(0), 0.0);
    });

    test('serialization roundtrip preserves values', () {
      final map = {
        'title': 'Organic Chemistry',
        'author': 'Morrison & Boyd',
        'isbn': '978-0136436690',
        'category': 'Science',
        'totalCopies': 3,
        'availableCopies': 0,
        'shelfLocation': 'Aisle 3, Shelf B',
        'lateFeePerDay': 20.0,
      };

      final book = LibraryBookModel.fromMap('b2', map);
      expect(book.isAvailable, isFalse);
      expect(book.shelfLocation, 'Aisle 3, Shelf B');
      expect(book.calculateFine(5), 100.0);
    });
  });
}
