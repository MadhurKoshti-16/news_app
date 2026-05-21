class ReadTimeEstimator {
  ReadTimeEstimator._();
  static const int _wordsPerMinute = 200;

  static const int _minimumMinutes = 1;

  static String estimate(String? text) {
    if (text == null || text.trim().isEmpty) {
      return '$_minimumMinutes min read';
    }

    final words = text.trim().split(RegExp(r'\s+'));
    final wordCount = words.length;

    if (wordCount == 0) {
      return '$_minimumMinutes min read';
    }

    final minutes = (wordCount / _wordsPerMinute).ceil();
    final displayMinutes = minutes < _minimumMinutes
        ? _minimumMinutes
        : minutes;

    return '$displayMinutes min read';
  }
}
