class ArabicTextNormalizer {
  ArabicTextNormalizer._();

  static String normalize(String text) {
    return text
        // إزالة التشكيل وعلامات الضبط القرآنية
        .replaceAll(
          RegExp(
            r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF]',
          ),
          '',
        )
        // إزالة التطويل
        .replaceAll('ـ', '')
        // توحيد أشكال الألف
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        // توحيد الهمزات على الواو والياء
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        // توحيد الألف المقصورة والياء
        .replaceAll('ى', 'ي')
        // توحيد المسافات
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
