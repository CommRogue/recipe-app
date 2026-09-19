import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// The schema's `date-time` fields are RFC 3339 strings on the wire between
/// Go and Dart, and Firestore Timestamps in stored documents
/// (docs/firestore-data-model.md). This file is the only place that knows
/// both spellings.
abstract final class Rfc3339 {
  /// Parses any RFC 3339 timestamp and normalises it to UTC.
  static DateTime parse(String value) => DateTime.parse(value).toUtc();

  /// Formats in UTC with a `Z` suffix, dropping a zero fraction so a value
  /// that arrived as `...:00Z` leaves as `...:00Z`.
  static String format(DateTime value) {
    final iso = value.toUtc().toIso8601String();
    return iso.endsWith('.000Z') ? '${iso.substring(0, iso.length - 5)}Z' : iso;
  }
}

/// JSON converter for `DateTime` fields of the contract types. Reads an RFC
/// 3339 string (from the Go service) or a Firestore [Timestamp] (from a stored
/// document), and always writes the string. Use [FirestoreDates.encode] to
/// turn the strings back into Timestamps before writing to Firestore.
class Rfc3339DateTimeConverter implements JsonConverter<DateTime, Object> {
  const Rfc3339DateTimeConverter();

  @override
  DateTime fromJson(Object json) => switch (json) {
    final String s => Rfc3339.parse(s),
    final Timestamp t => t.toDate().toUtc(),
    _ => throw FormatException('Not a date-time: $json'),
  };

  @override
  Object toJson(DateTime object) => Rfc3339.format(object);
}

/// Converts the date-time fields of a JSON map between the wire spelling
/// (RFC 3339 strings) and the stored spelling (Firestore Timestamps).
/// [paths] are dotted field paths such as `private.rating.ratedAt`; a path
/// whose parent is missing or null is skipped.
abstract final class FirestoreDates {
  /// Strings to Timestamps, for a write. Returns a new map.
  static Map<String, Object?> encode(
    Map<String, Object?> json,
    Iterable<String> paths,
  ) => _convert(
    json,
    paths,
    (v) => v is String ? Timestamp.fromDate(Rfc3339.parse(v)) : v,
  );

  /// Timestamps to strings, for a read. Returns a new map.
  static Map<String, Object?> decode(
    Map<String, Object?> json,
    Iterable<String> paths,
  ) => _convert(
    json,
    paths,
    (v) => v is Timestamp ? Rfc3339.format(v.toDate()) : v,
  );

  static Map<String, Object?> _convert(
    Map<String, Object?> json,
    Iterable<String> paths,
    Object? Function(Object?) f,
  ) {
    final out = _deepCopy(json);
    for (final path in paths) {
      final segments = path.split('.');
      Map<String, Object?>? parent = out;
      for (final key in segments.take(segments.length - 1)) {
        final next = parent![key];
        parent = next is Map<String, Object?> ? next : null;
        if (parent == null) break;
      }
      if (parent == null) continue;
      final last = segments.last;
      if (parent.containsKey(last)) parent[last] = f(parent[last]);
    }
    return out;
  }

  static Map<String, Object?> _deepCopy(Map<String, Object?> m) => {
    for (final e in m.entries)
      e.key: switch (e.value) {
        final Map<String, Object?> v => _deepCopy(v),
        final List<Object?> v => List<Object?>.of(v),
        _ => e.value,
      },
  };
}
