import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/text_highlight_helper.dart';

void main() {
  group('TextHighlightHelper Tests', () {
    test('splitForHighlight detects case-insensitive match segments', () {
      final segments = TextHighlightHelper.splitForHighlight('Physics Midterm Exam', 'midterm');
      expect(segments.length, 3);
      expect(segments[0], const TextSpanSegment(text: 'Physics ', isMatch: false));
      expect(segments[1], const TextSpanSegment(text: 'Midterm', isMatch: true));
      expect(segments[2], const TextSpanSegment(text: ' Exam', isMatch: false));
    });

    test('splitForHighlight returns single segment for empty search term', () {
      final segments = TextHighlightHelper.splitForHighlight('Mathematics', '');
      expect(segments.length, 1);
      expect(segments.first.isMatch, isFalse);
    });
  });
}
