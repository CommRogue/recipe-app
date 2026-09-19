import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';
import 'package:panwise/core/firestore/rfc3339.dart';
import 'package:panwise/features/recipes/domain/recipe.dart';

/// Removes keys that are absent from [expected] and carry a schema default in
/// [actual] (null, false or an empty list), so the comparison ignores optional
/// fields the Dart side spells out. Anything else must match exactly.
Object? normalise(Object? actual, Object? expected) {
  if (actual is Map && expected is Map) {
    return {
      for (final e in actual.entries)
        if (expected.containsKey(e.key) || !_isDefault(e.value))
          e.key: normalise(e.value, expected[e.key]),
    };
  }
  if (actual is List && expected is List) {
    return [
      for (var i = 0; i < actual.length; i++)
        normalise(actual[i], i < expected.length ? expected[i] : null),
    ];
  }
  return actual;
}

bool _isDefault(Object? v) => v == null || v == false || (v is List && v.isEmpty);

void main() {
  // The example is the schema's own; flutter test runs from app/.
  final exampleJson =
      jsonDecode(File('../schema/examples/draft.json').readAsStringSync())
          as Map<String, Object?>;

  group('Draft', () {
    test('parses schema/examples/draft.json', () {
      final draft = Draft.fromJson(exampleJson);
      expect(draft.id, '01994f5e-7c3a-7b2e-9d41-5a6f0c2e8b17');
      expect(draft.createdAt, DateTime.utc(2026, 9, 18, 9, 30));
      expect(draft.ingredients, hasLength(8));
      expect(draft.ingredients.last.quantity, isNull);
      expect(draft.ingredients.last.unit, isNull);
      expect(draft.ingredients.last.optional, isTrue);
      expect(draft.ingredients.first.unit, Unit.g);
      expect(draft.steps.first.temperatureC, 220);
      expect(draft.steps.first.timerSeconds, 600);
      expect(draft.steps.first.ingredientIds, ['i1', 'i2']);
      expect(draft.macros.source, MacroSource.modelEstimate);
      expect(draft.mealTypes, [MealType.lunch, MealType.dinner]);
      expect(draft.cover, const Cover.emoji(emoji: '🍜'));
      expect(draft.source.kind, SourceKind.generated);
    });

    test('round-trips the example without changing a value', () {
      final draft = Draft.fromJson(exampleJson);
      final out = draft.toJson();
      expect(normalise(out, exampleJson), exampleJson);
      expect(Draft.fromJson(out), draft);
    });

    test('keeps required nulls on the wire', () {
      final draft = Draft.fromJson(exampleJson);
      final toTaste = draft.toJson()['ingredients'] as List;
      final last = toTaste.last as Map;
      expect(last.containsKey('quantity'), isTrue);
      expect(last['quantity'], isNull);
      expect(last['unit'], isNull);
    });

    test('ignores unknown fields (H19)', () {
      final json = {...exampleJson, 'somethingNew': 1};
      expect(Draft.fromJson(json), Draft.fromJson(exampleJson));
    });
  });

  group('enum fallbacks (H19)', () {
    test('an unknown unit becomes Unit.unknown', () {
      final json = {
        ...exampleJson['ingredients']!.asList.first,
        'unit': 'cup',
      };
      expect(Ingredient.fromJson(json).unit, Unit.unknown);
    });

    test('an unknown meal type is dropped', () {
      final json = {...exampleJson, 'mealTypes': ['lunch', 'brunch']};
      expect(Draft.fromJson(json).mealTypes, [MealType.lunch]);
    });

    test('an unknown macros source is treated as an estimate', () {
      final json = {...exampleJson['macros'] as Map, 'source': 'usda'};
      expect(Macros.fromJson(json.cast()).source, MacroSource.modelEstimate);
    });

    test('an unknown cover kind falls back to the emoji', () {
      final cover = Cover.fromJson({'kind': 'generated', 'emoji': '🥘', 'imageId': 'x'});
      expect(cover, const Cover.emoji(emoji: '🥘'));
    });

    test('a photo cover keeps its emoji', () {
      final cover = Cover.fromJson({
        'kind': 'photo',
        'emoji': '🥘',
        'photoPath': 'users/u/recipes/r/cover.jpg',
      });
      expect(cover, const Cover.photo(emoji: '🥘', photoPath: 'users/u/recipes/r/cover.jpg'));
      expect(cover.toJson()['kind'], 'photo');
    });

    test('an unknown source kind parses', () {
      expect(Source.fromJson({'kind': 'video'}).kind, SourceKind.unknown);
    });
  });

  group('Recipe', () {
    test('fromDraft keeps the body and starts at revision 1', () {
      final draft = Draft.fromJson(exampleJson);
      final savedAt = DateTime.utc(2026, 9, 19, 10);
      final recipe = Recipe.fromDraft(draft, ownerUid: 'u1', savedAt: savedAt);
      expect(recipe.id, draft.id);
      expect(recipe.revision, 1);
      expect(recipe.ownerUid, 'u1');
      expect(recipe.savedAt, savedAt);
      expect(recipe.updatedAt, savedAt);
      expect(recipe.private, isNull);
      expect(Draft.fromJson(recipe.toJson()), draft, reason: 'the body is unchanged');
    });

    test('reads a stored document with Timestamps and a private map', () {
      final draft = Draft.fromJson(exampleJson);
      final recipe = Recipe.fromDraft(
        draft,
        ownerUid: 'u1',
        savedAt: DateTime.utc(2026, 9, 19, 10),
      ).copyWith(
        private: RecipePrivate(
          rating: Rating(stars: 4, ratedAt: DateTime.utc(2026, 9, 20), recipeRevision: 1),
          collectionIds: const ['c1'],
          cookCount: 1,
          lastCookedAt: DateTime.utc(2026, 9, 20),
        ),
      );
      final wire = recipe.toJson();
      expect(wire['savedAt'], '2026-09-19T10:00:00Z');

      // What Firestore holds: the same map with Timestamps at the date paths.
      final stored = FirestoreDates.encode(wire, Recipe.firestoreDatePaths);
      expect(stored['savedAt'], isA<Timestamp>());
      expect((stored['private'] as Map)['lastCookedAt'], isA<Timestamp>());
      expect(((stored['private'] as Map)['rating'] as Map)['ratedAt'], isA<Timestamp>());

      expect(Recipe.fromJson(stored), recipe, reason: 'reads Timestamps directly');
      expect(Recipe.fromJson(wire), recipe, reason: 'reads strings directly');
    });
  });
}

extension on Object {
  List<Map<String, Object?>> get asList => (this as List).cast<Map<String, Object?>>();
}
