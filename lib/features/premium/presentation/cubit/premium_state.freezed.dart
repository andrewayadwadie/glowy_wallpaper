// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PremiumState {

 Status get productsStatus; List<PremiumProductEntity> get products; PremiumProductEntity? get selectedProduct; bool get isPurchasing; bool get isRestoring; SubscriptionEntity? get purchasedSubscription; String? get errorMessage; String? get successMessage;
/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PremiumStateCopyWith<PremiumState> get copyWith => _$PremiumStateCopyWithImpl<PremiumState>(this as PremiumState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PremiumState&&(identical(other.productsStatus, productsStatus) || other.productsStatus == productsStatus)&&const DeepCollectionEquality().equals(other.products, products)&&(identical(other.selectedProduct, selectedProduct) || other.selectedProduct == selectedProduct)&&(identical(other.isPurchasing, isPurchasing) || other.isPurchasing == isPurchasing)&&(identical(other.isRestoring, isRestoring) || other.isRestoring == isRestoring)&&(identical(other.purchasedSubscription, purchasedSubscription) || other.purchasedSubscription == purchasedSubscription)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,productsStatus,const DeepCollectionEquality().hash(products),selectedProduct,isPurchasing,isRestoring,purchasedSubscription,errorMessage,successMessage);

@override
String toString() {
  return 'PremiumState(productsStatus: $productsStatus, products: $products, selectedProduct: $selectedProduct, isPurchasing: $isPurchasing, isRestoring: $isRestoring, purchasedSubscription: $purchasedSubscription, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $PremiumStateCopyWith<$Res>  {
  factory $PremiumStateCopyWith(PremiumState value, $Res Function(PremiumState) _then) = _$PremiumStateCopyWithImpl;
@useResult
$Res call({
 Status productsStatus, List<PremiumProductEntity> products, PremiumProductEntity? selectedProduct, bool isPurchasing, bool isRestoring, SubscriptionEntity? purchasedSubscription, String? errorMessage, String? successMessage
});




}
/// @nodoc
class _$PremiumStateCopyWithImpl<$Res>
    implements $PremiumStateCopyWith<$Res> {
  _$PremiumStateCopyWithImpl(this._self, this._then);

  final PremiumState _self;
  final $Res Function(PremiumState) _then;

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productsStatus = null,Object? products = null,Object? selectedProduct = freezed,Object? isPurchasing = null,Object? isRestoring = null,Object? purchasedSubscription = freezed,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_self.copyWith(
productsStatus: null == productsStatus ? _self.productsStatus : productsStatus // ignore: cast_nullable_to_non_nullable
as Status,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<PremiumProductEntity>,selectedProduct: freezed == selectedProduct ? _self.selectedProduct : selectedProduct // ignore: cast_nullable_to_non_nullable
as PremiumProductEntity?,isPurchasing: null == isPurchasing ? _self.isPurchasing : isPurchasing // ignore: cast_nullable_to_non_nullable
as bool,isRestoring: null == isRestoring ? _self.isRestoring : isRestoring // ignore: cast_nullable_to_non_nullable
as bool,purchasedSubscription: freezed == purchasedSubscription ? _self.purchasedSubscription : purchasedSubscription // ignore: cast_nullable_to_non_nullable
as SubscriptionEntity?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PremiumState].
extension PremiumStatePatterns on PremiumState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PremiumState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PremiumState value)  $default,){
final _that = this;
switch (_that) {
case _PremiumState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PremiumState value)?  $default,){
final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Status productsStatus,  List<PremiumProductEntity> products,  PremiumProductEntity? selectedProduct,  bool isPurchasing,  bool isRestoring,  SubscriptionEntity? purchasedSubscription,  String? errorMessage,  String? successMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
return $default(_that.productsStatus,_that.products,_that.selectedProduct,_that.isPurchasing,_that.isRestoring,_that.purchasedSubscription,_that.errorMessage,_that.successMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Status productsStatus,  List<PremiumProductEntity> products,  PremiumProductEntity? selectedProduct,  bool isPurchasing,  bool isRestoring,  SubscriptionEntity? purchasedSubscription,  String? errorMessage,  String? successMessage)  $default,) {final _that = this;
switch (_that) {
case _PremiumState():
return $default(_that.productsStatus,_that.products,_that.selectedProduct,_that.isPurchasing,_that.isRestoring,_that.purchasedSubscription,_that.errorMessage,_that.successMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Status productsStatus,  List<PremiumProductEntity> products,  PremiumProductEntity? selectedProduct,  bool isPurchasing,  bool isRestoring,  SubscriptionEntity? purchasedSubscription,  String? errorMessage,  String? successMessage)?  $default,) {final _that = this;
switch (_that) {
case _PremiumState() when $default != null:
return $default(_that.productsStatus,_that.products,_that.selectedProduct,_that.isPurchasing,_that.isRestoring,_that.purchasedSubscription,_that.errorMessage,_that.successMessage);case _:
  return null;

}
}

}

