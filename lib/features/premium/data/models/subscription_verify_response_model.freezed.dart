// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_verify_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionVerifyResponseModel {

 bool get verified; String? get expiryDate; String? get productId;
/// Create a copy of SubscriptionVerifyResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionVerifyResponseModelCopyWith<SubscriptionVerifyResponseModel> get copyWith => _$SubscriptionVerifyResponseModelCopyWithImpl<SubscriptionVerifyResponseModel>(this as SubscriptionVerifyResponseModel, _$identity);

  /// Serializes this SubscriptionVerifyResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionVerifyResponseModel&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.productId, productId) || other.productId == productId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,verified,expiryDate,productId);

@override
String toString() {
  return 'SubscriptionVerifyResponseModel(verified: $verified, expiryDate: $expiryDate, productId: $productId)';
}


}

/// @nodoc
abstract mixin class $SubscriptionVerifyResponseModelCopyWith<$Res>  {
  factory $SubscriptionVerifyResponseModelCopyWith(SubscriptionVerifyResponseModel value, $Res Function(SubscriptionVerifyResponseModel) _then) = _$SubscriptionVerifyResponseModelCopyWithImpl;
@useResult
$Res call({
 bool verified, String? expiryDate, String? productId
});




}
/// @nodoc
class _$SubscriptionVerifyResponseModelCopyWithImpl<$Res>
    implements $SubscriptionVerifyResponseModelCopyWith<$Res> {
  _$SubscriptionVerifyResponseModelCopyWithImpl(this._self, this._then);

  final SubscriptionVerifyResponseModel _self;
  final $Res Function(SubscriptionVerifyResponseModel) _then;

/// Create a copy of SubscriptionVerifyResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? verified = null,Object? expiryDate = freezed,Object? productId = freezed,}) {
  return _then(_self.copyWith(
verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionVerifyResponseModel].
extension SubscriptionVerifyResponseModelPatterns on SubscriptionVerifyResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionVerifyResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionVerifyResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionVerifyResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionVerifyResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionVerifyResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionVerifyResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool verified,  String? expiryDate,  String? productId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionVerifyResponseModel() when $default != null:
return $default(_that.verified,_that.expiryDate,_that.productId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool verified,  String? expiryDate,  String? productId)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionVerifyResponseModel():
return $default(_that.verified,_that.expiryDate,_that.productId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool verified,  String? expiryDate,  String? productId)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionVerifyResponseModel() when $default != null:
return $default(_that.verified,_that.expiryDate,_that.productId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionVerifyResponseModel extends SubscriptionVerifyResponseModel {
  const _SubscriptionVerifyResponseModel({required this.verified, this.expiryDate, this.productId}): super._();
  factory _SubscriptionVerifyResponseModel.fromJson(Map<String, dynamic> json) => _$SubscriptionVerifyResponseModelFromJson(json);

@override final  bool verified;
@override final  String? expiryDate;
@override final  String? productId;

/// Create a copy of SubscriptionVerifyResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionVerifyResponseModelCopyWith<_SubscriptionVerifyResponseModel> get copyWith => __$SubscriptionVerifyResponseModelCopyWithImpl<_SubscriptionVerifyResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionVerifyResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionVerifyResponseModel&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.productId, productId) || other.productId == productId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,verified,expiryDate,productId);

@override
String toString() {
  return 'SubscriptionVerifyResponseModel(verified: $verified, expiryDate: $expiryDate, productId: $productId)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionVerifyResponseModelCopyWith<$Res> implements $SubscriptionVerifyResponseModelCopyWith<$Res> {
  factory _$SubscriptionVerifyResponseModelCopyWith(_SubscriptionVerifyResponseModel value, $Res Function(_SubscriptionVerifyResponseModel) _then) = __$SubscriptionVerifyResponseModelCopyWithImpl;
@override @useResult
$Res call({
 bool verified, String? expiryDate, String? productId
});




}
/// @nodoc
class __$SubscriptionVerifyResponseModelCopyWithImpl<$Res>
    implements _$SubscriptionVerifyResponseModelCopyWith<$Res> {
  __$SubscriptionVerifyResponseModelCopyWithImpl(this._self, this._then);

  final _SubscriptionVerifyResponseModel _self;
  final $Res Function(_SubscriptionVerifyResponseModel) _then;

/// Create a copy of SubscriptionVerifyResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? verified = null,Object? expiryDate = freezed,Object? productId = freezed,}) {
  return _then(_SubscriptionVerifyResponseModel(
verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
