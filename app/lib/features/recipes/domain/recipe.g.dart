// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Ingredient _$IngredientFromJson(Map<String, dynamic> json) => _Ingredient(
  id: json['id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toDouble(),
  unit: $enumDecodeNullable(
    _$UnitEnumMap,
    json['unit'],
    unknownValue: Unit.unknown,
  ),
  preparation: json['preparation'] as String?,
  group: json['group'] as String?,
  optional: json['optional'] as bool? ?? false,
);

Map<String, dynamic> _$IngredientToJson(_Ingredient instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': _$UnitEnumMap[instance.unit],
      'preparation': instance.preparation,
      'group': instance.group,
      'optional': instance.optional,
    };

const _$UnitEnumMap = {
  Unit.g: 'g',
  Unit.ml: 'ml',
  Unit.tsp: 'tsp',
  Unit.tbsp: 'tbsp',
  Unit.piece: 'piece',
  Unit.clove: 'clove',
  Unit.slice: 'slice',
  Unit.sprig: 'sprig',
  Unit.bunch: 'bunch',
  Unit.pinch: 'pinch',
  Unit.unknown: 'unknown',
};

_Step _$StepFromJson(Map<String, dynamic> json) => _Step(
  text: json['text'] as String,
  ingredientIds: (json['ingredientIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  timerSeconds: (json['timerSeconds'] as num?)?.toInt(),
  temperatureC: (json['temperatureC'] as num?)?.toDouble(),
);

Map<String, dynamic> _$StepToJson(_Step instance) => <String, dynamic>{
  'text': instance.text,
  'ingredientIds': instance.ingredientIds,
  'timerSeconds': instance.timerSeconds,
  'temperatureC': instance.temperatureC,
};

_Cookware _$CookwareFromJson(Map<String, dynamic> json) =>
    _Cookware(name: json['name'] as String);

Map<String, dynamic> _$CookwareToJson(_Cookware instance) => <String, dynamic>{
  'name': instance.name,
};

_Macros _$MacrosFromJson(Map<String, dynamic> json) => _Macros(
  source: $enumDecode(
    _$MacroSourceEnumMap,
    json['source'],
    unknownValue: MacroSource.modelEstimate,
  ),
  calories: (json['calories'] as num).toDouble(),
  proteinG: (json['proteinG'] as num).toDouble(),
  carbsG: (json['carbsG'] as num).toDouble(),
  fatG: (json['fatG'] as num).toDouble(),
  fibreG: (json['fibreG'] as num).toDouble(),
);

Map<String, dynamic> _$MacrosToJson(_Macros instance) => <String, dynamic>{
  'source': _$MacroSourceEnumMap[instance.source]!,
  'calories': instance.calories,
  'proteinG': instance.proteinG,
  'carbsG': instance.carbsG,
  'fatG': instance.fatG,
  'fibreG': instance.fibreG,
};

const _$MacroSourceEnumMap = {MacroSource.modelEstimate: 'model_estimate'};

EmojiCover _$EmojiCoverFromJson(Map<String, dynamic> json) =>
    EmojiCover(emoji: json['emoji'] as String, $type: json['kind'] as String?);

Map<String, dynamic> _$EmojiCoverToJson(EmojiCover instance) =>
    <String, dynamic>{'emoji': instance.emoji, 'kind': instance.$type};

PhotoCover _$PhotoCoverFromJson(Map<String, dynamic> json) => PhotoCover(
  emoji: json['emoji'] as String,
  photoPath: json['photoPath'] as String?,
  $type: json['kind'] as String?,
);

Map<String, dynamic> _$PhotoCoverToJson(PhotoCover instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'photoPath': instance.photoPath,
      'kind': instance.$type,
    };

_DerivedFrom _$DerivedFromFromJson(Map<String, dynamic> json) => _DerivedFrom(
  recipeId: json['recipeId'] as String,
  revision: (json['revision'] as num).toInt(),
);

Map<String, dynamic> _$DerivedFromToJson(_DerivedFrom instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'revision': instance.revision,
    };

_Source _$SourceFromJson(Map<String, dynamic> json) => _Source(
  kind: $enumDecode(
    _$SourceKindEnumMap,
    json['kind'],
    unknownValue: SourceKind.unknown,
  ),
  url: json['url'] as String?,
  attribution: json['attribution'] as String?,
  derivedFrom: json['derivedFrom'] == null
      ? null
      : DerivedFrom.fromJson(json['derivedFrom'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SourceToJson(_Source instance) => <String, dynamic>{
  'kind': _$SourceKindEnumMap[instance.kind]!,
  'url': instance.url,
  'attribution': instance.attribution,
  'derivedFrom': instance.derivedFrom?.toJson(),
};

const _$SourceKindEnumMap = {
  SourceKind.generated: 'generated',
  SourceKind.unknown: 'unknown',
};

_Draft _$DraftFromJson(Map<String, dynamic> json) => _Draft(
  id: json['id'] as String,
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  source: Source.fromJson(json['source'] as Map<String, dynamic>),
  createdAt: const Rfc3339DateTimeConverter().fromJson(
    json['createdAt'] as Object,
  ),
  title: json['title'] as String,
  description: json['description'] as String,
  servings: (json['servings'] as num).toDouble(),
  activeMinutes: (json['activeMinutes'] as num).toInt(),
  passiveMinutes: (json['passiveMinutes'] as num).toInt(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => Step.fromJson(e as Map<String, dynamic>))
      .toList(),
  cookware:
      (json['cookware'] as List<dynamic>?)
          ?.map((e) => Cookware.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
  cuisine: json['cuisine'] as String?,
  mealTypes: json['mealTypes'] == null
      ? const []
      : const MealTypesConverter().fromJson(json['mealTypes'] as List),
  cover: Cover.fromJson(json['cover'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DraftToJson(_Draft instance) => <String, dynamic>{
  'id': instance.id,
  'schemaVersion': instance.schemaVersion,
  'source': instance.source.toJson(),
  'createdAt': const Rfc3339DateTimeConverter().toJson(instance.createdAt),
  'title': instance.title,
  'description': instance.description,
  'servings': instance.servings,
  'activeMinutes': instance.activeMinutes,
  'passiveMinutes': instance.passiveMinutes,
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'cookware': instance.cookware.map((e) => e.toJson()).toList(),
  'macros': instance.macros.toJson(),
  'cuisine': instance.cuisine,
  'mealTypes': const MealTypesConverter().toJson(instance.mealTypes),
  'cover': instance.cover.toJson(),
};

_Rating _$RatingFromJson(Map<String, dynamic> json) => _Rating(
  stars: (json['stars'] as num).toInt(),
  note: json['note'] as String?,
  ratedAt: const Rfc3339DateTimeConverter().fromJson(json['ratedAt'] as Object),
  recipeRevision: (json['recipeRevision'] as num).toInt(),
);

Map<String, dynamic> _$RatingToJson(_Rating instance) => <String, dynamic>{
  'stars': instance.stars,
  'note': instance.note,
  'ratedAt': const Rfc3339DateTimeConverter().toJson(instance.ratedAt),
  'recipeRevision': instance.recipeRevision,
};

_RecipePrivate _$RecipePrivateFromJson(Map<String, dynamic> json) =>
    _RecipePrivate(
      rating: json['rating'] == null
          ? null
          : Rating.fromJson(json['rating'] as Map<String, dynamic>),
      collectionIds:
          (json['collectionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cookCount: (json['cookCount'] as num?)?.toInt() ?? 0,
      lastCookedAt: _$JsonConverterFromJson<Object, DateTime>(
        json['lastCookedAt'],
        const Rfc3339DateTimeConverter().fromJson,
      ),
    );

Map<String, dynamic> _$RecipePrivateToJson(_RecipePrivate instance) =>
    <String, dynamic>{
      'rating': instance.rating?.toJson(),
      'collectionIds': instance.collectionIds,
      'cookCount': instance.cookCount,
      'lastCookedAt': _$JsonConverterToJson<Object, DateTime>(
        instance.lastCookedAt,
        const Rfc3339DateTimeConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_Recipe _$RecipeFromJson(Map<String, dynamic> json) => _Recipe(
  id: json['id'] as String,
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  source: Source.fromJson(json['source'] as Map<String, dynamic>),
  createdAt: const Rfc3339DateTimeConverter().fromJson(
    json['createdAt'] as Object,
  ),
  title: json['title'] as String,
  description: json['description'] as String,
  servings: (json['servings'] as num).toDouble(),
  activeMinutes: (json['activeMinutes'] as num).toInt(),
  passiveMinutes: (json['passiveMinutes'] as num).toInt(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => Step.fromJson(e as Map<String, dynamic>))
      .toList(),
  cookware:
      (json['cookware'] as List<dynamic>?)
          ?.map((e) => Cookware.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
  cuisine: json['cuisine'] as String?,
  mealTypes: json['mealTypes'] == null
      ? const []
      : const MealTypesConverter().fromJson(json['mealTypes'] as List),
  cover: Cover.fromJson(json['cover'] as Map<String, dynamic>),
  ownerUid: json['ownerUid'] as String,
  revision: (json['revision'] as num).toInt(),
  savedAt: const Rfc3339DateTimeConverter().fromJson(json['savedAt'] as Object),
  updatedAt: const Rfc3339DateTimeConverter().fromJson(
    json['updatedAt'] as Object,
  ),
  private: json['private'] == null
      ? null
      : RecipePrivate.fromJson(json['private'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecipeToJson(_Recipe instance) => <String, dynamic>{
  'id': instance.id,
  'schemaVersion': instance.schemaVersion,
  'source': instance.source.toJson(),
  'createdAt': const Rfc3339DateTimeConverter().toJson(instance.createdAt),
  'title': instance.title,
  'description': instance.description,
  'servings': instance.servings,
  'activeMinutes': instance.activeMinutes,
  'passiveMinutes': instance.passiveMinutes,
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'cookware': instance.cookware.map((e) => e.toJson()).toList(),
  'macros': instance.macros.toJson(),
  'cuisine': instance.cuisine,
  'mealTypes': const MealTypesConverter().toJson(instance.mealTypes),
  'cover': instance.cover.toJson(),
  'ownerUid': instance.ownerUid,
  'revision': instance.revision,
  'savedAt': const Rfc3339DateTimeConverter().toJson(instance.savedAt),
  'updatedAt': const Rfc3339DateTimeConverter().toJson(instance.updatedAt),
  'private': instance.private?.toJson(),
};
