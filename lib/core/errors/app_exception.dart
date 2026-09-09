class AppException implements Exception {
  final String code;
  final String message;
  
  const AppException({required this.code, required this.message});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
