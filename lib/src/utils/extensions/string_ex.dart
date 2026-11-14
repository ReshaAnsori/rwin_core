extension StringEx on String? {
  // ─── Case conversion ───────────────────────────────────────────────────────

  /// `"hello"` → `"Hello"`
  String capitalize() {
    final v = this?.trim();
    if (v == null || v.isEmpty) return '';
    return '${v[0].toUpperCase()}${v.substring(1)}';
  }

  /// `"hello_world"` → `"helloWorld"`
  String toCamelCase() {
    final v = this?.trim();
    if (v == null || v.isEmpty) return '';
    return v
        .split(RegExp(r'[_\s-]+'))
        .map((w) => w.isNotEmpty ? w.capitalize() : '')
        .join('');
  }

  /// `"helloWorld"` → `"hello_world"`
  String toSnakeCase() {
    final v = this?.trim();
    if (v == null || v.isEmpty) return '';
    return v
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'),
            (m) => '${m[1]}_${m[2]}')
        .toLowerCase()
        .replaceAll(' ', '_');
  }

  /// `"helloWorld"` → `"hello-world"`
  String toKebabCase() => toSnakeCase().replaceAll('_', '-');

  /// `"hello_world"` → `"HelloWorld"`
  String toPascalCase() => toCamelCase().capitalize();

  /// `"helloWorld"` / `"hello_world"` / `"hello-world"` → `"Hello World"`
  String toTitleCase() {
    final v = this?.trim();
    if (v == null || v.isEmpty) return '';
    if (v.contains('_') || v.contains('-')) {
      return v.split(RegExp(r'[_-]+')).map((w) => w.capitalize()).join(' ');
    }
    return v
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .map((w) => w.capitalize())
        .join(' ');
  }

  /// `"HELLO WORLD"` → `"Hello world"`
  String toSentenceCase() {
    final v = this?.trim().toLowerCase();
    if (v == null || v.isEmpty) return '';
    return v.capitalize();
  }

  /// `"john doe"` → `"John Doe"`
  String toCapitalizeWords() {
    final v = this?.trim();
    if (v == null || v.isEmpty) return '';
    return v.split(' ').map((w) => w.capitalize()).join(' ');
  }

  // ─── Validation ────────────────────────────────────────────────────────────

  bool isValidEmail() {
    final v = this;
    if (v == null || v.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$', caseSensitive: false)
        .hasMatch(v);
  }

  bool isValidUrl() {
    final v = this;
    if (v == null || v.isEmpty) return false;
    return RegExp(r'^(http|https):\/\/[^\s$.?#].[^\s]*$', caseSensitive: false)
        .hasMatch(v);
  }

  bool isValidPhone() {
    final v = this?.replaceAll(' ', '');
    if (v == null || v.isEmpty) return false;
    return RegExp(r'^\+?\d{7,15}$').hasMatch(v);
  }

  // ─── Checks ────────────────────────────────────────────────────────────────

  /// `true` when non-null and non-empty.
  bool get hasValue => this != null && this!.isNotEmpty;

  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  bool get isNumeric => this != null && double.tryParse(this!) != null;

  bool get isAlphabet =>
      this != null && RegExp(r'^[a-zA-Z]+$').hasMatch(this!);

  bool isEqual(String? other) => this == other;

  bool isEqualIgnoreCase(String? other) {
    if (this == null && other == null) return true;
    if (this == null || other == null) return false;
    return this!.toLowerCase() == other.toLowerCase();
  }

  // ─── Transforms ────────────────────────────────────────────────────────────

  String orEmpty() => this ?? '';

  String safeTrim() => this?.trim() ?? '';

  String removeAllWhitespace() => (this ?? '').replaceAll(RegExp(r'\s+'), '');

  String digitsOnly() => (this ?? '').replaceAll(RegExp(r'[^0-9]'), '');

  /// Truncates to [maxLength] characters with `…` suffix.
  String truncate(int maxLength) {
    final v = this ?? '';
    if (v.length <= maxLength) return v;
    return '${v.substring(0, maxLength)}...';
  }

  String reverse() => (this ?? '').split('').reversed.join('');

  String repeat(int n) {
    final v = this ?? '';
    if (n <= 0) return '';
    return List.filled(n, v).join();
  }

  /// Masks all but the last [visibleCount] characters.
  String mask({int visibleCount = 4, String maskChar = '*'}) {
    final v = this ?? '';
    if (v.length <= visibleCount) return v;
    final hidden = v.length - visibleCount;
    return maskChar * hidden + v.substring(hidden);
  }

  String safeSubstring(int start, [int? end]) {
    final v = this ?? '';
    if (start >= v.length) return '';
    return v.substring(start, end ?? v.length);
  }

  // ─── Conversions ───────────────────────────────────────────────────────────

  int toInt({int defaultValue = 0}) =>
      this == null ? defaultValue : int.tryParse(this!) ?? defaultValue;

  double toDouble({double defaultValue = 0.0}) =>
      this == null ? defaultValue : double.tryParse(this!) ?? defaultValue;
}
