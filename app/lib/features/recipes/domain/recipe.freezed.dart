// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ingredient {

/// `i1`, `i2`, ... referenced by [Step.ingredientIds].
 String get id;/// The ingredient alone: "onion", not "1 large onion, finely diced".
 String get name;/// Null together with [unit] for "to taste".
 double? get quantity;@JsonKey(unknownEnumValue: Unit.unknown) Unit? get unit; String? get preparation; String? get group; bool get optional;
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientCopyWith<Ingredient> get copyWith => _$IngredientCopyWithImpl<Ingredient>(this as Ingredient, _$identity);

  /// Serializes this Ingredient to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Ingredient;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ingredient&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.preparation, _this.preparation) || other.preparation == _this.preparation)&&(identical(other.group, _this.group) || other.group == _this.group)&&(identical(other.optional, _this.optional) || other.optional == _this.optional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Ingredient;
  return Object.hash(runtimeType,_this.id,_this.name,_this.quantity,_this.unit,_this.preparation,_this.group,_this.optional);
}

@override
String toString() {
  final _this = this as Ingredient;
  return 'Ingredient(id: ${_this.id}, name: ${_this.name}, quantity: ${_this.quantity}, unit: ${_this.unit}, preparation: ${_this.preparation}, group: ${_this.group}, optional: ${_this.optional})';
}


}

/// @nodoc
abstract mixin class $IngredientCopyWith<$Res>  {
  factory $IngredientCopyWith(Ingredient value, $Res Function(Ingredient) _then) = _$IngredientCopyWithImpl;
@useResult
$Res call({
 String id, String name, double? quantity,@JsonKey(unknownEnumValue: Unit.unknown) Unit? unit, String? preparation, String? group, bool optional
});




}
/// @nodoc
class _$IngredientCopyWithImpl<$Res>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._self, this._then);

  final Ingredient _self;
  final $Res Function(Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? quantity = freezed,Object? unit = freezed,Object? preparation = freezed,Object? group = freezed,Object? optional = null,}) {
  return _then(Ingredient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as Unit?,preparation: freezed == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,optional: null == optional ? _self.optional : optional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Ingredient].
extension IngredientPatterns on Ingredient {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ingredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ingredient value)  $default,){
final _that = this;
switch (_that) {
case _Ingredient():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ingredient value)?  $default,){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double? quantity, @JsonKey(unknownEnumValue: Unit.unknown)  Unit? unit,  String? preparation,  String? group,  bool optional)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.name,_that.quantity,_that.unit,_that.preparation,_that.group,_that.optional);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double? quantity, @JsonKey(unknownEnumValue: Unit.unknown)  Unit? unit,  String? preparation,  String? group,  bool optional)  $default,) {final _that = this;
switch (_that) {
case _Ingredient():
return $default(_that.id,_that.name,_that.quantity,_that.unit,_that.preparation,_that.group,_that.optional);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double? quantity, @JsonKey(unknownEnumValue: Unit.unknown)  Unit? unit,  String? preparation,  String? group,  bool optional)?  $default,) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.name,_that.quantity,_that.unit,_that.preparation,_that.group,_that.optional);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ingredient implements Ingredient {
  const _Ingredient({required this.id, required this.name, required this.quantity, @JsonKey(unknownEnumValue: Unit.unknown) required this.unit, this.preparation, this.group, this.optional = false});
  factory _Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);

/// `i1`, `i2`, ... referenced by [Step.ingredientIds].
@override final  String id;
/// The ingredient alone: "onion", not "1 large onion, finely diced".
@override final  String name;
/// Null together with [unit] for "to taste".
@override final  double? quantity;
@override@JsonKey(unknownEnumValue: Unit.unknown) final  Unit? unit;
@override final  String? preparation;
@override final  String? group;
@override@JsonKey() final  bool optional;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientCopyWith<_Ingredient> get copyWith => __$IngredientCopyWithImpl<_Ingredient>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.preparation, preparation) || other.preparation == preparation)&&(identical(other.group, group) || other.group == group)&&(identical(other.optional, optional) || other.optional == optional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,quantity,unit,preparation,group,optional);
}

@override
String toString() {
    return 'Ingredient(id: $id, name: $name, quantity: $quantity, unit: $unit, preparation: $preparation, group: $group, optional: $optional)';
}


}

/// @nodoc
abstract mixin class _$IngredientCopyWith<$Res> implements $IngredientCopyWith<$Res> {
  factory _$IngredientCopyWith(_Ingredient value, $Res Function(_Ingredient) _then) = __$IngredientCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double? quantity,@JsonKey(unknownEnumValue: Unit.unknown) Unit? unit, String? preparation, String? group, bool optional
});




}
/// @nodoc
class __$IngredientCopyWithImpl<$Res>
    implements _$IngredientCopyWith<$Res> {
  __$IngredientCopyWithImpl(this._self, this._then);

  final _Ingredient _self;
  final $Res Function(_Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? quantity = freezed,Object? unit = freezed,Object? preparation = freezed,Object? group = freezed,Object? optional = null,}) {
  return _then(_Ingredient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as Unit?,preparation: freezed == preparation ? _self.preparation : preparation // ignore: cast_nullable_to_non_nullable
as String?,group: freezed == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String?,optional: null == optional ? _self.optional : optional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Step {

/// Names ingredients without quantities and holds no temperatures; the
/// app renders both beside the step in the viewer's Unit System.
 String get text; List<String> get ingredientIds; int? get timerSeconds; double? get temperatureC;
/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StepCopyWith<Step> get copyWith => _$StepCopyWithImpl<Step>(this as Step, _$identity);

  /// Serializes this Step to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Step;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Step&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.ingredientIds, _this.ingredientIds)&&(identical(other.timerSeconds, _this.timerSeconds) || other.timerSeconds == _this.timerSeconds)&&(identical(other.temperatureC, _this.temperatureC) || other.temperatureC == _this.temperatureC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Step;
  return Object.hash(runtimeType,_this.text,const DeepCollectionEquality().hash(_this.ingredientIds),_this.timerSeconds,_this.temperatureC);
}

@override
String toString() {
  final _this = this as Step;
  return 'Step(text: ${_this.text}, ingredientIds: ${_this.ingredientIds}, timerSeconds: ${_this.timerSeconds}, temperatureC: ${_this.temperatureC})';
}


}

/// @nodoc
abstract mixin class $StepCopyWith<$Res>  {
  factory $StepCopyWith(Step value, $Res Function(Step) _then) = _$StepCopyWithImpl;
@useResult
$Res call({
 String text, List<String> ingredientIds, int? timerSeconds, double? temperatureC
});




}
/// @nodoc
class _$StepCopyWithImpl<$Res>
    implements $StepCopyWith<$Res> {
  _$StepCopyWithImpl(this._self, this._then);

  final Step _self;
  final $Res Function(Step) _then;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = null,Object? ingredientIds = null,Object? timerSeconds = freezed,Object? temperatureC = freezed,}) {
  return _then(Step(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,ingredientIds: null == ingredientIds ? _self.ingredientIds : ingredientIds // ignore: cast_nullable_to_non_nullable
as List<String>,timerSeconds: freezed == timerSeconds ? _self.timerSeconds : timerSeconds // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Step].
extension StepPatterns on Step {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Step value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Step() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Step value)  $default,){
final _that = this;
switch (_that) {
case _Step():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Step value)?  $default,){
final _that = this;
switch (_that) {
case _Step() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String text,  List<String> ingredientIds,  int? timerSeconds,  double? temperatureC)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Step() when $default != null:
return $default(_that.text,_that.ingredientIds,_that.timerSeconds,_that.temperatureC);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String text,  List<String> ingredientIds,  int? timerSeconds,  double? temperatureC)  $default,) {final _that = this;
switch (_that) {
case _Step():
return $default(_that.text,_that.ingredientIds,_that.timerSeconds,_that.temperatureC);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String text,  List<String> ingredientIds,  int? timerSeconds,  double? temperatureC)?  $default,) {final _that = this;
switch (_that) {
case _Step() when $default != null:
return $default(_that.text,_that.ingredientIds,_that.timerSeconds,_that.temperatureC);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Step implements Step {
  const _Step({required this.text, required  List<String> ingredientIds, this.timerSeconds, this.temperatureC}): _ingredientIds = ingredientIds;
  factory _Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);

/// Names ingredients without quantities and holds no temperatures; the
/// app renders both beside the step in the viewer's Unit System.
@override final  String text;
 final  List<String> _ingredientIds;
@override List<String> get ingredientIds {
  if (_ingredientIds is EqualUnmodifiableListView) return _ingredientIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredientIds);
}

@override final  int? timerSeconds;
@override final  double? temperatureC;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StepCopyWith<_Step> get copyWith => __$StepCopyWithImpl<_Step>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StepToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Step&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.ingredientIds, _ingredientIds)&&(identical(other.timerSeconds, timerSeconds) || other.timerSeconds == timerSeconds)&&(identical(other.temperatureC, temperatureC) || other.temperatureC == temperatureC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_ingredientIds),timerSeconds,temperatureC);
}

