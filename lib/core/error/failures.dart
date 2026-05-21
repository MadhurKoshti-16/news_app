import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({required String message, int? statusCode}) =
      NetworkFailure;

  const factory Failure.server({
    required String message,
    required int statusCode,
  }) = ServerFailure;

  const factory Failure.cache({required String message}) = CacheFailure;

  const factory Failure.unexpected({required String message}) =
      UnexpectedFailure;

  const factory Failure.unauthorized({String? message}) = UnauthorizedFailure;
}

extension FailureMessage on Failure {
  String get userMessage => when(
    network: (msg, _) => 'No internet connection. Showing cached data.',
    server: (msg, code) => 'Server error ($code). Please try again.',
    cache: (msg) => 'Could not load saved data.',
    unexpected: (msg) => 'Something went wrong. Please try again.',
    unauthorized: (msg) => 'Invalid API key. Check your .env configuration.',
  );
}
