import 'dart:math';

const _base36 = '0123456789abcdefghijklmnopqrstuvwxyz';

/// Length of the time prefix. 9 base-36 digits hold milliseconds since the
/// epoch until the year 6429, so ids sort by creation time as plain strings.
const _timeLength = 9;
const _suffixLength = 4;

/// Total length of an id minted by [mintEntryId].
const entryIdLength = _timeLength + _suffixLength;

/// Mints the id of a free-text Profile entry (docs/firestore-data-model.md):
/// milliseconds since the epoch in base 36, zero-padded, plus a short random
/// suffix. Keys of the Profile maps are shown in key order, which is therefore
/// creation order; an Override names an entry by this id.
String mintEntryId({DateTime? now, Random? random}) {
  final millis = (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch;
  final time = millis.toRadixString(36).padLeft(_timeLength, '0');
  final rng = random ?? Random.secure();
  final suffix = String.fromCharCodes(
    Iterable.generate(
      _suffixLength,
      (_) => _base36.codeUnitAt(rng.nextInt(_base36.length)),
    ),
  );
  return '$time$suffix';
}
