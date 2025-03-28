class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class ApiConnectionException extends ApiException {
  ApiConnectionException(String message) : super(message);
}

class ApiTimeoutException extends ApiException {
  ApiTimeoutException(String message) : super(message);
}

class ApiDataException extends ApiException {
  ApiDataException(String message) : super(message);
}

class ApiServerException extends ApiException {
  ApiServerException(String message) : super(message);
}

class ApiAuthException extends ApiException {
  ApiAuthException(String message) : super(message);
}