@override
String toString() {
    return 'Step(text: $text, ingredientIds: $ingredientIds, timerSeconds: $timerSeconds, temperatureC: $temperatureC)';
}


}

/// @nodoc
abstract mixin class _$StepCopyWith<$Res> implements $StepCopyWith<$Res> {
  factory _$StepCopyWith(_Step value, $Res Function(_Step) _then) = __$StepCopyWithImpl;
@override @useResult
$Res call({
 String text, List<String> ingredientIds, int? timerSeconds, double? temperatureC
});




}
/// @nodoc
class __$StepCopyWithImpl<$Res>
    implements _$StepCopyWith<$Res> {
  __$StepCopyWithImpl(this._self, this._then);

  final _Step _self;
  final $Res Function(_Step) _then;

/// Create a copy of Step
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? ingredientIds = null,Object? timerSeconds = freezed,Object? temperatureC = freezed,}) {
  return _then(_Step(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,ingredientIds: null == ingredientIds ? _self._ingredientIds : ingredientIds // ignore: cast_nullable_to_non_nullable
as List<String>,timerSeconds: freezed == timerSeconds ? _self.timerSeconds : timerSeconds // ignore: cast_nullable_to_non_nullable
as int?,temperatureC: freezed == temperatureC ? _self.temperatureC : temperatureC // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$Cookware {

 String get name;
/// Create a copy of Cookware
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookwareCopyWith<Cookware> get copyWith => _$CookwareCopyWithImpl<Cookware>(this as Cookware, _$identity);

  /// Serializes this Cookware to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Cookware;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cookware&&(identical(other.name, _this.name) || other.name == _this.name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Cookware;
  return Object.hash(runtimeType,_this.name);
}

@override
String toString() {
  final _this = this as Cookware;
  return 'Cookware(name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $CookwareCopyWith<$Res>  {
  factory $CookwareCopyWith(Cookware value, $Res Function(Cookware) _then) = _$CookwareCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$CookwareCopyWithImpl<$Res>
    implements $CookwareCopyWith<$Res> {
  _$CookwareCopyWithImpl(this._self, this._then);

  final Cookware _self;
  final $Res Function(Cookware) _then;

/// Create a copy of Cookware
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(Cookware(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Cookware].
extension CookwarePatterns on Cookware {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cookware value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cookware() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cookware value)  $default,){
final _that = this;
switch (_that) {
case _Cookware():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cookware value)?  $default,){
final _that = this;
switch (_that) {
case _Cookware() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cookware() when $default != null:
return $default(_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _Cookware():
return $default(_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _Cookware() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cookware implements Cookware {
  const _Cookware({required this.name});
  factory _Cookware.fromJson(Map<String, dynamic> json) => _$CookwareFromJson(json);

@override final  String name;

/// Create a copy of Cookware
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookwareCopyWith<_Cookware> get copyWith => __$CookwareCopyWithImpl<_Cookware>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CookwareToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cookware&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name);
}

@override
String toString() {
    return 'Cookware(name: $name)';
}


}

/// @nodoc
abstract mixin class _$CookwareCopyWith<$Res> implements $CookwareCopyWith<$Res> {
  factory _$CookwareCopyWith(_Cookware value, $Res Function(_Cookware) _then) = __$CookwareCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$CookwareCopyWithImpl<$Res>
    implements _$CookwareCopyWith<$Res> {
  __$CookwareCopyWithImpl(this._self, this._then);

  final _Cookware _self;
  final $Res Function(_Cookware) _then;

/// Create a copy of Cookware
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_Cookware(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Macros {

@JsonKey(unknownEnumValue: MacroSource.modelEstimate) MacroSource get source; double get calories; double get proteinG; double get carbsG; double get fatG; double get fibreG;
/// Create a copy of Macros
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MacrosCopyWith<Macros> get copyWith => _$MacrosCopyWithImpl<Macros>(this as Macros, _$identity);

  /// Serializes this Macros to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Macros;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Macros&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.calories, _this.calories) || other.calories == _this.calories)&&(identical(other.proteinG, _this.proteinG) || other.proteinG == _this.proteinG)&&(identical(other.carbsG, _this.carbsG) || other.carbsG == _this.carbsG)&&(identical(other.fatG, _this.fatG) || other.fatG == _this.fatG)&&(identical(other.fibreG, _this.fibreG) || other.fibreG == _this.fibreG));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Macros;
  return Object.hash(runtimeType,_this.source,_this.calories,_this.proteinG,_this.carbsG,_this.fatG,_this.fibreG);
}

@override
String toString() {
  final _this = this as Macros;
  return 'Macros(source: ${_this.source}, calories: ${_this.calories}, proteinG: ${_this.proteinG}, carbsG: ${_this.carbsG}, fatG: ${_this.fatG}, fibreG: ${_this.fibreG})';
}


}

/// @nodoc
abstract mixin class $MacrosCopyWith<$Res>  {
  factory $MacrosCopyWith(Macros value, $Res Function(Macros) _then) = _$MacrosCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: MacroSource.modelEstimate) MacroSource source, double calories, double proteinG, double carbsG, double fatG, double fibreG
});




}
/// @nodoc
class _$MacrosCopyWithImpl<$Res>
    implements $MacrosCopyWith<$Res> {
  _$MacrosCopyWithImpl(this._self, this._then);

  final Macros _self;
  final $Res Function(Macros) _then;

/// Create a copy of Macros
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? calories = null,Object? proteinG = null,Object? carbsG = null,Object? fatG = null,Object? fibreG = null,}) {
  return _then(Macros(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MacroSource,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,proteinG: null == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double,carbsG: null == carbsG ? _self.carbsG : carbsG // ignore: cast_nullable_to_non_nullable
as double,fatG: null == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double,fibreG: null == fibreG ? _self.fibreG : fibreG // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Macros].
extension MacrosPatterns on Macros {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Macros value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Macros() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Macros value)  $default,){
final _that = this;
switch (_that) {
case _Macros():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Macros value)?  $default,){
final _that = this;
switch (_that) {
case _Macros() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: MacroSource.modelEstimate)  MacroSource source,  double calories,  double proteinG,  double carbsG,  double fatG,  double fibreG)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Macros() when $default != null:
return $default(_that.source,_that.calories,_that.proteinG,_that.carbsG,_that.fatG,_that.fibreG);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: MacroSource.modelEstimate)  MacroSource source,  double calories,  double proteinG,  double carbsG,  double fatG,  double fibreG)  $default,) {final _that = this;
switch (_that) {
case _Macros():
return $default(_that.source,_that.calories,_that.proteinG,_that.carbsG,_that.fatG,_that.fibreG);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: MacroSource.modelEstimate)  MacroSource source,  double calories,  double proteinG,  double carbsG,  double fatG,  double fibreG)?  $default,) {final _that = this;
switch (_that) {
case _Macros() when $default != null:
return $default(_that.source,_that.calories,_that.proteinG,_that.carbsG,_that.fatG,_that.fibreG);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Macros implements Macros {
  const _Macros({@JsonKey(unknownEnumValue: MacroSource.modelEstimate) required this.source, required this.calories, required this.proteinG, required this.carbsG, required this.fatG, required this.fibreG});
  factory _Macros.fromJson(Map<String, dynamic> json) => _$MacrosFromJson(json);

@override@JsonKey(unknownEnumValue: MacroSource.modelEstimate) final  MacroSource source;
@override final  double calories;
@override final  double proteinG;
@override final  double carbsG;
@override final  double fatG;
@override final  double fibreG;

/// Create a copy of Macros
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MacrosCopyWith<_Macros> get copyWith => __$MacrosCopyWithImpl<_Macros>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MacrosToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Macros&&(identical(other.source, source) || other.source == source)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.proteinG, proteinG) || other.proteinG == proteinG)&&(identical(other.carbsG, carbsG) || other.carbsG == carbsG)&&(identical(other.fatG, fatG) || other.fatG == fatG)&&(identical(other.fibreG, fibreG) || other.fibreG == fibreG));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,source,calories,proteinG,carbsG,fatG,fibreG);
}

@override
String toString() {
    return 'Macros(source: $source, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatG: $fatG, fibreG: $fibreG)';
}


}

