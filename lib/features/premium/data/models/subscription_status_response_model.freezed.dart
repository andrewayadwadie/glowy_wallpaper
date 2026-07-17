// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionStatusResponseModel {

 bool get isActive; String? get expiryDate; String? get productId; String? get status;
/// Create a copy of SubscriptionStatusResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionStatusResponseModelCopyWith<SubscriptionStatusResponseModel> get copyWith => _$SubscriptionStatusResponseModelCopyWithImpl<SubscriptionStatusResponseModel>(this as SubscriptionStatusResponseModel, _$identity);

  /// Serializes this SubscriptionStatusResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionStatusResponseModel&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isActive,expiryDate,productId,status);

@override
String toString() {
  return 'SubscriptionStatusResponseModel(isActive: $isActive, expiryDate: $expiryDate, productId: $productId, status: $status)';
}


}

/// @nodoc
abstract mixin class $SubscriptionStatusResponseModelCopyWith<$Res>  {
  factory $SubscriptionStatusResponseModelCopyWith(SubscriptionStatusResponseModel value, $Res Function(SubscriptionStatusResponseModel) _then) = _$SubscriptionStatusResponseModelCopyWithImpl;
@useResult
$Res call({
 bool isActive, String? expiryDate, String? productId, String? status
});




}
/// @nodoc
class _$SubscriptionStatusResponseModelCopyWithImpl<$Res>
    implements $SubscriptionStatusResponseModelCopyWith<$Res> {
  _$SubscriptionStatusResponseModelCopyWithImpl(this._self, this._then);

  final SubscriptionStatusResponseModel _self;
  final $Res Function(SubscriptionStatusResponseModel) _then;

/// Create a copy of SubscriptionStatusResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isActive = null,Object? expiryDate = freezed,Object? productId = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionStatusResponseModel].
extension SubscriptionStatusResponseModelPatterns on SubscriptionStatusResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionStatusResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionStatusResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionStatusResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatusResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionStatusResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionStatusResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isActive,  String? expiryDate,  String? productId,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionStatusResponseModel() when $default != null:
return $default(_that.isActive,_that.expiryDate,_that.productId,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isActive,  String? expiryDate,  String? productId,  String? status)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatusResponseModel():
return $default(_that.isActive,_that.expiryDate,_that.productId,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isActive,  String? expiryDate,  String? productId,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionStatusResponseModel() when $default != null:
return $default(_that.isActive,_that.expiryDate,_that.productId,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionStatusResponseModel extends SubscriptionStatusResponseModel {
  const _SubscriptionStatusResponseModel({required this.isActive, this.expiryDate, this.productId, this.status}): super._();
  factory _SubscriptionStatusResponseModel.fromJson(Map<String, dynamic> json) => _$SubscriptionStatusResponseModelFromJson(json);

@override final  bool isActive;
@override final  String? expiryDate;
@override final  String? productId;
@override final  String? status;

/// Create a copy of SubscriptionStatusResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionStatusResponseModelCopyWith<_SubscriptionStatusResponseModel> get copyWith => __$SubscriptionStatusResponseModelCopyWithImpl<_SubscriptionStatusResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionStatusResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionStatusResponseModel&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isActive,expiryDate,productId,status);

@override
String toString() {
  return 'SubscriptionStatusResponseModel(isActive: $isActive, expiryDate: $expiryDate, productId: $productId, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionStatusResponseModelCopyWith<$Res> implements $SubscriptionStatusResponseModelCopyWith<$Res> {
  factory _$SubscriptionStatusResponseModelCopyWith(_SubscriptionStatusResponseModel value, $Res Function(_SubscriptionStatusResponseModel) _then) = __$SubscriptionStatusResponseModelCopyWithImpl;
@override @useResult
$Res call({
 bool isActive, String? expiryDate, String? productId, String? status
});




}
/// @nodoc
class __$SubscriptionStatusResponseModelCopyWithImpl<$Res>
    implements _$SubscriptionStatusResponseModelCopyWith<$Res> {
  __$SubscriptionStatusResponseModelCopyWithImpl(this._self, this._then);

  final _SubscriptionStatusResponseModel _self;
  final $Res Function(_SubscriptionStatusResponseModel) _then;

/// Create a copy of SubscriptionStatusResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isActive = null,Object? expiryDate = freezed,Object? productId = freezed,Object? status = freezed,}) {
  return _then(_SubscriptionStatusResponseModel(
isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,expiryDate: freezed == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
