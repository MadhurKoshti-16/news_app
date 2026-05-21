// test/core/error/failures_test.dart
//
// Unit tests for the Failure hierarchy: userMessage and when() dispatch.

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/error/failures.dart';

void main() {
  group('Failure.userMessage', () {
    test('NetworkFailure returns correct message', () {
      const f = NetworkFailure(message: 'no connection');
      expect(f.userMessage, contains('internet'));
    });

    test('ServerFailure includes status code', () {
      const f = ServerFailure(message: 'internal error', statusCode: 500);
      expect(f.userMessage, contains('500'));
    });

    test('CacheFailure returns correct message', () {
      const f = CacheFailure(message: 'hive error');
      expect(f.userMessage, contains('saved data'));
    });

    test('UnexpectedFailure returns generic message', () {
      const f = UnexpectedFailure(message: 'boom');
      expect(f.userMessage, contains('wrong'));
    });

    test('UnauthorizedFailure mentions API key', () {
      const f = UnauthorizedFailure();
      expect(f.userMessage, contains('API key'));
    });
  });

  group('Failure.when()', () {
    test('dispatches NetworkFailure correctly', () {
      const f = NetworkFailure(message: 'off', statusCode: null);
      final result = f.when(
        network: (msg, code) => 'network:$msg',
        server: (_, _) => 'server',
        cache: (_) => 'cache',
        unexpected: (_) => 'unexpected',
        unauthorized: (_) => 'unauthorized',
      );
      expect(result, 'network:off');
    });

    test('dispatches ServerFailure correctly', () {
      const f = ServerFailure(message: 'err', statusCode: 404);
      final result = f.when(
        network: (_, _) => 'network',
        server: (msg, code) => 'server:$code',
        cache: (_) => 'cache',
        unexpected: (_) => 'unexpected',
        unauthorized: (_) => 'unauthorized',
      );
      expect(result, 'server:404');
    });

    test('dispatches CacheFailure correctly', () {
      const f = CacheFailure(message: 'cache error');
      final result = f.when(
        network: (_, _) => 'network',
        server: (_, _) => 'server',
        cache: (msg) => 'cache:$msg',
        unexpected: (_) => 'unexpected',
        unauthorized: (_) => 'unauthorized',
      );
      expect(result, 'cache:cache error');
    });
  });

  group('Failure.maybeWhen()', () {
    test('falls through to orElse when type not handled', () {
      const f = UnexpectedFailure(message: 'x');
      final result = f.maybeWhen(
        network: (_, _) => 'network',
        orElse: () => 'fallback',
      );
      expect(result, 'fallback');
    });

    test('handles matched type and ignores orElse', () {
      const f = CacheFailure(message: 'y');
      final result = f.maybeWhen(
        cache: (msg) => 'cache:$msg',
        orElse: () => 'fallback',
      );
      expect(result, 'cache:y');
    });
  });
}