/// @nodoc
abstract mixin class _$MacrosCopyWith<$Res> implements $MacrosCopyWith<$Res> {
  factory _$MacrosCopyWith(_Macros value, $Res Function(_Macros) _then) = __$MacrosCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: MacroSource.modelEstimate) MacroSource source, double calories, double proteinG, double carbsG, double fatG, double fibreG
});




}
/// @nodoc
class __$MacrosCopyWithImpl<$Res>
    implements _$MacrosCopyWith<$Res> {
  __$MacrosCopyWithImpl(this._self, this._then);

  final _Macros _self;
  final $Res Function(_Macros) _then;

/// Create a copy of Macros
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? calories = null,Object? proteinG = null,Object? carbsG = null,Object? fatG = null,Object? fibreG = null,}) {
  return _then(_Macros(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as MacroSource,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double,proteinG: null == proteinG ? _self.proteinG : proteinG // ignore: cast_nullable_to_non_nullable
as double,carbsG: null == carbsG ? _self.carbsG : carbsG // ignore: cast_nullable_to_non_nullable
as double,fatG: null == fatG ? _self.fatG : fatG // ignore: cast_nullable_to_non_nullable
as double,fibreG: null == fibreG ? _self.fibreG : fibreG // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

Cover _$CoverFromJson(
  Map<String, dynamic> json
) {
        switch (json['kind']) {
                  case 'photo':
          return PhotoCover.fromJson(
            json
          );
        
          default:
            return EmojiCover.fromJson(
  json
);
        }
      
}

/// @nodoc
mixin _$Cover {

 String get emoji;
/// Create a copy of Cover
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoverCopyWith<Cover> get copyWith => _$CoverCopyWithImpl<Cover>(this as Cover, _$identity);

  /// Serializes this Cover to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Cover;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cover&&(identical(other.emoji, _this.emoji) || other.emoji == _this.emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Cover;
  return Object.hash(runtimeType,_this.emoji);
}

@override
String toString() {
  final _this = this as Cover;
  return 'Cover(emoji: ${_this.emoji})';
}


}

/// @nodoc
abstract mixin class $CoverCopyWith<$Res>  {
  factory $CoverCopyWith(Cover value, $Res Function(Cover) _then) = _$CoverCopyWithImpl;
@useResult
$Res call({
 String emoji
});




}
/// @nodoc
class _$CoverCopyWithImpl<$Res>
    implements $CoverCopyWith<$Res> {
  _$CoverCopyWithImpl(this._self, this._then);

  final Cover _self;
  final $Res Function(Cover) _then;

/// Create a copy of Cover
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emoji = null,}) {
  return _then(_self.copyWith(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Cover].
extension CoverPatterns on Cover {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EmojiCover value)?  emoji,TResult Function( PhotoCover value)?  photo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EmojiCover() when emoji != null:
return emoji(_that);case PhotoCover() when photo != null:
return photo(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EmojiCover value)  emoji,required TResult Function( PhotoCover value)  photo,}){
final _that = this;
switch (_that) {
case EmojiCover():
return emoji(_that);case PhotoCover():
return photo(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EmojiCover value)?  emoji,TResult? Function( PhotoCover value)?  photo,}){
final _that = this;
switch (_that) {
case EmojiCover() when emoji != null:
return emoji(_that);case PhotoCover() when photo != null:
return photo(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String emoji)?  emoji,TResult Function( String emoji,  String? photoPath)?  photo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EmojiCover() when emoji != null:
return emoji(_that.emoji);case PhotoCover() when photo != null:
return photo(_that.emoji,_that.photoPath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String emoji)  emoji,required TResult Function( String emoji,  String? photoPath)  photo,}) {final _that = this;
switch (_that) {
case EmojiCover():
return emoji(_that.emoji);case PhotoCover():
return photo(_that.emoji,_that.photoPath);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String emoji)?  emoji,TResult? Function( String emoji,  String? photoPath)?  photo,}) {final _that = this;
switch (_that) {
case EmojiCover() when emoji != null:
return emoji(_that.emoji);case PhotoCover() when photo != null:
return photo(_that.emoji,_that.photoPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class EmojiCover implements Cover {
  const EmojiCover({required this.emoji,  String? $type}): $type = $type ?? 'emoji';
  factory EmojiCover.fromJson(Map<String, dynamic> json) => _$EmojiCoverFromJson(json);

@override final  String emoji;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Cover
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmojiCoverCopyWith<EmojiCover> get copyWith => _$EmojiCoverCopyWithImpl<EmojiCover>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmojiCoverToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is EmojiCover&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,emoji);
}

@override
String toString() {
    return 'Cover.emoji(emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $EmojiCoverCopyWith<$Res> implements $CoverCopyWith<$Res> {
  factory $EmojiCoverCopyWith(EmojiCover value, $Res Function(EmojiCover) _then) = _$EmojiCoverCopyWithImpl;
@override @useResult
$Res call({
 String emoji
});




}
/// @nodoc
class _$EmojiCoverCopyWithImpl<$Res>
    implements $EmojiCoverCopyWith<$Res> {
  _$EmojiCoverCopyWithImpl(this._self, this._then);

  final EmojiCover _self;
  final $Res Function(EmojiCover) _then;

/// Create a copy of Cover
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,}) {
  return _then(EmojiCover(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PhotoCover implements Cover {
  const PhotoCover({required this.emoji, required this.photoPath,  String? $type}): $type = $type ?? 'photo';
  factory PhotoCover.fromJson(Map<String, dynamic> json) => _$PhotoCoverFromJson(json);

@override final  String emoji;
 final  String? photoPath;

@JsonKey(name: 'kind')
final String $type;


/// Create a copy of Cover
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoCoverCopyWith<PhotoCover> get copyWith => _$PhotoCoverCopyWithImpl<PhotoCover>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoCoverToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoCover&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,emoji,photoPath);
}

@override
String toString() {
    return 'Cover.photo(emoji: $emoji, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class $PhotoCoverCopyWith<$Res> implements $CoverCopyWith<$Res> {
  factory $PhotoCoverCopyWith(PhotoCover value, $Res Function(PhotoCover) _then) = _$PhotoCoverCopyWithImpl;
@override @useResult
$Res call({
 String emoji, String? photoPath
});




}
/// @nodoc
class _$PhotoCoverCopyWithImpl<$Res>
    implements $PhotoCoverCopyWith<$Res> {
  _$PhotoCoverCopyWithImpl(this._self, this._then);

  final PhotoCover _self;
  final $Res Function(PhotoCover) _then;

/// Create a copy of Cover
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? photoPath = freezed,}) {
  return _then(PhotoCover(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DerivedFrom {

 String get recipeId; int get revision;
/// Create a copy of DerivedFrom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DerivedFromCopyWith<DerivedFrom> get copyWith => _$DerivedFromCopyWithImpl<DerivedFrom>(this as DerivedFrom, _$identity);

  /// Serializes this DerivedFrom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DerivedFrom;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DerivedFrom&&(identical(other.recipeId, _this.recipeId) || other.recipeId == _this.recipeId)&&(identical(other.revision, _this.revision) || other.revision == _this.revision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DerivedFrom;
  return Object.hash(runtimeType,_this.recipeId,_this.revision);
}

@override
String toString() {
  final _this = this as DerivedFrom;
  return 'DerivedFrom(recipeId: ${_this.recipeId}, revision: ${_this.revision})';
}


}

/// @nodoc
abstract mixin class $DerivedFromCopyWith<$Res>  {
  factory $DerivedFromCopyWith(DerivedFrom value, $Res Function(DerivedFrom) _then) = _$DerivedFromCopyWithImpl;
@useResult
$Res call({
 String recipeId, int revision
});




}
/// @nodoc
class _$DerivedFromCopyWithImpl<$Res>
    implements $DerivedFromCopyWith<$Res> {
  _$DerivedFromCopyWithImpl(this._self, this._then);

  final DerivedFrom _self;
  final $Res Function(DerivedFrom) _then;

/// Create a copy of DerivedFrom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeId = null,Object? revision = null,}) {
  return _then(DerivedFrom(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DerivedFrom].
extension DerivedFromPatterns on DerivedFrom {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DerivedFrom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DerivedFrom() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DerivedFrom value)  $default,){
final _that = this;
switch (_that) {
case _DerivedFrom():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DerivedFrom value)?  $default,){
final _that = this;
switch (_that) {
case _DerivedFrom() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipeId,  int revision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DerivedFrom() when $default != null:
return $default(_that.recipeId,_that.revision);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipeId,  int revision)  $default,) {final _that = this;
switch (_that) {
case _DerivedFrom():
return $default(_that.recipeId,_that.revision);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipeId,  int revision)?  $default,) {final _that = this;
switch (_that) {
case _DerivedFrom() when $default != null:
return $default(_that.recipeId,_that.revision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DerivedFrom implements DerivedFrom {
  const _DerivedFrom({required this.recipeId, required this.revision});
  factory _DerivedFrom.fromJson(Map<String, dynamic> json) => _$DerivedFromFromJson(json);

@override final  String recipeId;
@override final  int revision;

/// Create a copy of DerivedFrom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DerivedFromCopyWith<_DerivedFrom> get copyWith => __$DerivedFromCopyWithImpl<_DerivedFrom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DerivedFromToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DerivedFrom&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.revision, revision) || other.revision == revision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,recipeId,revision);
}

@override
String toString() {
    return 'DerivedFrom(recipeId: $recipeId, revision: $revision)';
}


}

/// @nodoc
abstract mixin class _$DerivedFromCopyWith<$Res> implements $DerivedFromCopyWith<$Res> {
  factory _$DerivedFromCopyWith(_DerivedFrom value, $Res Function(_DerivedFrom) _then) = __$DerivedFromCopyWithImpl;
@override @useResult
$Res call({
 String recipeId, int revision
});




}
/// @nodoc
class __$DerivedFromCopyWithImpl<$Res>
    implements _$DerivedFromCopyWith<$Res> {
  __$DerivedFromCopyWithImpl(this._self, this._then);

  final _DerivedFrom _self;
  final $Res Function(_DerivedFrom) _then;

/// Create a copy of DerivedFrom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? revision = null,}) {
  return _then(_DerivedFrom(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Source {

@JsonKey(unknownEnumValue: SourceKind.unknown) SourceKind get kind; String? get url; String? get attribution; DerivedFrom? get derivedFrom;
/// Create a copy of Source
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SourceCopyWith<Source> get copyWith => _$SourceCopyWithImpl<Source>(this as Source, _$identity);

  /// Serializes this Source to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Source;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Source&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.attribution, _this.attribution) || other.attribution == _this.attribution)&&(identical(other.derivedFrom, _this.derivedFrom) || other.derivedFrom == _this.derivedFrom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Source;
  return Object.hash(runtimeType,_this.kind,_this.url,_this.attribution,_this.derivedFrom);
}

@override
String toString() {
  final _this = this as Source;
  return 'Source(kind: ${_this.kind}, url: ${_this.url}, attribution: ${_this.attribution}, derivedFrom: ${_this.derivedFrom})';
}


}

/// @nodoc
abstract mixin class $SourceCopyWith<$Res>  {
  factory $SourceCopyWith(Source value, $Res Function(Source) _then) = _$SourceCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: SourceKind.unknown) SourceKind kind, String? url, String? attribution, DerivedFrom? derivedFrom
});


$DerivedFromCopyWith<$Res>? get derivedFrom;

}
/// @nodoc
class _$SourceCopyWithImpl<$Res>
    implements $SourceCopyWith<$Res> {
  _$SourceCopyWithImpl(this._self, this._then);

  final Source _self;
  final $Res Function(Source) _then;

/// Create a copy of Source
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? url = freezed,Object? attribution = freezed,Object? derivedFrom = freezed,}) {
  return _then(Source(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SourceKind,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,derivedFrom: freezed == derivedFrom ? _self.derivedFrom : derivedFrom // ignore: cast_nullable_to_non_nullable
as DerivedFrom?,
  ));
}
/// Create a copy of Source
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DerivedFromCopyWith<$Res>? get derivedFrom {
    if (_self.derivedFrom == null) {
    return null;
  }

  return $DerivedFromCopyWith<$Res>(_self.derivedFrom!, (value) {
    return _then(_self.copyWith(derivedFrom: value));
  });
}
}


/// Adds pattern-matching-related methods to [Source].
extension SourcePatterns on Source {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Source value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Source() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Source value)  $default,){
final _that = this;
switch (_that) {
case _Source():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Source value)?  $default,){
final _that = this;
switch (_that) {
case _Source() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: SourceKind.unknown)  SourceKind kind,  String? url,  String? attribution,  DerivedFrom? derivedFrom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Source() when $default != null:
return $default(_that.kind,_that.url,_that.attribution,_that.derivedFrom);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: SourceKind.unknown)  SourceKind kind,  String? url,  String? attribution,  DerivedFrom? derivedFrom)  $default,) {final _that = this;
switch (_that) {
case _Source():
return $default(_that.kind,_that.url,_that.attribution,_that.derivedFrom);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: SourceKind.unknown)  SourceKind kind,  String? url,  String? attribution,  DerivedFrom? derivedFrom)?  $default,) {final _that = this;
switch (_that) {
case _Source() when $default != null:
return $default(_that.kind,_that.url,_that.attribution,_that.derivedFrom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Source implements Source {
  const _Source({@JsonKey(unknownEnumValue: SourceKind.unknown) required this.kind, this.url, this.attribution, this.derivedFrom});
  factory _Source.fromJson(Map<String, dynamic> json) => _$SourceFromJson(json);

@override@JsonKey(unknownEnumValue: SourceKind.unknown) final  SourceKind kind;
@override final  String? url;
@override final  String? attribution;
@override final  DerivedFrom? derivedFrom;

/// Create a copy of Source
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SourceCopyWith<_Source> get copyWith => __$SourceCopyWithImpl<_Source>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SourceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Source&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.url, url) || other.url == url)&&(identical(other.attribution, attribution) || other.attribution == attribution)&&(identical(other.derivedFrom, derivedFrom) || other.derivedFrom == derivedFrom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,url,attribution,derivedFrom);
}

@override
String toString() {
    return 'Source(kind: $kind, url: $url, attribution: $attribution, derivedFrom: $derivedFrom)';
}


}

