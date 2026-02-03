/// Utilities for Arabic text (e.g. tashkeel-insensitive search).
class ArabicUtils {
  ArabicUtils._();

  /// Removes Arabic diacritics (tashkeel) and related marks from [text].
  /// Also strips tatweel and spaces so searches work even if tri-literal
  /// roots are written with spaces (e.g. "ر ب ب" vs "ربب").
  ///
  /// - Diacritics: \u064B-\u065F (Fathatan..Small Waw, etc.), \u0670 (Superscript Alef)
  /// - Tatweel: \u0640
  /// - Whitespace: all standard space characters (\\s)
  static String stripTashkeel(String text) {
    if (text.isEmpty) return text;
    return text.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640\s]'), '');
  }

  /// Returns true if [haystack] contains [needle] when both are normalized
  /// (tashkeel stripped), so search works with or without diacritics.
  static bool containsNormalized(String haystack, String needle) {
    if (needle.isEmpty) return true;
    final h = stripTashkeel(haystack);
    final n = stripTashkeel(needle);
    return h.contains(n);
  }
}
