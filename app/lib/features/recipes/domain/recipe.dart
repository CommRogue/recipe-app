import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/firestore/rfc3339.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

// Dart side of the Go-to-Dart contract, schema/recipe.schema.json (ADR 0002,
// ADR 0004). Written by hand from the schema for now; the map's "Not yet
// specified" list holds generating both sides from the schema.
//
// Readers ignore unknown fields (json_serializable's default) and map unknown
// enum values to the fallback the schema names for each enum (H19).

/// Closed, metric-canonical unit set. `unknown` is the fallback for a value a
/// newer schema added: show the quantity with no unit and do not convert.
enum Unit { g, ml, tsp, tbsp, piece, clove, slice, sprig, bunch, pinch, unknown }

/// When a Recipe is eaten. An unknown value is dropped (see [MealTypesConverter]).
enum MealType { breakfast, lunch, dinner, snack, dessert, drink }

/// Drives the "estimate" label (H3). An unknown value is treated as an estimate.
enum MacroSource {
  @JsonValue('model_estimate')
  modelEstimate,
}

/// Provenance (H4). v1 only writes `generated`; an unknown kind renders the
/// recipe with no attribution.
enum SourceKind { generated, unknown }

/// Drops unknown meal types instead of failing the whole Recipe.
class MealTypesConverter
    implements JsonConverter<List<MealType>, List<dynamic>> {
  const MealTypesConverter();

  static final _byName = {for (final m in MealType.values) m.name: m};

  @override
  List<MealType> fromJson(List<dynamic> json) => [
    for (final v in json)
      if (v is String && _byName.containsKey(v)) _byName[v]!,
  ];

  @override
  List<dynamic> toJson(List<MealType> object) => [
    for (final m in object) m.name,
  ];
}

@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    /// `i1`, `i2`, ... referenced by [Step.ingredientIds].
    required String id,

    /// The ingredient alone: "onion", not "1 large onion, finely diced".
    required String name,

    /// Null together with [unit] for "to taste".
    required double? quantity,
    @JsonKey(unknownEnumValue: Unit.unknown) required Unit? unit,
    String? preparation,
    String? group,
    @Default(false) bool optional,
  }) = _Ingredient;

  factory Ingredient.fromJson(Map<String, Object?> json) =>
      _$IngredientFromJson(json);
}

@freezed
abstract class Step with _$Step {
  const factory Step({
    /// Names ingredients without quantities and holds no temperatures; the
    /// app renders both beside the step in the viewer's Unit System.
    required String text,
    required List<String> ingredientIds,
    int? timerSeconds,
    double? temperatureC,
  }) = _Step;

  factory Step.fromJson(Map<String, Object?> json) => _$StepFromJson(json);
}

@freezed
abstract class Cookware with _$Cookware {
  const factory Cookware({required String name}) = _Cookware;

  factory Cookware.fromJson(Map<String, Object?> json) =>
      _$CookwareFromJson(json);
}

/// Estimated Macros, per serving.
@freezed
abstract class Macros with _$Macros {
  const factory Macros({
    @JsonKey(unknownEnumValue: MacroSource.modelEstimate)
    required MacroSource source,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required double fibreG,
  }) = _Macros;

  factory Macros.fromJson(Map<String, Object?> json) => _$MacrosFromJson(json);
}

/// The Cover (H13). The emoji is always kept, so removing a photo needs no
/// model call. An unknown `kind` falls back to the emoji.
@Freezed(unionKey: 'kind', fallbackUnion: 'emoji')
sealed class Cover with _$Cover {
  const factory Cover.emoji({required String emoji}) = EmojiCover;

  /// [photoPath] is a Cloud Storage path under the owner's prefix, never a
  /// download URL.
  const factory Cover.photo({
    required String emoji,
    required String photoPath,
  }) = PhotoCover;

  factory Cover.fromJson(Map<String, Object?> json) => _$CoverFromJson(json);
}

@freezed
abstract class DerivedFrom with _$DerivedFrom {
  const factory DerivedFrom({
    required String recipeId,
    required int revision,
  }) = _DerivedFrom;

  factory DerivedFrom.fromJson(Map<String, Object?> json) =>
      _$DerivedFromFromJson(json);
}

