// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubscriptionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionState()';
}


}

/// @nodoc
class $SubscriptionStateCopyWith<$Res>  {
$SubscriptionStateCopyWith(SubscriptionState _, $Res Function(SubscriptionState) __);
}


/// Adds pattern-matching-related methods to [SubscriptionState].
extension SubscriptionStatePatterns on SubscriptionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SubscriptionGuest value)?  guest,TResult Function( SubscriptionPremium value)?  premium,TResult Function( SubscriptionLoading value)?  loading,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SubscriptionGuest() when guest != null:
return guest(_that);case SubscriptionPremium() when premium != null:
return premium(_that);case SubscriptionLoading() when loading != null:
return loading(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SubscriptionGuest value)  guest,required TResult Function( SubscriptionPremium value)  premium,required TResult Function( SubscriptionLoading value)  loading,}){
final _that = this;
switch (_that) {
case SubscriptionGuest():
return guest(_that);case SubscriptionPremium():
return premium(_that);case SubscriptionLoading():
return loading(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SubscriptionGuest value)?  guest,TResult? Function( SubscriptionPremium value)?  premium,TResult? Function( SubscriptionLoading value)?  loading,}){
final _that = this;
switch (_that) {
case SubscriptionGuest() when guest != null:
return guest(_that);case SubscriptionPremium() when premium != null:
return premium(_that);case SubscriptionLoading() when loading != null:
return loading(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  guest,TResult Function( UserEntity user)?  premium,TResult Function()?  loading,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SubscriptionGuest() when guest != null:
return guest();case SubscriptionPremium() when premium != null:
return premium(_that.user);case SubscriptionLoading() when loading != null:
return loading();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  guest,required TResult Function( UserEntity user)  premium,required TResult Function()  loading,}) {final _that = this;
switch (_that) {
case SubscriptionGuest():
return guest();case SubscriptionPremium():
return premium(_that.user);case SubscriptionLoading():
return loading();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  guest,TResult? Function( UserEntity user)?  premium,TResult? Function()?  loading,}) {final _that = this;
switch (_that) {
case SubscriptionGuest() when guest != null:
return guest();case SubscriptionPremium() when premium != null:
return premium(_that.user);case SubscriptionLoading() when loading != null:
return loading();case _:
  return null;

}
}

}

/// @nodoc


class SubscriptionGuest implements SubscriptionState {
  const SubscriptionGuest();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionGuest);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionState.guest()';
}


}




/// @nodoc


class SubscriptionPremium implements SubscriptionState {
  const SubscriptionPremium({required this.user});
  

 final  UserEntity user;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPremiumCopyWith<SubscriptionPremium> get copyWith => _$SubscriptionPremiumCopyWithImpl<SubscriptionPremium>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPremium&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'SubscriptionState.premium(user: $user)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPremiumCopyWith<$Res> implements $SubscriptionStateCopyWith<$Res> {
  factory $SubscriptionPremiumCopyWith(SubscriptionPremium value, $Res Function(SubscriptionPremium) _then) = _$SubscriptionPremiumCopyWithImpl;
@useResult
$Res call({
 UserEntity user
});




}
/// @nodoc
class _$SubscriptionPremiumCopyWithImpl<$Res>
    implements $SubscriptionPremiumCopyWith<$Res> {
  _$SubscriptionPremiumCopyWithImpl(this._self, this._then);

  final SubscriptionPremium _self;
  final $Res Function(SubscriptionPremium) _then;

/// Create a copy of SubscriptionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(SubscriptionPremium(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity,
  ));
}


}

/// @nodoc


class SubscriptionLoading implements SubscriptionState {
  const SubscriptionLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubscriptionState.loading()';
}


}




// dart format on
