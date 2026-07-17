// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_cache_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionCacheModel {

@JsonKey(name: 'status') String get status;@JsonKey(name: 'product_id') String? get productId;@JsonKey(name: 'purchase_token') String? get purchaseToken;@JsonKey(name: 'verification_state') String get verificationState;@JsonKey(name: 'expiry_date') String? get expiryDate;@JsonKey(name: 'last_verified_at') String? get lastVerifiedAt;
/// Create a copy of SubscriptionCacheModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionCacheModelCopyWith<SubscriptionCacheModel> get copyWith => _$SubscriptionCacheModelCopyWithImpl<SubscriptionCacheModel>(this as SubscriptionCacheModel, _$identity);

  /// Serializes this SubscriptionCacheModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionCacheModel&&(identical(other.status, status) || other.status == status)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.purchaseToken, purchaseToken) || other.purchaseToken == purchaseToken)&&(identical(other.verificationState, verificationState) || other.verificationState == verificationState)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.lastVerifiedAt, lastVerifiedAt) || other.lastVerifiedAt == lastVerifiedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,productId,purchaseToken,verificationState,expiryDate,lastVerifiedAt);

@override
String toString() {
  return 'SubscriptionCacheModel(status: $status, productId: $productId, purchaseToken: $purchaseToken, verificationState: $verificationState, expiryDate: $expiryDate, lastVerifiedAt: $lastVerifiedAt)';
}


}