/// @nodoc
abstract mixin class _$SourceCopyWith<$Res> implements $SourceCopyWith<$Res> {
  factory _$SourceCopyWith(_Source value, $Res Function(_Source) _then) = __$SourceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: SourceKind.unknown) SourceKind kind, String? url, String? attribution, DerivedFrom? derivedFrom
});


@override $DerivedFromCopyWith<$Res>? get derivedFrom;

}
/// @nodoc
class __$SourceCopyWithImpl<$Res>
    implements _$SourceCopyWith<$Res> {
  __$SourceCopyWithImpl(this._self, this._then);

  final _Source _self;
  final $Res Function(_Source) _then;

/// Create a copy of Source
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? url = freezed,Object? attribution = freezed,Object? derivedFrom = freezed,}) {
  return _then(_Source(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SourceKind,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,derivedFrom: freezed == derivedFrom ? _self.derivedFrom : derivedFrom // ignore: cast_nullable_to_non_nullable
as DerivedFrom?,
  ));
}

/// Create a copy of Source
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DerivedFromCopyWith<$Res>? get derivedFrom {
    if (_self.derivedFrom == null) {
    return null;
  }

  return $DerivedFromCopyWith<$Res>(_self.derivedFrom!, (value) {
    return _then(_self.copyWith(derivedFrom: value));
  });
}
}


/// @nodoc
mixin _$Draft {

/// UUIDv7 minted by the Go service; saving keeps it as the Recipe id.
 String get id; int get schemaVersion; Source get source;@Rfc3339DateTimeConverter() DateTime get createdAt; String get title; String get description; double get servings; int get activeMinutes; int get passiveMinutes; List<Ingredient> get ingredients; List<Step> get steps; List<Cookware> get cookware; Macros get macros; String? get cuisine;@MealTypesConverter() List<MealType> get mealTypes; Cover get cover;
/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftCopyWith<Draft> get copyWith => _$DraftCopyWithImpl<Draft>(this as Draft, _$identity);

  /// Serializes this Draft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Draft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Draft&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.servings, _this.servings) || other.servings == _this.servings)&&(identical(other.activeMinutes, _this.activeMinutes) || other.activeMinutes == _this.activeMinutes)&&(identical(other.passiveMinutes, _this.passiveMinutes) || other.passiveMinutes == _this.passiveMinutes)&&const DeepCollectionEquality().equals(other.ingredients, _this.ingredients)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&const DeepCollectionEquality().equals(other.cookware, _this.cookware)&&(identical(other.macros, _this.macros) || other.macros == _this.macros)&&(identical(other.cuisine, _this.cuisine) || other.cuisine == _this.cuisine)&&const DeepCollectionEquality().equals(other.mealTypes, _this.mealTypes)&&(identical(other.cover, _this.cover) || other.cover == _this.cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Draft;
  return Object.hash(runtimeType,_this.id,_this.schemaVersion,_this.source,_this.createdAt,_this.title,_this.description,_this.servings,_this.activeMinutes,_this.passiveMinutes,const DeepCollectionEquality().hash(_this.ingredients),const DeepCollectionEquality().hash(_this.steps),const DeepCollectionEquality().hash(_this.cookware),_this.macros,_this.cuisine,const DeepCollectionEquality().hash(_this.mealTypes),_this.cover);
}

@override
String toString() {
  final _this = this as Draft;
  return 'Draft(id: ${_this.id}, schemaVersion: ${_this.schemaVersion}, source: ${_this.source}, createdAt: ${_this.createdAt}, title: ${_this.title}, description: ${_this.description}, servings: ${_this.servings}, activeMinutes: ${_this.activeMinutes}, passiveMinutes: ${_this.passiveMinutes}, ingredients: ${_this.ingredients}, steps: ${_this.steps}, cookware: ${_this.cookware}, macros: ${_this.macros}, cuisine: ${_this.cuisine}, mealTypes: ${_this.mealTypes}, cover: ${_this.cover})';
}


}

