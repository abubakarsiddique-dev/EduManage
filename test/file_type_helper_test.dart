import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage/core/utils/file_type_helper.dart';

void main() {
  group('FileTypeHelper Tests', () {
    test('getExtension parses various file path schemes', () {
      expect(FileTypeHelper.getExtension('report.pdf'), 'pdf');
      expect(FileTypeHelper.getExtension('https://cdn.school.edu/assignments/lab1.DOCX?token=123'), 'docx');
      expect(FileTypeHelper.getExtension('README'), '');
    });

    test('getCategory classifies file extensions accurately', () {
      expect(FileTypeHelper.getCategory('document.pdf'), FileCategory.document);
      expect(FileTypeHelper.getCategory('screenshot.png'), FileCategory.image);
      expect(FileTypeHelper.getCategory('grades.xlsx'), FileCategory.spreadsheet);
      expect(FileTypeHelper.getCategory('slides.pptx'), FileCategory.presentation);
      expect(FileTypeHelper.getCategory('backup.zip'), FileCategory.archive);
    });

    test('isAllowedSubmission verifies homework upload safety', () {
      expect(FileTypeHelper.isAllowedSubmission('homework.pdf'), isTrue);
      expect(FileTypeHelper.isAllowedSubmission('exploit.exe'), isFalse);
    });
  });
}
