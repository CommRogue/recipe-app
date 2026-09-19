import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/core/firestore/rfc3339.dart';

void main() {
  group('Rfc3339', () {
    test('parses an offset and normalises to UTC', () {
      final t = Rfc3339.parse('2026-09-18T12:30:00+03:00');
      expect(t.isUtc, isTrue);
      expect(t, DateTime.utc(2026, 9, 18, 9, 30));
    });

    test('formats without a fraction when it is zero', () {
      expect(Rfc3339.format(DateTime.utc(2026, 9, 18, 9, 30)), '2026-09-18T09:30:00Z');
    });

    test('keeps a non-zero fraction', () {
      expect(
        Rfc3339.format(DateTime.utc(2026, 9, 18, 9, 30, 0, 250)),
        '2026-09-18T09:30:00.250Z',
      );
    });

    test('round-trips the schema example value unchanged', () {
      const wire = '2026-09-18T09:30:00Z';
      expect(Rfc3339.format(Rfc3339.parse(wire)), wire);
    });
  });

  group('Rfc3339DateTimeConverter', () {
    const converter = Rfc3339DateTimeConverter();
    final instant = DateTime.utc(2026, 9, 18, 9, 30);

    test('reads a string', () {
      expect(converter.fromJson('2026-09-18T09:30:00Z'), instant);
    });

    test('reads a Firestore Timestamp', () {
      expect(converter.fromJson(Timestamp.fromDate(instant)), instant);
    });

    test('rejects anything else', () {
      expect(() => converter.fromJson(42), throwsFormatException);
    });

    test('writes the string spelling', () {
      expect(converter.toJson(instant), '2026-09-18T09:30:00Z');
    });
  });

  group('FirestoreDates', () {
    final json = <String, Object?>{
      'title': 'x',
      'createdAt': '2026-09-18T09:30:00Z',
      'private': {
        'rating': {'stars': 5, 'ratedAt': '2026-09-19T08:00:00Z'},
        'lastCookedAt': null,
      },
    };
    const paths = ['createdAt', 'private.rating.ratedAt', 'private.lastCookedAt', 'savedAt'];

    test('encode turns strings at the given paths into Timestamps', () {
      final out = FirestoreDates.encode(json, paths);
      expect(out['createdAt'], Timestamp.fromDate(DateTime.utc(2026, 9, 18, 9, 30)));
      final rating = (out['private'] as Map)['rating'] as Map;
      expect(rating['ratedAt'], isA<Timestamp>());
      expect(rating['stars'], 5);
      expect((out['private'] as Map)['lastCookedAt'], isNull);
      expect(out.containsKey('savedAt'), isFalse, reason: 'missing paths are skipped');
      expect(out['title'], 'x');
    });

    test('encode does not mutate its input', () {
      FirestoreDates.encode(json, paths);
      expect(json['createdAt'], isA<String>());
    });

    test('decode is the inverse of encode', () {
      expect(FirestoreDates.decode(FirestoreDates.encode(json, paths), paths), json);
    });
  });
}
