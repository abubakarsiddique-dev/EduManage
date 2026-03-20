enum FileCategory { document, image, spreadsheet, presentation, archive, unknown }

/// Utility helper for inspecting file extensions, MIME categories, and allowed upload types.
class FileTypeHelper {
  FileTypeHelper._();

  static const Set<String> _docExtensions = {'pdf', 'doc', 'docx', 'txt', 'rtf'};
  static const Set<String> _imgExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'};
  static const Set<String> _sheetExtensions = {'xls', 'xlsx', 'csv'};
  static const Set<String> _presentationExtensions = {'ppt', 'pptx'};
  static const Set<String> _archiveExtensions = {'zip', 'rar', '7z', 'tar', 'gz'};

  /// Extracts the lowercase file extension from a filename or URL.
  static String getExtension(String fileNameOrUrl) {
    final clean = fileNameOrUrl.split('?').first.split('#').first;
    final dotIndex = clean.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == clean.length - 1) return '';
    return clean.substring(dotIndex + 1).toLowerCase();
  }

  /// Categorizes a file into [FileCategory] based on its extension.
  static FileCategory getCategory(String fileNameOrUrl) {
    final ext = getExtension(fileNameOrUrl);
    if (_docExtensions.contains(ext)) return FileCategory.document;
    if (_imgExtensions.contains(ext)) return FileCategory.image;
    if (_sheetExtensions.contains(ext)) return FileCategory.spreadsheet;
    if (_presentationExtensions.contains(ext)) return FileCategory.presentation;
    if (_archiveExtensions.contains(ext)) return FileCategory.archive;
    return FileCategory.unknown;
  }

  /// Checks if the file is safe and allowable for student assignment submission.
  static bool isAllowedSubmission(String fileName) {
    final category = getCategory(fileName);
    return category == FileCategory.document ||
        category == FileCategory.image ||
        category == FileCategory.spreadsheet ||
        category == FileCategory.presentation;
  }
}