/// @nodoc
abstract mixin class $SubscriptionCacheModelCopyWith<$Res>  {
  factory $SubscriptionCacheModelCopyWith(SubscriptionCacheModel value, $Res Function(SubscriptionCacheModel) _then) = _$SubscriptionCacheModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status') String status,@JsonKey(name: 'product_id') String? productId,@JsonKey(name: 'purchase_token') String? purchaseToken,@JsonKey(name: 'verification_state') String verificationState,@JsonKey(name: 'expiry_date') String? expiryDate,@JsonKey(name: 'last_verified_at') String? lastVerifiedAt
});




}
/// @nodoc
class _$SubscriptionCacheModelCopyWithImpl<$Res>
    implements $SubscriptionCacheModelCopyWith<$Res> {
  _$SubscriptionCacheModelCopyWithImpl(this._self, this._then);

  final SubscriptionCacheModel _self;
  final $Res Function(SubscriptionCacheModel) _then;

/// Create a copy of SubscriptionCacheModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? productId = freezed,Object? purchaseToken = freezed,Object? verificationState = null,Object? expiryDate = freezed,Object? lastVerifiedAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,purchaseToken: freezed == purchaseToken ? _self.purchaseToken : purchaseToken // ignore: cast_nullable_to_non_nullable
as String?,verificationState: null == verificationState ? _self.verificationState : verificationState // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,lastVerifiedAt: freezed == lastVerifiedAt ? _self.lastVerifiedAt : lastVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionCacheModel].
extension SubscriptionCacheModelPatterns on SubscriptionCacheModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionCacheModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionCacheModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionCacheModel value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionCacheModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionCacheModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionCacheModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status')  String status, @JsonKey(name: 'product_id')  String? productId, @JsonKey(name: 'purchase_token')  String? purchaseToken, @JsonKey(name: 'verification_state')  String verificationState, @JsonKey(name: 'expiry_date')  String? expiryDate, @JsonKey(name: 'last_verified_at')  String? lastVerifiedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionCacheModel() when $default != null:
return $default(_that.status,_that.productId,_that.purchaseToken,_that.verificationState,_that.expiryDate,_that.lastVerifiedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status')  String status, @JsonKey(name: 'product_id')  String? productId, @JsonKey(name: 'purchase_token')  String? purchaseToken, @JsonKey(name: 'verification_state')  String verificationState, @JsonKey(name: 'expiry_date')  String? expiryDate, @JsonKey(name: 'last_verified_at')  String? lastVerifiedAt)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionCacheModel():
return $default(_that.status,_that.productId,_that.purchaseToken,_that.verificationState,_that.expiryDate,_that.lastVerifiedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status')  String status, @JsonKey(name: 'product_id')  String? productId, @JsonKey(name: 'purchase_token')  String? purchaseToken, @JsonKey(name: 'verification_state')  String verificationState, @JsonKey(name: 'expiry_date')  String? expiryDate, @JsonKey(name: 'last_verified_at')  String? lastVerifiedAt)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionCacheModel() when $default != null:
return $default(_that.status,_that.productId,_that.purchaseToken,_that.verificationState,_that.expiryDate,_that.lastVerifiedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionCacheModel extends SubscriptionCacheModel {
  const _SubscriptionCacheModel({@JsonKey(name: 'status') required this.status, @JsonKey(name: 'product_id') this.productId, @JsonKey(name: 'purchase_token') this.purchaseToken, @JsonKey(name: 'verification_state') required this.verificationState, @JsonKey(name: 'expiry_date') this.expiryDate, @JsonKey(name: 'last_verified_at') this.lastVerifiedAt}): super._();
  factory _SubscriptionCacheModel.fromJson(Map<String, dynamic> json) => _$SubscriptionCacheModelFromJson(json);

@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'product_id') final  String? productId;
@override@JsonKey(name: 'purchase_token') final  String? purchaseToken;
@override@JsonKey(name: 'verification_state') final  String verificationState;
@override@JsonKey(name: 'expiry_date') final  String? expiryDate;
@override@JsonKey(name: 'last_verified_at') final  String? lastVerifiedAt;

/// Create a copy of SubscriptionCacheModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionCacheModelCopyWith<_SubscriptionCacheModel> get copyWith => __$SubscriptionCacheModelCopyWithImpl<_SubscriptionCacheModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionCacheModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionCacheModel&&(identical(other.status, status) || other.status == status)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.purchaseToken, purchaseToken) || other.purchaseToken == purchaseToken)&&(identical(other.verificationState, verificationState) || other.verificationState == verificationState)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.lastVerifiedAt, lastVerifiedAt) || other.lastVerifiedAt == lastVerifiedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,productId,purchaseToken,verificationState,expiryDate,lastVerifiedAt);

@override
String toString() {
  return 'SubscriptionCacheModel(status: $status, productId: $productId, purchaseToken: $purchaseToken, verificationState: $verificationState, expiryDate: $expiryDate, lastVerifiedAt: $lastVerifiedAt)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionCacheModelCopyWith<$Res> implements $SubscriptionCacheModelCopyWith<$Res> {
  factory _$SubscriptionCacheModelCopyWith(_SubscriptionCacheModel value, $Res Function(_SubscriptionCacheModel) _then) = __$SubscriptionCacheModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status') String status,@JsonKey(name: 'product_id') String? productId,@JsonKey(name: 'purchase_token') String? purchaseToken,@JsonKey(name: 'verification_state') String verificationState,@JsonKey(name: 'expiry_date') String? expiryDate,@JsonKey(name: 'last_verified_at') String? lastVerifiedAt
});




}
/// @nodoc
class __$SubscriptionCacheModelCopyWithImpl<$Res>
    implements _$SubscriptionCacheModelCopyWith<$Res> {
  __$SubscriptionCacheModelCopyWithImpl(this._self, this._then);

  final _SubscriptionCacheModel _self;
  final $Res Function(_SubscriptionCacheModel) _then;

/// Create a copy of SubscriptionCacheModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? productId = freezed,Object? purchaseToken = freezed,Object? verificationState = null,Object? expiryDate = freezed,Object? lastVerifiedAt = freezed,}) {
  return _then(_SubscriptionCacheModel(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,purchaseToken: freezed == purchaseToken ? _self.purchaseToken : purchaseToken // ignore: cast_nullable_to_non_nullable
as String?,verificationState: null == verificationState ? _self.verificationState : verificationState // ignore: cast_nullable_to_non_nullable
as String,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,lastVerifiedAt: freezed == lastVerifiedAt ? _self.lastVerifiedAt : lastVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
