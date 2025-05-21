enum ResultDisplayType {
  noResult,
  resultOnly,
  resultWithAnswers,
}

extension ResultDisplayTypeExtension on ResultDisplayType {
  String get value {
    switch (this) {
      case ResultDisplayType.resultOnly:
        return 'النتيجة فقط';
      case ResultDisplayType.resultWithAnswers:
        return 'النتيجة مع الإجابات';
      case ResultDisplayType.noResult:
        return 'بدون نتيجة';
      default:
        return ''; // Handle any additional cases or return a default value
    }
  }
}

ResultDisplayType getResultDisplayTypeFromString(String text) {
  switch (text) {
    case 'resultOnly':
      return ResultDisplayType.resultOnly;
    case 'resultWithAnswers':
      return ResultDisplayType.resultWithAnswers;
    case 'noResult':
      return ResultDisplayType.noResult;
    default:
      throw Exception('Invalid ResultDisplayType string: $text');
  }
}
