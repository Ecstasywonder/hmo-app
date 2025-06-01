/// Custom exception class for API-related errors.
class ApiException implements Exception {
  final String message;
  final int? code;

  ApiException(this.message, {this.code});

  @override
  String toString() {
    if (code != null) {
      return 'ApiException ($code): $message';
    }
    return 'ApiException: $message';
  }
}