@freezed
abstract class Source with _$Source {
  const factory Source({
    @JsonKey(unknownEnumValue: SourceKind.unknown) required SourceKind kind,
    String? url,
    String? attribution,
    DerivedFrom? derivedFrom,
  }) = _Source;

  factory Source.fromJson(Map<String, Object?> json) => _$SourceFromJson(json);
}

/// What the Go service returns: a recipe the user has not saved. Holds nothing
/// about the Generation Request that produced it (H16).
@freezed
abstract class Draft with _$Draft {
  const factory Draft({
    /// UUIDv7 minted by the Go service; saving keeps it as the Recipe id.
    required String id,
    required int schemaVersion,
    required Source source,
    @Rfc3339DateTimeConverter() required DateTime createdAt,
    required String title,
    required String description,
    required double servings,
    required int activeMinutes,
    required int passiveMinutes,
    required List<Ingredient> ingredients,
    required List<Step> steps,
    @Default([]) List<Cookware> cookware,
    required Macros macros,
    String? cuisine,
    @MealTypesConverter() @Default([]) List<MealType> mealTypes,
    required Cover cover,
  }) = _Draft;

  factory Draft.fromJson(Map<String, Object?> json) => _$DraftFromJson(json);
}

/// A Rating (H9), owner-private, stored at `private.rating`.
@freezed
abstract class Rating with _$Rating {
  const factory Rating({
    required int stars,
    String? note,
    @Rfc3339DateTimeConverter() required DateTime ratedAt,
    required int recipeRevision,
  }) = _Rating;

  factory Rating.fromJson(Map<String, Object?> json) => _$RatingFromJson(json);
}

/// Owner-private data on the Recipe document (ADR 0007). A missing map or
/// member means unrated, in no Collection, never cooked.
@freezed
abstract class RecipePrivate with _$RecipePrivate {
  const factory RecipePrivate({
    Rating? rating,
    @Default([]) List<String> collectionIds,
    @Default(0) int cookCount,
    @Rfc3339DateTimeConverter() DateTime? lastCookedAt,
  }) = _RecipePrivate;

  factory RecipePrivate.fromJson(Map<String, Object?> json) =>
      _$RecipePrivateFromJson(json);
}

/// A saved Draft: the same body plus ownership and revision, stored at
/// `users/{uid}/recipes/{id}`. Renders from this document alone (H5).
@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required int schemaVersion,
    required Source source,
    @Rfc3339DateTimeConverter() required DateTime createdAt,
    required String title,
    required String description,
    required double servings,
    required int activeMinutes,
    required int passiveMinutes,
    required List<Ingredient> ingredients,
    required List<Step> steps,
    @Default([]) List<Cookware> cookware,
    required Macros macros,
    String? cuisine,
    @MealTypesConverter() @Default([]) List<MealType> mealTypes,
    required Cover cover,
    required String ownerUid,
    required int revision,
    @Rfc3339DateTimeConverter() required DateTime savedAt,
    @Rfc3339DateTimeConverter() required DateTime updatedAt,
    RecipePrivate? private,
  }) = _Recipe;

  const Recipe._();

  factory Recipe.fromJson(Map<String, Object?> json) => _$RecipeFromJson(json);

  /// The Recipe that saving [draft] produces: the body unchanged, revision 1.
  /// The caller stores it with `savedAt` and `updatedAt` as server timestamps
  /// (see [firestoreDatePaths]).
  factory Recipe.fromDraft(
    Draft draft, {
    required String ownerUid,
    required DateTime savedAt,
  }) => Recipe(
    id: draft.id,
    schemaVersion: draft.schemaVersion,
    source: draft.source,
    createdAt: draft.createdAt,
    title: draft.title,
    description: draft.description,
    servings: draft.servings,
    activeMinutes: draft.activeMinutes,
    passiveMinutes: draft.passiveMinutes,
    ingredients: draft.ingredients,
    steps: draft.steps,
    cookware: draft.cookware,
    macros: draft.macros,
    cuisine: draft.cuisine,
    mealTypes: draft.mealTypes,
    cover: draft.cover,
    ownerUid: ownerUid,
    revision: 1,
    savedAt: savedAt,
    updatedAt: savedAt,
  );

  /// The date-time fields of a stored Recipe, for [FirestoreDates].
  static const firestoreDatePaths = [
    'createdAt',
    'savedAt',
    'updatedAt',
    'private.rating.ratedAt',
    'private.lastCookedAt',
  ];
}
