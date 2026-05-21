// test/core/utils/read_time_estimator_test.dart
//
// Unit tests for ReadTimeEstimator.
// These are pure Dart tests — no Flutter widgets, no mocks.

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/core/utils/read_time_estimator.dart';

void main() {
  group('ReadTimeEstimator', () {
    group('estimate()', () {
      test('returns "1 min read" for null input', () {
        expect(ReadTimeEstimator.estimate(null), '1 min read');
      });

      test('returns "1 min read" for empty string', () {
        expect(ReadTimeEstimator.estimate(''), '1 min read');
      });

      test('returns "1 min read" for whitespace-only string', () {
        expect(ReadTimeEstimator.estimate('   '), '1 min read');
      });

      test('returns "1 min read" for very short text (< 200 words)', () {
        final shortText = 'Hello world. This is a test.';
        expect(ReadTimeEstimator.estimate(shortText), '1 min read');
      });

      test('returns "1 min read" for exactly 200 words', () {
        final text200 = List.filled(200, 'word').join(' ');
        expect(ReadTimeEstimator.estimate(text200), '1 min read');
      });

      test('returns "2 min read" for 201 words', () {
        final text201 = List.filled(201, 'word').join(' ');
        expect(ReadTimeEstimator.estimate(text201), '2 min read');
      });

      test('returns "5 min read" for 1000 words', () {
        final text = List.filled(1000, 'word').join(' ');
        expect(ReadTimeEstimator.estimate(text), '5 min read');
      });
    });
  });
}
