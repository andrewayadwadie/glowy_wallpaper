// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState()';
}


}

/// @nodoc
class $NotificationStateCopyWith<$Res>  {
$NotificationStateCopyWith(NotificationState _, $Res Function(NotificationState) __);
}


/// Adds pattern-matching-related methods to [NotificationState].
extension NotificationStatePatterns on NotificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NotificationInitial value)?  initial,TResult Function( NotificationPermissionRequesting value)?  permissionRequesting,TResult Function( NotificationPermissionGranted value)?  permissionGranted,TResult Function( NotificationPermissionDenied value)?  permissionDenied,TResult Function( NotificationError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial(_that);case NotificationPermissionRequesting() when permissionRequesting != null:
return permissionRequesting(_that);case NotificationPermissionGranted() when permissionGranted != null:
return permissionGranted(_that);case NotificationPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case NotificationError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NotificationInitial value)  initial,required TResult Function( NotificationPermissionRequesting value)  permissionRequesting,required TResult Function( NotificationPermissionGranted value)  permissionGranted,required TResult Function( NotificationPermissionDenied value)  permissionDenied,required TResult Function( NotificationError value)  error,}){
final _that = this;
switch (_that) {
case NotificationInitial():
return initial(_that);case NotificationPermissionRequesting():
return permissionRequesting(_that);case NotificationPermissionGranted():
return permissionGranted(_that);case NotificationPermissionDenied():
return permissionDenied(_that);case NotificationError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NotificationInitial value)?  initial,TResult? Function( NotificationPermissionRequesting value)?  permissionRequesting,TResult? Function( NotificationPermissionGranted value)?  permissionGranted,TResult? Function( NotificationPermissionDenied value)?  permissionDenied,TResult? Function( NotificationError value)?  error,}){
final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial(_that);case NotificationPermissionRequesting() when permissionRequesting != null:
return permissionRequesting(_that);case NotificationPermissionGranted() when permissionGranted != null:
return permissionGranted(_that);case NotificationPermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case NotificationError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  permissionRequesting,TResult Function( String? token)?  permissionGranted,TResult Function()?  permissionDenied,TResult Function( Failure failure)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial();case NotificationPermissionRequesting() when permissionRequesting != null:
return permissionRequesting();case NotificationPermissionGranted() when permissionGranted != null:
return permissionGranted(_that.token);case NotificationPermissionDenied() when permissionDenied != null:
return permissionDenied();case NotificationError() when error != null:
return error(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  permissionRequesting,required TResult Function( String? token)  permissionGranted,required TResult Function()  permissionDenied,required TResult Function( Failure failure)  error,}) {final _that = this;
switch (_that) {
case NotificationInitial():
return initial();case NotificationPermissionRequesting():
return permissionRequesting();case NotificationPermissionGranted():
return permissionGranted(_that.token);case NotificationPermissionDenied():
return permissionDenied();case NotificationError():
return error(_that.failure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  permissionRequesting,TResult? Function( String? token)?  permissionGranted,TResult? Function()?  permissionDenied,TResult? Function( Failure failure)?  error,}) {final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial();case NotificationPermissionRequesting() when permissionRequesting != null:
return permissionRequesting();case NotificationPermissionGranted() when permissionGranted != null:
return permissionGranted(_that.token);case NotificationPermissionDenied() when permissionDenied != null:
return permissionDenied();case NotificationError() when error != null:
return error(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class NotificationInitial implements NotificationState {
  const NotificationInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.initial()';
}


}




/// @nodoc


class NotificationPermissionRequesting implements NotificationState {
  const NotificationPermissionRequesting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPermissionRequesting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.permissionRequesting()';
}


}




/// @nodoc


class NotificationPermissionGranted implements NotificationState {
  const NotificationPermissionGranted({this.token});
  

 final  String? token;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPermissionGrantedCopyWith<NotificationPermissionGranted> get copyWith => _$NotificationPermissionGrantedCopyWithImpl<NotificationPermissionGranted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPermissionGranted&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'NotificationState.permissionGranted(token: $token)';
}


}

/// @nodoc
abstract mixin class $NotificationPermissionGrantedCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory $NotificationPermissionGrantedCopyWith(NotificationPermissionGranted value, $Res Function(NotificationPermissionGranted) _then) = _$NotificationPermissionGrantedCopyWithImpl;
@useResult
$Res call({
 String? token
});




}
/// @nodoc
class _$NotificationPermissionGrantedCopyWithImpl<$Res>
    implements $NotificationPermissionGrantedCopyWith<$Res> {
  _$NotificationPermissionGrantedCopyWithImpl(this._self, this._then);

  final NotificationPermissionGranted _self;
  final $Res Function(NotificationPermissionGranted) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = freezed,}) {
  return _then(NotificationPermissionGranted(
token: freezed == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NotificationPermissionDenied implements NotificationState {
  const NotificationPermissionDenied();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPermissionDenied);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.permissionDenied()';
}


}




/// @nodoc


class NotificationError implements NotificationState {
  const NotificationError({required this.failure});
  

 final  Failure failure;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationErrorCopyWith<NotificationError> get copyWith => _$NotificationErrorCopyWithImpl<NotificationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationError&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'NotificationState.error(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $NotificationErrorCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory $NotificationErrorCopyWith(NotificationError value, $Res Function(NotificationError) _then) = _$NotificationErrorCopyWithImpl;
@useResult
$Res call({
 Failure failure
});




}
/// @nodoc
class _$NotificationErrorCopyWithImpl<$Res>
    implements $NotificationErrorCopyWith<$Res> {
  _$NotificationErrorCopyWithImpl(this._self, this._then);

  final NotificationError _self;
  final $Res Function(NotificationError) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(NotificationError(
failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}


}

// dart format on
