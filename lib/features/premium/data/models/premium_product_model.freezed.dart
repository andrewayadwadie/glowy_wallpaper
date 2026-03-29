// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PremiumProductModel {

 String get productId; String get title; String get price; BillingPeriod get billingPeriod; double get rawPrice;
/// Create a copy of PremiumProductModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PremiumProductModelCopyWith<PremiumProductModel> get copyWith => _$PremiumProductModelCopyWithImpl<PremiumProductModel>(this as PremiumProductModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PremiumProductModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.title, title) || other.title == title)&&(identical(other.price, price) || other.price == price)&&(identical(other.billingPeriod, billingPeriod) || other.billingPeriod == billingPeriod)&&(identical(other.rawPrice, rawPrice) || other.rawPrice == rawPrice));
}


@override
int get hashCode => Object.hash(runtimeType,productId,title,price,billingPeriod,rawPrice);

@override
String toString() {
  return 'PremiumProductModel(productId: $productId, title: $title, price: $price, billingPeriod: $billingPeriod, rawPrice: $rawPrice)';
}


}

/// @nodoc
abstract mixin class $PremiumProductModelCopyWith<$Res>  {
  factory $PremiumProductModelCopyWith(PremiumProductModel value, $Res Function(PremiumProductModel) _then) = _$PremiumProductModelCopyWithImpl;
@useResult
$Res call({
 String productId, String title, String price, BillingPeriod billingPeriod, double rawPrice
});




}
/// @nodoc
class _$PremiumProductModelCopyWithImpl<$Res>
    implements $PremiumProductModelCopyWith<$Res> {
  _$PremiumProductModelCopyWithImpl(this._self, this._then);

  final PremiumProductModel _self;
  final $Res Function(PremiumProductModel) _then;

/// Create a copy of PremiumProductModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? title = null,Object? price = null,Object? billingPeriod = null,Object? rawPrice = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,billingPeriod: null == billingPeriod ? _self.billingPeriod : billingPeriod // ignore: cast_nullable_to_non_nullable
as BillingPeriod,rawPrice: null == rawPrice ? _self.rawPrice : rawPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PremiumProductModel].
extension PremiumProductModelPatterns on PremiumProductModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PremiumProductModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PremiumProductModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PremiumProductModel value)  $default,){
final _that = this;
switch (_that) {
case _PremiumProductModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PremiumProductModel value)?  $default,){
final _that = this;
switch (_that) {
case _PremiumProductModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String title,  String price,  BillingPeriod billingPeriod,  double rawPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PremiumProductModel() when $default != null:
return $default(_that.productId,_that.title,_that.price,_that.billingPeriod,_that.rawPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String title,  String price,  BillingPeriod billingPeriod,  double rawPrice)  $default,) {final _that = this;
switch (_that) {
case _PremiumProductModel():
return $default(_that.productId,_that.title,_that.price,_that.billingPeriod,_that.rawPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String title,  String price,  BillingPeriod billingPeriod,  double rawPrice)?  $default,) {final _that = this;
switch (_that) {
case _PremiumProductModel() when $default != null:
return $default(_that.productId,_that.title,_that.price,_that.billingPeriod,_that.rawPrice);case _:
  return null;

}
}

}

/// @nodoc


class _PremiumProductModel extends PremiumProductModel {
  const _PremiumProductModel({required this.productId, required this.title, required this.price, required this.billingPeriod, required this.rawPrice}): super._();
  

@override final  String productId;
@override final  String title;
@override final  String price;
@override final  BillingPeriod billingPeriod;
@override final  double rawPrice;

/// Create a copy of PremiumProductModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PremiumProductModelCopyWith<_PremiumProductModel> get copyWith => __$PremiumProductModelCopyWithImpl<_PremiumProductModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PremiumProductModel&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.title, title) || other.title == title)&&(identical(other.price, price) || other.price == price)&&(identical(other.billingPeriod, billingPeriod) || other.billingPeriod == billingPeriod)&&(identical(other.rawPrice, rawPrice) || other.rawPrice == rawPrice));
}


@override
int get hashCode => Object.hash(runtimeType,productId,title,price,billingPeriod,rawPrice);

@override
String toString() {
  return 'PremiumProductModel(productId: $productId, title: $title, price: $price, billingPeriod: $billingPeriod, rawPrice: $rawPrice)';
}


}

/// @nodoc
abstract mixin class _$PremiumProductModelCopyWith<$Res> implements $PremiumProductModelCopyWith<$Res> {
  factory _$PremiumProductModelCopyWith(_PremiumProductModel value, $Res Function(_PremiumProductModel) _then) = __$PremiumProductModelCopyWithImpl;
@override @useResult
$Res call({
 String productId, String title, String price, BillingPeriod billingPeriod, double rawPrice
});




}
/// @nodoc
class __$PremiumProductModelCopyWithImpl<$Res>
    implements _$PremiumProductModelCopyWith<$Res> {
  __$PremiumProductModelCopyWithImpl(this._self, this._then);

  final _PremiumProductModel _self;
  final $Res Function(_PremiumProductModel) _then;

/// Create a copy of PremiumProductModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? title = null,Object? price = null,Object? billingPeriod = null,Object? rawPrice = null,}) {
  return _then(_PremiumProductModel(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,billingPeriod: null == billingPeriod ? _self.billingPeriod : billingPeriod // ignore: cast_nullable_to_non_nullable
as BillingPeriod,rawPrice: null == rawPrice ? _self.rawPrice : rawPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
