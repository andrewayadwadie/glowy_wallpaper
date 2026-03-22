// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionStatusModel {

@JsonKey(name: 'is_premium') bool get isPremium;
/// Create a copy of SubscriptionStatusModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStatusModelCopyWith<SubscriptionStatusModel> get copyWith => _$SubscriptionStatusModelCopyWithImpl<SubscriptionStatusModel>(this as SubscriptionStatusModel, _$identity);

  /// Serializes this SubscriptionStatusModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStatusModel&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPremium);

@override
String toString() {
  return 'SubscriptionStatusModel(isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStatusModelCopyWith<$Res>  {
  factory $SubscriptionStatusModelCopyWith(SubscriptionStatusModel value, $Res Function(SubscriptionStatusModel) _then) = _$SubscriptionStatusModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'is_premium') bool isPremium
});




}
/// @nodoc
class _$SubscriptionStatusModelCopyWithImpl<$Res>
    implements $SubscriptionStatusModelCopyWith<$Res> {
  _$SubscriptionStatusModelCopyWithImpl(this._self, this._then);

  final SubscriptionStatusModel _self;
  final $Res Function(SubscriptionStatusModel) _then;

/// Create a copy of SubscriptionStatusModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPremium = null,}) {
  return _then(_self.copyWith(
isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionStatusModel].
extension SubscriptionStatusModelPatterns on SubscriptionStatusModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionStatusModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionStatusModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionStatusModel value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatusModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionStatusModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatusModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_premium')  bool isPremium)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionStatusModel() when $default != null:
return $default(_that.isPremium);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'is_premium')  bool isPremium)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatusModel():
return $default(_that.isPremium);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'is_premium')  bool isPremium)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatusModel() when $default != null:
return $default(_that.isPremium);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionStatusModel implements SubscriptionStatusModel {
  const _SubscriptionStatusModel({@JsonKey(name: 'is_premium') required this.isPremium});
  factory _SubscriptionStatusModel.fromJson(Map<String, dynamic> json) => _$SubscriptionStatusModelFromJson(json);

@override@JsonKey(name: 'is_premium') final  bool isPremium;

/// Create a copy of SubscriptionStatusModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStatusModelCopyWith<_SubscriptionStatusModel> get copyWith => __$SubscriptionStatusModelCopyWithImpl<_SubscriptionStatusModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionStatusModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionStatusModel&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPremium);

@override
String toString() {
  return 'SubscriptionStatusModel(isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStatusModelCopyWith<$Res> implements $SubscriptionStatusModelCopyWith<$Res> {
  factory _$SubscriptionStatusModelCopyWith(_SubscriptionStatusModel value, $Res Function(_SubscriptionStatusModel) _then) = __$SubscriptionStatusModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'is_premium') bool isPremium
});




}
/// @nodoc
class __$SubscriptionStatusModelCopyWithImpl<$Res>
    implements _$SubscriptionStatusModelCopyWith<$Res> {
  __$SubscriptionStatusModelCopyWithImpl(this._self, this._then);

  final _SubscriptionStatusModel _self;
  final $Res Function(_SubscriptionStatusModel) _then;

/// Create a copy of SubscriptionStatusModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPremium = null,}) {
  return _then(_SubscriptionStatusModel(
isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