/// @nodoc
abstract mixin class $DraftCopyWith<$Res>  {
  factory $DraftCopyWith(Draft value, $Res Function(Draft) _then) = _$DraftCopyWithImpl;
@useResult
$Res call({
 String id, int schemaVersion, Source source,@Rfc3339DateTimeConverter() DateTime createdAt, String title, String description, double servings, int activeMinutes, int passiveMinutes, List<Ingredient> ingredients, List<Step> steps, List<Cookware> cookware, Macros macros, String? cuisine,@MealTypesConverter() List<MealType> mealTypes, Cover cover
});


$SourceCopyWith<$Res> get source;$MacrosCopyWith<$Res> get macros;$CoverCopyWith<$Res> get cover;

}
/// @nodoc
class _$DraftCopyWithImpl<$Res>
    implements $DraftCopyWith<$Res> {
  _$DraftCopyWithImpl(this._self, this._then);

  final Draft _self;
  final $Res Function(Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? schemaVersion = null,Object? source = null,Object? createdAt = null,Object? title = null,Object? description = null,Object? servings = null,Object? activeMinutes = null,Object? passiveMinutes = null,Object? ingredients = null,Object? steps = null,Object? cookware = null,Object? macros = null,Object? cuisine = freezed,Object? mealTypes = null,Object? cover = null,}) {
  return _then(Draft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as double,activeMinutes: null == activeMinutes ? _self.activeMinutes : activeMinutes // ignore: cast_nullable_to_non_nullable
as int,passiveMinutes: null == passiveMinutes ? _self.passiveMinutes : passiveMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<Ingredient>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<Step>,cookware: null == cookware ? _self.cookware : cookware // ignore: cast_nullable_to_non_nullable
as List<Cookware>,macros: null == macros ? _self.macros : macros // ignore: cast_nullable_to_non_nullable
as Macros,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,mealTypes: null == mealTypes ? _self.mealTypes : mealTypes // ignore: cast_nullable_to_non_nullable
as List<MealType>,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as Cover,
  ));
}
/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SourceCopyWith<$Res> get source {
  
  return $SourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MacrosCopyWith<$Res> get macros {
  
  return $MacrosCopyWith<$Res>(_self.macros, (value) {
    return _then(_self.copyWith(macros: value));
  });
}/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoverCopyWith<$Res> get cover {
  
  return $CoverCopyWith<$Res>(_self.cover, (value) {
    return _then(_self.copyWith(cover: value));
  });
}
}


/// Adds pattern-matching-related methods to [Draft].
extension DraftPatterns on Draft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Draft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Draft value)  $default,){
final _that = this;
switch (_that) {
case _Draft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Draft value)?  $default,){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int schemaVersion,  Source source, @Rfc3339DateTimeConverter()  DateTime createdAt,  String title,  String description,  double servings,  int activeMinutes,  int passiveMinutes,  List<Ingredient> ingredients,  List<Step> steps,  List<Cookware> cookware,  Macros macros,  String? cuisine, @MealTypesConverter()  List<MealType> mealTypes,  Cover cover)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.id,_that.schemaVersion,_that.source,_that.createdAt,_that.title,_that.description,_that.servings,_that.activeMinutes,_that.passiveMinutes,_that.ingredients,_that.steps,_that.cookware,_that.macros,_that.cuisine,_that.mealTypes,_that.cover);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int schemaVersion,  Source source, @Rfc3339DateTimeConverter()  DateTime createdAt,  String title,  String description,  double servings,  int activeMinutes,  int passiveMinutes,  List<Ingredient> ingredients,  List<Step> steps,  List<Cookware> cookware,  Macros macros,  String? cuisine, @MealTypesConverter()  List<MealType> mealTypes,  Cover cover)  $default,) {final _that = this;
switch (_that) {
case _Draft():
return $default(_that.id,_that.schemaVersion,_that.source,_that.createdAt,_that.title,_that.description,_that.servings,_that.activeMinutes,_that.passiveMinutes,_that.ingredients,_that.steps,_that.cookware,_that.macros,_that.cuisine,_that.mealTypes,_that.cover);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int schemaVersion,  Source source, @Rfc3339DateTimeConverter()  DateTime createdAt,  String title,  String description,  double servings,  int activeMinutes,  int passiveMinutes,  List<Ingredient> ingredients,  List<Step> steps,  List<Cookware> cookware,  Macros macros,  String? cuisine, @MealTypesConverter()  List<MealType> mealTypes,  Cover cover)?  $default,) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.id,_that.schemaVersion,_that.source,_that.createdAt,_that.title,_that.description,_that.servings,_that.activeMinutes,_that.passiveMinutes,_that.ingredients,_that.steps,_that.cookware,_that.macros,_that.cuisine,_that.mealTypes,_that.cover);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Draft implements Draft {
  const _Draft({required this.id, required this.schemaVersion, required this.source, @Rfc3339DateTimeConverter() required this.createdAt, required this.title, required this.description, required this.servings, required this.activeMinutes, required this.passiveMinutes, required  List<Ingredient> ingredients, required  List<Step> steps,  List<Cookware> cookware = const [], required this.macros, this.cuisine, @MealTypesConverter()  List<MealType> mealTypes = const [], required this.cover}): _ingredients = ingredients,_steps = steps,_cookware = cookware,_mealTypes = mealTypes;
  factory _Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);

/// UUIDv7 minted by the Go service; saving keeps it as the Recipe id.
@override final  String id;
@override final  int schemaVersion;
@override final  Source source;
@override@Rfc3339DateTimeConverter() final  DateTime createdAt;
@override final  String title;
@override final  String description;
@override final  double servings;
@override final  int activeMinutes;
@override final  int passiveMinutes;
 final  List<Ingredient> _ingredients;
@override List<Ingredient> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

 final  List<Step> _steps;
@override List<Step> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  List<Cookware> _cookware;
@override@JsonKey() List<Cookware> get cookware {
  if (_cookware is EqualUnmodifiableListView) return _cookware;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cookware);
}

@override final  Macros macros;
@override final  String? cuisine;
 final  List<MealType> _mealTypes;
@override@JsonKey()@MealTypesConverter() List<MealType> get mealTypes {
  if (_mealTypes is EqualUnmodifiableListView) return _mealTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mealTypes);
}

@override final  Cover cover;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftCopyWith<_Draft> get copyWith => __$DraftCopyWithImpl<_Draft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Draft&&(identical(other.id, id) || other.id == id)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.activeMinutes, activeMinutes) || other.activeMinutes == activeMinutes)&&(identical(other.passiveMinutes, passiveMinutes) || other.passiveMinutes == passiveMinutes)&&const DeepCollectionEquality().equals(other.ingredients, _ingredients)&&const DeepCollectionEquality().equals(other.steps, _steps)&&const DeepCollectionEquality().equals(other.cookware, _cookware)&&(identical(other.macros, macros) || other.macros == macros)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&const DeepCollectionEquality().equals(other.mealTypes, _mealTypes)&&(identical(other.cover, cover) || other.cover == cover));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,schemaVersion,source,createdAt,title,description,servings,activeMinutes,passiveMinutes,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_cookware),macros,cuisine,const DeepCollectionEquality().hash(_mealTypes),cover);
}

@override
String toString() {
    return 'Draft(id: $id, schemaVersion: $schemaVersion, source: $source, createdAt: $createdAt, title: $title, description: $description, servings: $servings, activeMinutes: $activeMinutes, passiveMinutes: $passiveMinutes, ingredients: $ingredients, steps: $steps, cookware: $cookware, macros: $macros, cuisine: $cuisine, mealTypes: $mealTypes, cover: $cover)';
}


}

/// @nodoc
abstract mixin class _$DraftCopyWith<$Res> implements $DraftCopyWith<$Res> {
  factory _$DraftCopyWith(_Draft value, $Res Function(_Draft) _then) = __$DraftCopyWithImpl;
@override @useResult
$Res call({
 String id, int schemaVersion, Source source,@Rfc3339DateTimeConverter() DateTime createdAt, String title, String description, double servings, int activeMinutes, int passiveMinutes, List<Ingredient> ingredients, List<Step> steps, List<Cookware> cookware, Macros macros, String? cuisine,@MealTypesConverter() List<MealType> mealTypes, Cover cover
});


@override $SourceCopyWith<$Res> get source;@override $MacrosCopyWith<$Res> get macros;@override $CoverCopyWith<$Res> get cover;

}
/// @nodoc
class __$DraftCopyWithImpl<$Res>
    implements _$DraftCopyWith<$Res> {
  __$DraftCopyWithImpl(this._self, this._then);

  final _Draft _self;
  final $Res Function(_Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? schemaVersion = null,Object? source = null,Object? createdAt = null,Object? title = null,Object? description = null,Object? servings = null,Object? activeMinutes = null,Object? passiveMinutes = null,Object? ingredients = null,Object? steps = null,Object? cookware = null,Object? macros = null,Object? cuisine = freezed,Object? mealTypes = null,Object? cover = null,}) {
  return _then(_Draft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as double,activeMinutes: null == activeMinutes ? _self.activeMinutes : activeMinutes // ignore: cast_nullable_to_non_nullable
as int,passiveMinutes: null == passiveMinutes ? _self.passiveMinutes : passiveMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<Ingredient>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<Step>,cookware: null == cookware ? _self._cookware : cookware // ignore: cast_nullable_to_non_nullable
as List<Cookware>,macros: null == macros ? _self.macros : macros // ignore: cast_nullable_to_non_nullable
as Macros,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,mealTypes: null == mealTypes ? _self._mealTypes : mealTypes // ignore: cast_nullable_to_non_nullable
as List<MealType>,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as Cover,
  ));
}

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SourceCopyWith<$Res> get source {
  
  return $SourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MacrosCopyWith<$Res> get macros {
  
  return $MacrosCopyWith<$Res>(_self.macros, (value) {
    return _then(_self.copyWith(macros: value));
  });
}/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoverCopyWith<$Res> get cover {
  
  return $CoverCopyWith<$Res>(_self.cover, (value) {
    return _then(_self.copyWith(cover: value));
  });
}
}


