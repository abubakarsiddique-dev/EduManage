/// Utility for generating clean, URL-safe slugs for documents, syllabus chapters, and portal paths.
class SlugGeneratorHelper {
  SlugGeneratorHelper._();

  /// Converts a title (e.g. "Chapter 3: Thermodynamics & Heat!") into a clean slug ("chapter-3-thermodynamics-heat").
  static String generate(String title) {
    if (title.trim().isEmpty) return '';

    var slug = title.toLowerCase().trim();
    // Replace accented characters or symbols
    slug = slug.replaceAll(RegExp(r'[^\w\s-]'), '');
    // Replace multiple spaces or underscores with a single hyphen
    slug = slug.replaceAll(RegExp(r'[\s_]+'), '-');
    // Remove duplicate hyphens
    slug = slug.replaceAll(RegExp(r'-+'), '-');
    // Remove leading/trailing hyphens
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    return slug;
  }
}
