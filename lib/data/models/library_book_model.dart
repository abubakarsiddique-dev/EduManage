/// Represents a library book in the school catalog with issuance and availability tracking.
class LibraryBookModel {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final String shelfLocation;
  final double lateFeePerDay;

  const LibraryBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.category = 'General',
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.shelfLocation = '',
    this.lateFeePerDay = 10.0,
  });

  factory LibraryBookModel.fromMap(String id, Map<String, dynamic> map) {
    return LibraryBookModel(
      id: id,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      isbn: map['isbn'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      totalCopies: (map['totalCopies'] as num?)?.toInt() ?? 1,
      availableCopies: (map['availableCopies'] as num?)?.toInt() ?? 1,
      shelfLocation: map['shelfLocation'] as String? ?? '',
      lateFeePerDay: (map['lateFeePerDay'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'shelfLocation': shelfLocation,
      'lateFeePerDay': lateFeePerDay,
    };
  }

  bool get isAvailable => availableCopies > 0;
  int get issuedCopies => totalCopies - availableCopies;

  double calculateFine(int daysOverdue) {
    if (daysOverdue <= 0) return 0.0;
    return daysOverdue * lateFeePerDay;
  }

  LibraryBookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    int? totalCopies,
    int? availableCopies,
    String? shelfLocation,
    double? lateFeePerDay,
  }) {
    return LibraryBookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      shelfLocation: shelfLocation ?? this.shelfLocation,
      lateFeePerDay: lateFeePerDay ?? this.lateFeePerDay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryBookModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isbn == other.isbn;

  @override
  int get hashCode => id.hashCode ^ isbn.hashCode;

  @override
  String toString() => 'LibraryBookModel(id: $id, title: $title, isbn: $isbn)';
}