/// @nodoc
mixin _$Rating {

 int get stars; String? get note;@Rfc3339DateTimeConverter() DateTime get ratedAt; int get recipeRevision;
/// Create a copy of Rating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RatingCopyWith<Rating> get copyWith => _$RatingCopyWithImpl<Rating>(this as Rating, _$identity);

  /// Serializes this Rating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Rating;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rating&&(identical(other.stars, _this.stars) || other.stars == _this.stars)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.ratedAt, _this.ratedAt) || other.ratedAt == _this.ratedAt)&&(identical(other.recipeRevision, _this.recipeRevision) || other.recipeRevision == _this.recipeRevision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Rating;
  return Object.hash(runtimeType,_this.stars,_this.note,_this.ratedAt,_this.recipeRevision);
}

@override
String toString() {
  final _this = this as Rating;
  return 'Rating(stars: ${_this.stars}, note: ${_this.note}, ratedAt: ${_this.ratedAt}, recipeRevision: ${_this.recipeRevision})';
}


}

/// @nodoc
abstract mixin class $RatingCopyWith<$Res>  {
  factory $RatingCopyWith(Rating value, $Res Function(Rating) _then) = _$RatingCopyWithImpl;
@useResult
$Res call({
 int stars, String? note,@Rfc3339DateTimeConverter() DateTime ratedAt, int recipeRevision
});




}
/// @nodoc
class _$RatingCopyWithImpl<$Res>
    implements $RatingCopyWith<$Res> {
  _$RatingCopyWithImpl(this._self, this._then);

  final Rating _self;
  final $Res Function(Rating) _then;

/// Create a copy of Rating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stars = null,Object? note = freezed,Object? ratedAt = null,Object? recipeRevision = null,}) {
  return _then(Rating(
stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,ratedAt: null == ratedAt ? _self.ratedAt : ratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,recipeRevision: null == recipeRevision ? _self.recipeRevision : recipeRevision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Rating].
extension RatingPatterns on Rating {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rating() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rating value)  $default,){
final _that = this;
switch (_that) {
case _Rating():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rating value)?  $default,){
final _that = this;
switch (_that) {
case _Rating() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stars,  String? note, @Rfc3339DateTimeConverter()  DateTime ratedAt,  int recipeRevision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rating() when $default != null:
return $default(_that.stars,_that.note,_that.ratedAt,_that.recipeRevision);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stars,  String? note, @Rfc3339DateTimeConverter()  DateTime ratedAt,  int recipeRevision)  $default,) {final _that = this;
switch (_that) {
case _Rating():
return $default(_that.stars,_that.note,_that.ratedAt,_that.recipeRevision);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stars,  String? note, @Rfc3339DateTimeConverter()  DateTime ratedAt,  int recipeRevision)?  $default,) {final _that = this;
switch (_that) {
case _Rating() when $default != null:
return $default(_that.stars,_that.note,_that.ratedAt,_that.recipeRevision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Rating implements Rating {
  const _Rating({required this.stars, this.note, @Rfc3339DateTimeConverter() required this.ratedAt, required this.recipeRevision});
  factory _Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);

@override final  int stars;
@override final  String? note;
@override@Rfc3339DateTimeConverter() final  DateTime ratedAt;
@override final  int recipeRevision;

/// Create a copy of Rating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RatingCopyWith<_Rating> get copyWith => __$RatingCopyWithImpl<_Rating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RatingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rating&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.note, note) || other.note == note)&&(identical(other.ratedAt, ratedAt) || other.ratedAt == ratedAt)&&(identical(other.recipeRevision, recipeRevision) || other.recipeRevision == recipeRevision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stars,note,ratedAt,recipeRevision);
}

@override
String toString() {
    return 'Rating(stars: $stars, note: $note, ratedAt: $ratedAt, recipeRevision: $recipeRevision)';
}


}

/// @nodoc
abstract mixin class _$RatingCopyWith<$Res> implements $RatingCopyWith<$Res> {
  factory _$RatingCopyWith(_Rating value, $Res Function(_Rating) _then) = __$RatingCopyWithImpl;
@override @useResult
$Res call({
 int stars, String? note,@Rfc3339DateTimeConverter() DateTime ratedAt, int recipeRevision
});




}
/// @nodoc
class __$RatingCopyWithImpl<$Res>
    implements _$RatingCopyWith<$Res> {
  __$RatingCopyWithImpl(this._self, this._then);

  final _Rating _self;
  final $Res Function(_Rating) _then;

/// Create a copy of Rating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stars = null,Object? note = freezed,Object? ratedAt = null,Object? recipeRevision = null,}) {
  return _then(_Rating(
stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,ratedAt: null == ratedAt ? _self.ratedAt : ratedAt // ignore: cast_nullable_to_non_nullable
as DateTime,recipeRevision: null == recipeRevision ? _self.recipeRevision : recipeRevision // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RecipePrivate {

 Rating? get rating; List<String> get collectionIds; int get cookCount;@Rfc3339DateTimeConverter() DateTime? get lastCookedAt;
/// Create a copy of RecipePrivate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipePrivateCopyWith<RecipePrivate> get copyWith => _$RecipePrivateCopyWithImpl<RecipePrivate>(this as RecipePrivate, _$identity);

  /// Serializes this RecipePrivate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecipePrivate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipePrivate&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&const DeepCollectionEquality().equals(other.collectionIds, _this.collectionIds)&&(identical(other.cookCount, _this.cookCount) || other.cookCount == _this.cookCount)&&(identical(other.lastCookedAt, _this.lastCookedAt) || other.lastCookedAt == _this.lastCookedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecipePrivate;
  return Object.hash(runtimeType,_this.rating,const DeepCollectionEquality().hash(_this.collectionIds),_this.cookCount,_this.lastCookedAt);
}

@override
String toString() {
  final _this = this as RecipePrivate;
  return 'RecipePrivate(rating: ${_this.rating}, collectionIds: ${_this.collectionIds}, cookCount: ${_this.cookCount}, lastCookedAt: ${_this.lastCookedAt})';
}


}

/// @nodoc
abstract mixin class $RecipePrivateCopyWith<$Res>  {
  factory $RecipePrivateCopyWith(RecipePrivate value, $Res Function(RecipePrivate) _then) = _$RecipePrivateCopyWithImpl;
@useResult
$Res call({
 Rating? rating, List<String> collectionIds, int cookCount,@Rfc3339DateTimeConverter() DateTime? lastCookedAt
});


$RatingCopyWith<$Res>? get rating;

}
/// @nodoc
class _$RecipePrivateCopyWithImpl<$Res>
    implements $RecipePrivateCopyWith<$Res> {
  _$RecipePrivateCopyWithImpl(this._self, this._then);

  final RecipePrivate _self;
  final $Res Function(RecipePrivate) _then;

/// Create a copy of RecipePrivate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rating = freezed,Object? collectionIds = null,Object? cookCount = null,Object? lastCookedAt = freezed,}) {
  return _then(RecipePrivate(
rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating?,collectionIds: null == collectionIds ? _self.collectionIds : collectionIds // ignore: cast_nullable_to_non_nullable
as List<String>,cookCount: null == cookCount ? _self.cookCount : cookCount // ignore: cast_nullable_to_non_nullable
as int,lastCookedAt: freezed == lastCookedAt ? _self.lastCookedAt : lastCookedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of RecipePrivate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $RatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecipePrivate].
extension RecipePrivatePatterns on RecipePrivate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipePrivate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipePrivate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipePrivate value)  $default,){
final _that = this;
switch (_that) {
case _RecipePrivate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipePrivate value)?  $default,){
final _that = this;
switch (_that) {
case _RecipePrivate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Rating? rating,  List<String> collectionIds,  int cookCount, @Rfc3339DateTimeConverter()  DateTime? lastCookedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipePrivate() when $default != null:
return $default(_that.rating,_that.collectionIds,_that.cookCount,_that.lastCookedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Rating? rating,  List<String> collectionIds,  int cookCount, @Rfc3339DateTimeConverter()  DateTime? lastCookedAt)  $default,) {final _that = this;
switch (_that) {
case _RecipePrivate():
return $default(_that.rating,_that.collectionIds,_that.cookCount,_that.lastCookedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Rating? rating,  List<String> collectionIds,  int cookCount, @Rfc3339DateTimeConverter()  DateTime? lastCookedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecipePrivate() when $default != null:
return $default(_that.rating,_that.collectionIds,_that.cookCount,_that.lastCookedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipePrivate implements RecipePrivate {
  const _RecipePrivate({this.rating,  List<String> collectionIds = const [], this.cookCount = 0, @Rfc3339DateTimeConverter() this.lastCookedAt}): _collectionIds = collectionIds;
  factory _RecipePrivate.fromJson(Map<String, dynamic> json) => _$RecipePrivateFromJson(json);

@override final  Rating? rating;
 final  List<String> _collectionIds;
@override@JsonKey() List<String> get collectionIds {
  if (_collectionIds is EqualUnmodifiableListView) return _collectionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collectionIds);
}

@override@JsonKey() final  int cookCount;
@override@Rfc3339DateTimeConverter() final  DateTime? lastCookedAt;

/// Create a copy of RecipePrivate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipePrivateCopyWith<_RecipePrivate> get copyWith => __$RecipePrivateCopyWithImpl<_RecipePrivate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipePrivateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipePrivate&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.collectionIds, _collectionIds)&&(identical(other.cookCount, cookCount) || other.cookCount == cookCount)&&(identical(other.lastCookedAt, lastCookedAt) || other.lastCookedAt == lastCookedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rating,const DeepCollectionEquality().hash(_collectionIds),cookCount,lastCookedAt);
}

@override
String toString() {
    return 'RecipePrivate(rating: $rating, collectionIds: $collectionIds, cookCount: $cookCount, lastCookedAt: $lastCookedAt)';
}


}

/// @nodoc
abstract mixin class _$RecipePrivateCopyWith<$Res> implements $RecipePrivateCopyWith<$Res> {
  factory _$RecipePrivateCopyWith(_RecipePrivate value, $Res Function(_RecipePrivate) _then) = __$RecipePrivateCopyWithImpl;
@override @useResult
$Res call({
 Rating? rating, List<String> collectionIds, int cookCount,@Rfc3339DateTimeConverter() DateTime? lastCookedAt
});


@override $RatingCopyWith<$Res>? get rating;

}
/// @nodoc
class __$RecipePrivateCopyWithImpl<$Res>
    implements _$RecipePrivateCopyWith<$Res> {
  __$RecipePrivateCopyWithImpl(this._self, this._then);

  final _RecipePrivate _self;
  final $Res Function(_RecipePrivate) _then;

/// Create a copy of RecipePrivate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rating = freezed,Object? collectionIds = null,Object? cookCount = null,Object? lastCookedAt = freezed,}) {
  return _then(_RecipePrivate(
rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as Rating?,collectionIds: null == collectionIds ? _self._collectionIds : collectionIds // ignore: cast_nullable_to_non_nullable
as List<String>,cookCount: null == cookCount ? _self.cookCount : cookCount // ignore: cast_nullable_to_non_nullable
as int,lastCookedAt: freezed == lastCookedAt ? _self.lastCookedAt : lastCookedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of RecipePrivate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $RatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// @nodoc
mixin _$Recipe {

 String get id; int get schemaVersion; Source get source;@Rfc3339DateTimeConverter() DateTime get createdAt; String get title; String get description; double get servings; int get activeMinutes; int get passiveMinutes; List<Ingredient> get ingredients; List<Step> get steps; List<Cookware> get cookware; Macros get macros; String? get cuisine;@MealTypesConverter() List<MealType> get mealTypes; Cover get cover; String get ownerUid; int get revision;@Rfc3339DateTimeConverter() DateTime get savedAt;@Rfc3339DateTimeConverter() DateTime get updatedAt; RecipePrivate? get private;
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeCopyWith<Recipe> get copyWith => _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Recipe;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recipe&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.servings, _this.servings) || other.servings == _this.servings)&&(identical(other.activeMinutes, _this.activeMinutes) || other.activeMinutes == _this.activeMinutes)&&(identical(other.passiveMinutes, _this.passiveMinutes) || other.passiveMinutes == _this.passiveMinutes)&&const DeepCollectionEquality().equals(other.ingredients, _this.ingredients)&&const DeepCollectionEquality().equals(other.steps, _this.steps)&&const DeepCollectionEquality().equals(other.cookware, _this.cookware)&&(identical(other.macros, _this.macros) || other.macros == _this.macros)&&(identical(other.cuisine, _this.cuisine) || other.cuisine == _this.cuisine)&&const DeepCollectionEquality().equals(other.mealTypes, _this.mealTypes)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.ownerUid, _this.ownerUid) || other.ownerUid == _this.ownerUid)&&(identical(other.revision, _this.revision) || other.revision == _this.revision)&&(identical(other.savedAt, _this.savedAt) || other.savedAt == _this.savedAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.private, _this.private) || other.private == _this.private));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Recipe;
  return Object.hashAll([runtimeType,_this.id,_this.schemaVersion,_this.source,_this.createdAt,_this.title,_this.description,_this.servings,_this.activeMinutes,_this.passiveMinutes,const DeepCollectionEquality().hash(_this.ingredients),const DeepCollectionEquality().hash(_this.steps),const DeepCollectionEquality().hash(_this.cookware),_this.macros,_this.cuisine,const DeepCollectionEquality().hash(_this.mealTypes),_this.cover,_this.ownerUid,_this.revision,_this.savedAt,_this.updatedAt,_this.private]);
}

@override
String toString() {
  final _this = this as Recipe;
  return 'Recipe(id: ${_this.id}, schemaVersion: ${_this.schemaVersion}, source: ${_this.source}, createdAt: ${_this.createdAt}, title: ${_this.title}, description: ${_this.description}, servings: ${_this.servings}, activeMinutes: ${_this.activeMinutes}, passiveMinutes: ${_this.passiveMinutes}, ingredients: ${_this.ingredients}, steps: ${_this.steps}, cookware: ${_this.cookware}, macros: ${_this.macros}, cuisine: ${_this.cuisine}, mealTypes: ${_this.mealTypes}, cover: ${_this.cover}, ownerUid: ${_this.ownerUid}, revision: ${_this.revision}, savedAt: ${_this.savedAt}, updatedAt: ${_this.updatedAt}, private: ${_this.private})';
}


}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res>  {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) = _$RecipeCopyWithImpl;
@useResult
$Res call({
 String id, int schemaVersion, Source source,@Rfc3339DateTimeConverter() DateTime createdAt, String title, String description, double servings, int activeMinutes, int passiveMinutes, List<Ingredient> ingredients, List<Step> steps, List<Cookware> cookware, Macros macros, String? cuisine,@MealTypesConverter() List<MealType> mealTypes, Cover cover, String ownerUid, int revision,@Rfc3339DateTimeConverter() DateTime savedAt,@Rfc3339DateTimeConverter() DateTime updatedAt, RecipePrivate? private
});


$SourceCopyWith<$Res> get source;$MacrosCopyWith<$Res> get macros;$CoverCopyWith<$Res> get cover;$RecipePrivateCopyWith<$Res>? get private;

}
/// @nodoc
class _$RecipeCopyWithImpl<$Res>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? schemaVersion = null,Object? source = null,Object? createdAt = null,Object? title = null,Object? description = null,Object? servings = null,Object? activeMinutes = null,Object? passiveMinutes = null,Object? ingredients = null,Object? steps = null,Object? cookware = null,Object? macros = null,Object? cuisine = freezed,Object? mealTypes = null,Object? cover = null,Object? ownerUid = null,Object? revision = null,Object? savedAt = null,Object? updatedAt = null,Object? private = freezed,}) {
  return _then(Recipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as double,activeMinutes: null == activeMinutes ? _self.activeMinutes : activeMinutes // ignore: cast_nullable_to_non_nullable
as int,passiveMinutes: null == passiveMinutes ? _self.passiveMinutes : passiveMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<Ingredient>,steps: null == steps ? _self.steps : steps // ignore: cast_nullable_to_non_nullable
as List<Step>,cookware: null == cookware ? _self.cookware : cookware // ignore: cast_nullable_to_non_nullable
as List<Cookware>,macros: null == macros ? _self.macros : macros // ignore: cast_nullable_to_non_nullable
as Macros,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,mealTypes: null == mealTypes ? _self.mealTypes : mealTypes // ignore: cast_nullable_to_non_nullable
as List<MealType>,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as Cover,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as RecipePrivate?,
  ));
}
/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SourceCopyWith<$Res> get source {
  
  return $SourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MacrosCopyWith<$Res> get macros {
  
  return $MacrosCopyWith<$Res>(_self.macros, (value) {
    return _then(_self.copyWith(macros: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoverCopyWith<$Res> get cover {
  
  return $CoverCopyWith<$Res>(_self.cover, (value) {
    return _then(_self.copyWith(cover: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipePrivateCopyWith<$Res>? get private {
    if (_self.private == null) {
    return null;
  }

  return $RecipePrivateCopyWith<$Res>(_self.private!, (value) {
    return _then(_self.copyWith(private: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recipe].
extension RecipePatterns on Recipe {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recipe value)  $default,){
final _that = this;
switch (_that) {
case _Recipe():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recipe value)?  $default,){
final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int schemaVersion,  Source source, @Rfc3339DateTimeConverter()  DateTime createdAt,  String title,  String description,  double servings,  int activeMinutes,  int passiveMinutes,  List<Ingredient> ingredients,  List<Step> steps,  List<Cookware> cookware,  Macros macros,  String? cuisine, @MealTypesConverter()  List<MealType> mealTypes,  Cover cover,  String ownerUid,  int revision, @Rfc3339DateTimeConverter()  DateTime savedAt, @Rfc3339DateTimeConverter()  DateTime updatedAt,  RecipePrivate? private)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.schemaVersion,_that.source,_that.createdAt,_that.title,_that.description,_that.servings,_that.activeMinutes,_that.passiveMinutes,_that.ingredients,_that.steps,_that.cookware,_that.macros,_that.cuisine,_that.mealTypes,_that.cover,_that.ownerUid,_that.revision,_that.savedAt,_that.updatedAt,_that.private);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int schemaVersion,  Source source, @Rfc3339DateTimeConverter()  DateTime createdAt,  String title,  String description,  double servings,  int activeMinutes,  int passiveMinutes,  List<Ingredient> ingredients,  List<Step> steps,  List<Cookware> cookware,  Macros macros,  String? cuisine, @MealTypesConverter()  List<MealType> mealTypes,  Cover cover,  String ownerUid,  int revision, @Rfc3339DateTimeConverter()  DateTime savedAt, @Rfc3339DateTimeConverter()  DateTime updatedAt,  RecipePrivate? private)  $default,) {final _that = this;
switch (_that) {
case _Recipe():
return $default(_that.id,_that.schemaVersion,_that.source,_that.createdAt,_that.title,_that.description,_that.servings,_that.activeMinutes,_that.passiveMinutes,_that.ingredients,_that.steps,_that.cookware,_that.macros,_that.cuisine,_that.mealTypes,_that.cover,_that.ownerUid,_that.revision,_that.savedAt,_that.updatedAt,_that.private);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int schemaVersion,  Source source, @Rfc3339DateTimeConverter()  DateTime createdAt,  String title,  String description,  double servings,  int activeMinutes,  int passiveMinutes,  List<Ingredient> ingredients,  List<Step> steps,  List<Cookware> cookware,  Macros macros,  String? cuisine, @MealTypesConverter()  List<MealType> mealTypes,  Cover cover,  String ownerUid,  int revision, @Rfc3339DateTimeConverter()  DateTime savedAt, @Rfc3339DateTimeConverter()  DateTime updatedAt,  RecipePrivate? private)?  $default,) {final _that = this;
switch (_that) {
case _Recipe() when $default != null:
return $default(_that.id,_that.schemaVersion,_that.source,_that.createdAt,_that.title,_that.description,_that.servings,_that.activeMinutes,_that.passiveMinutes,_that.ingredients,_that.steps,_that.cookware,_that.macros,_that.cuisine,_that.mealTypes,_that.cover,_that.ownerUid,_that.revision,_that.savedAt,_that.updatedAt,_that.private);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Recipe extends Recipe {
  const _Recipe({required this.id, required this.schemaVersion, required this.source, @Rfc3339DateTimeConverter() required this.createdAt, required this.title, required this.description, required this.servings, required this.activeMinutes, required this.passiveMinutes, required  List<Ingredient> ingredients, required  List<Step> steps,  List<Cookware> cookware = const [], required this.macros, this.cuisine, @MealTypesConverter()  List<MealType> mealTypes = const [], required this.cover, required this.ownerUid, required this.revision, @Rfc3339DateTimeConverter() required this.savedAt, @Rfc3339DateTimeConverter() required this.updatedAt, this.private}): _ingredients = ingredients,_steps = steps,_cookware = cookware,_mealTypes = mealTypes,super._();
  factory _Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);

@override final  String id;
@override final  int schemaVersion;
@override final  Source source;
@override@Rfc3339DateTimeConverter() final  DateTime createdAt;
@override final  String title;
@override final  String description;
@override final  double servings;
@override final  int activeMinutes;
@override final  int passiveMinutes;
 final  List<Ingredient> _ingredients;
@override List<Ingredient> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}

 final  List<Step> _steps;
@override List<Step> get steps {
  if (_steps is EqualUnmodifiableListView) return _steps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_steps);
}

 final  List<Cookware> _cookware;
@override@JsonKey() List<Cookware> get cookware {
  if (_cookware is EqualUnmodifiableListView) return _cookware;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cookware);
}

@override final  Macros macros;
@override final  String? cuisine;
 final  List<MealType> _mealTypes;
@override@JsonKey()@MealTypesConverter() List<MealType> get mealTypes {
  if (_mealTypes is EqualUnmodifiableListView) return _mealTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mealTypes);
}

@override final  Cover cover;
@override final  String ownerUid;
@override final  int revision;
@override@Rfc3339DateTimeConverter() final  DateTime savedAt;
@override@Rfc3339DateTimeConverter() final  DateTime updatedAt;
@override final  RecipePrivate? private;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeCopyWith<_Recipe> get copyWith => __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recipe&&(identical(other.id, id) || other.id == id)&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.servings, servings) || other.servings == servings)&&(identical(other.activeMinutes, activeMinutes) || other.activeMinutes == activeMinutes)&&(identical(other.passiveMinutes, passiveMinutes) || other.passiveMinutes == passiveMinutes)&&const DeepCollectionEquality().equals(other.ingredients, _ingredients)&&const DeepCollectionEquality().equals(other.steps, _steps)&&const DeepCollectionEquality().equals(other.cookware, _cookware)&&(identical(other.macros, macros) || other.macros == macros)&&(identical(other.cuisine, cuisine) || other.cuisine == cuisine)&&const DeepCollectionEquality().equals(other.mealTypes, _mealTypes)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.revision, revision) || other.revision == revision)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.private, private) || other.private == private));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,schemaVersion,source,createdAt,title,description,servings,activeMinutes,passiveMinutes,const DeepCollectionEquality().hash(_ingredients),const DeepCollectionEquality().hash(_steps),const DeepCollectionEquality().hash(_cookware),macros,cuisine,const DeepCollectionEquality().hash(_mealTypes),cover,ownerUid,revision,savedAt,updatedAt,private]);
}

