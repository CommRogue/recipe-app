import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/core/firestore/entry_id.dart';

void main() {
  final t0 = DateTime.utc(2026, 9, 19, 8, 0, 0);

  test('has a fixed length of lower-case base-36 characters', () {
    final id = mintEntryId(now: t0);
    expect(id.length, entryIdLength);
    expect(id, matches(RegExp(r'^[0-9a-z]+$')));
  });

  test('sorts by creation time as a plain string', () {
    final earlier = mintEntryId(now: t0, random: Random(1));
    final later = mintEntryId(
      now: t0.add(const Duration(milliseconds: 1)),
      random: Random(1),
    );
    expect(earlier.compareTo(later), lessThan(0));
  });

  test('still sorts correctly across a base-36 digit rollover', () {
    // 36^8 ms is the first instant needing 9 digits; before it the prefix is
    // zero-padded, so the order must hold across that boundary.
    final boundary = DateTime.fromMillisecondsSinceEpoch(pow(36, 8).toInt(), isUtc: true);
    final before = mintEntryId(now: boundary.subtract(const Duration(milliseconds: 1)));
    final after = mintEntryId(now: boundary);
    expect(before.compareTo(after), lessThan(0));
  });

  test('two ids in the same millisecond differ', () {
    final a = mintEntryId(now: t0, random: Random(1));
    final b = mintEntryId(now: t0, random: Random(2));
    expect(a, isNot(b));
    expect(a.substring(0, entryIdLength - 4), b.substring(0, entryIdLength - 4));
  });
}