/// @nodoc


class _PremiumState implements PremiumState {
  const _PremiumState({this.productsStatus = Status.loading, final  List<PremiumProductEntity> products = const [], this.selectedProduct, this.isPurchasing = false, this.isRestoring = false, this.purchasedSubscription, this.errorMessage, this.successMessage}): _products = products;
  

@override@JsonKey() final  Status productsStatus;
 final  List<PremiumProductEntity> _products;
@override@JsonKey() List<PremiumProductEntity> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override final  PremiumProductEntity? selectedProduct;
@override@JsonKey() final  bool isPurchasing;
@override@JsonKey() final  bool isRestoring;
@override final  SubscriptionEntity? purchasedSubscription;
@override final  String? errorMessage;
@override final  String? successMessage;

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PremiumStateCopyWith<_PremiumState> get copyWith => __$PremiumStateCopyWithImpl<_PremiumState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PremiumState&&(identical(other.productsStatus, productsStatus) || other.productsStatus == productsStatus)&&const DeepCollectionEquality().equals(other._products, _products)&&(identical(other.selectedProduct, selectedProduct) || other.selectedProduct == selectedProduct)&&(identical(other.isPurchasing, isPurchasing) || other.isPurchasing == isPurchasing)&&(identical(other.isRestoring, isRestoring) || other.isRestoring == isRestoring)&&(identical(other.purchasedSubscription, purchasedSubscription) || other.purchasedSubscription == purchasedSubscription)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,productsStatus,const DeepCollectionEquality().hash(_products),selectedProduct,isPurchasing,isRestoring,purchasedSubscription,errorMessage,successMessage);

@override
String toString() {
  return 'PremiumState(productsStatus: $productsStatus, products: $products, selectedProduct: $selectedProduct, isPurchasing: $isPurchasing, isRestoring: $isRestoring, purchasedSubscription: $purchasedSubscription, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class _$PremiumStateCopyWith<$Res> implements $PremiumStateCopyWith<$Res> {
  factory _$PremiumStateCopyWith(_PremiumState value, $Res Function(_PremiumState) _then) = __$PremiumStateCopyWithImpl;
@override @useResult
$Res call({
 Status productsStatus, List<PremiumProductEntity> products, PremiumProductEntity? selectedProduct, bool isPurchasing, bool isRestoring, SubscriptionEntity? purchasedSubscription, String? errorMessage, String? successMessage
});




}
/// @nodoc
class __$PremiumStateCopyWithImpl<$Res>
    implements _$PremiumStateCopyWith<$Res> {
  __$PremiumStateCopyWithImpl(this._self, this._then);

  final _PremiumState _self;
  final $Res Function(_PremiumState) _then;

/// Create a copy of PremiumState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productsStatus = null,Object? products = null,Object? selectedProduct = freezed,Object? isPurchasing = null,Object? isRestoring = null,Object? purchasedSubscription = freezed,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_PremiumState(
productsStatus: null == productsStatus ? _self.productsStatus : productsStatus // ignore: cast_nullable_to_non_nullable
as Status,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<PremiumProductEntity>,selectedProduct: freezed == selectedProduct ? _self.selectedProduct : selectedProduct // ignore: cast_nullable_to_non_nullable
as PremiumProductEntity?,isPurchasing: null == isPurchasing ? _self.isPurchasing : isPurchasing // ignore: cast_nullable_to_non_nullable
as bool,isRestoring: null == isRestoring ? _self.isRestoring : isRestoring // ignore: cast_nullable_to_non_nullable
as bool,purchasedSubscription: freezed == purchasedSubscription ? _self.purchasedSubscription : purchasedSubscription // ignore: cast_nullable_to_non_nullable
as SubscriptionEntity?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