@override
String toString() {
    return 'Recipe(id: $id, schemaVersion: $schemaVersion, source: $source, createdAt: $createdAt, title: $title, description: $description, servings: $servings, activeMinutes: $activeMinutes, passiveMinutes: $passiveMinutes, ingredients: $ingredients, steps: $steps, cookware: $cookware, macros: $macros, cuisine: $cuisine, mealTypes: $mealTypes, cover: $cover, ownerUid: $ownerUid, revision: $revision, savedAt: $savedAt, updatedAt: $updatedAt, private: $private)';
}


}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) = __$RecipeCopyWithImpl;
@override @useResult
$Res call({
 String id, int schemaVersion, Source source,@Rfc3339DateTimeConverter() DateTime createdAt, String title, String description, double servings, int activeMinutes, int passiveMinutes, List<Ingredient> ingredients, List<Step> steps, List<Cookware> cookware, Macros macros, String? cuisine,@MealTypesConverter() List<MealType> mealTypes, Cover cover, String ownerUid, int revision,@Rfc3339DateTimeConverter() DateTime savedAt,@Rfc3339DateTimeConverter() DateTime updatedAt, RecipePrivate? private
});


@override $SourceCopyWith<$Res> get source;@override $MacrosCopyWith<$Res> get macros;@override $CoverCopyWith<$Res> get cover;@override $RecipePrivateCopyWith<$Res>? get private;

}
/// @nodoc
class __$RecipeCopyWithImpl<$Res>
    implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? schemaVersion = null,Object? source = null,Object? createdAt = null,Object? title = null,Object? description = null,Object? servings = null,Object? activeMinutes = null,Object? passiveMinutes = null,Object? ingredients = null,Object? steps = null,Object? cookware = null,Object? macros = null,Object? cuisine = freezed,Object? mealTypes = null,Object? cover = null,Object? ownerUid = null,Object? revision = null,Object? savedAt = null,Object? updatedAt = null,Object? private = freezed,}) {
  return _then(_Recipe(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as Source,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,servings: null == servings ? _self.servings : servings // ignore: cast_nullable_to_non_nullable
as double,activeMinutes: null == activeMinutes ? _self.activeMinutes : activeMinutes // ignore: cast_nullable_to_non_nullable
as int,passiveMinutes: null == passiveMinutes ? _self.passiveMinutes : passiveMinutes // ignore: cast_nullable_to_non_nullable
as int,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<Ingredient>,steps: null == steps ? _self._steps : steps // ignore: cast_nullable_to_non_nullable
as List<Step>,cookware: null == cookware ? _self._cookware : cookware // ignore: cast_nullable_to_non_nullable
as List<Cookware>,macros: null == macros ? _self.macros : macros // ignore: cast_nullable_to_non_nullable
as Macros,cuisine: freezed == cuisine ? _self.cuisine : cuisine // ignore: cast_nullable_to_non_nullable
as String?,mealTypes: null == mealTypes ? _self._mealTypes : mealTypes // ignore: cast_nullable_to_non_nullable
as List<MealType>,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as Cover,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,revision: null == revision ? _self.revision : revision // ignore: cast_nullable_to_non_nullable
as int,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,private: freezed == private ? _self.private : private // ignore: cast_nullable_to_non_nullable
as RecipePrivate?,
  ));
}

/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SourceCopyWith<$Res> get source {
  
  return $SourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MacrosCopyWith<$Res> get macros {
  
  return $MacrosCopyWith<$Res>(_self.macros, (value) {
    return _then(_self.copyWith(macros: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoverCopyWith<$Res> get cover {
  
  return $CoverCopyWith<$Res>(_self.cover, (value) {
    return _then(_self.copyWith(cover: value));
  });
}/// Create a copy of Recipe
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecipePrivateCopyWith<$Res>? get private {
    if (_self.private == null) {
    return null;
  }

  return $RecipePrivateCopyWith<$Res>(_self.private!, (value) {
    return _then(_self.copyWith(private: value));
  });
}
}

// dart format on
