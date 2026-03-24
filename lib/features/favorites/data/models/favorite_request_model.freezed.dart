// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteRequestModel {

@JsonKey(name: 'wallpaper_id') String get wallpaperId;
/// Create a copy of FavoriteRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteRequestModelCopyWith<FavoriteRequestModel> get copyWith => _$FavoriteRequestModelCopyWithImpl<FavoriteRequestModel>(this as FavoriteRequestModel, _$identity);

  /// Serializes this FavoriteRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteRequestModel&&(identical(other.wallpaperId, wallpaperId) || other.wallpaperId == wallpaperId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wallpaperId);

@override
String toString() {
  return 'FavoriteRequestModel(wallpaperId: $wallpaperId)';
}


}

/// @nodoc
abstract mixin class $FavoriteRequestModelCopyWith<$Res>  {
  factory $FavoriteRequestModelCopyWith(FavoriteRequestModel value, $Res Function(FavoriteRequestModel) _then) = _$FavoriteRequestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'wallpaper_id') String wallpaperId
});




}
/// @nodoc
class _$FavoriteRequestModelCopyWithImpl<$Res>
    implements $FavoriteRequestModelCopyWith<$Res> {
  _$FavoriteRequestModelCopyWithImpl(this._self, this._then);

  final FavoriteRequestModel _self;
  final $Res Function(FavoriteRequestModel) _then;

/// Create a copy of FavoriteRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wallpaperId = null,}) {
  return _then(_self.copyWith(
wallpaperId: null == wallpaperId ? _self.wallpaperId : wallpaperId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteRequestModel].
extension FavoriteRequestModelPatterns on FavoriteRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteRequestModel() when $default != null:
return $default(_that.wallpaperId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId)  $default,) {final _that = this;
switch (_that) {
case _FavoriteRequestModel():
return $default(_that.wallpaperId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteRequestModel() when $default != null:
return $default(_that.wallpaperId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteRequestModel implements FavoriteRequestModel {
  const _FavoriteRequestModel({@JsonKey(name: 'wallpaper_id') required this.wallpaperId});
  factory _FavoriteRequestModel.fromJson(Map<String, dynamic> json) => _$FavoriteRequestModelFromJson(json);

@override@JsonKey(name: 'wallpaper_id') final  String wallpaperId;

/// Create a copy of FavoriteRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteRequestModelCopyWith<_FavoriteRequestModel> get copyWith => __$FavoriteRequestModelCopyWithImpl<_FavoriteRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteRequestModel&&(identical(other.wallpaperId, wallpaperId) || other.wallpaperId == wallpaperId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wallpaperId);

@override
String toString() {
  return 'FavoriteRequestModel(wallpaperId: $wallpaperId)';
}


}

/// @nodoc
abstract mixin class _$FavoriteRequestModelCopyWith<$Res> implements $FavoriteRequestModelCopyWith<$Res> {
  factory _$FavoriteRequestModelCopyWith(_FavoriteRequestModel value, $Res Function(_FavoriteRequestModel) _then) = __$FavoriteRequestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'wallpaper_id') String wallpaperId
});




}
/// @nodoc
class __$FavoriteRequestModelCopyWithImpl<$Res>
    implements _$FavoriteRequestModelCopyWith<$Res> {
  __$FavoriteRequestModelCopyWithImpl(this._self, this._then);

  final _FavoriteRequestModel _self;
  final $Res Function(_FavoriteRequestModel) _then;

/// Create a copy of FavoriteRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wallpaperId = null,}) {
  return _then(_FavoriteRequestModel(
wallpaperId: null == wallpaperId ? _self.wallpaperId : wallpaperId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MergeFavoritesRequestModel {

@JsonKey(name: 'wallpaper_ids') List<String> get wallpaperIds;
/// Create a copy of MergeFavoritesRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeFavoritesRequestModelCopyWith<MergeFavoritesRequestModel> get copyWith => _$MergeFavoritesRequestModelCopyWithImpl<MergeFavoritesRequestModel>(this as MergeFavoritesRequestModel, _$identity);

  /// Serializes this MergeFavoritesRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeFavoritesRequestModel&&const DeepCollectionEquality().equals(other.wallpaperIds, wallpaperIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(wallpaperIds));

@override
String toString() {
  return 'MergeFavoritesRequestModel(wallpaperIds: $wallpaperIds)';
}


}

/// @nodoc
abstract mixin class $MergeFavoritesRequestModelCopyWith<$Res>  {
  factory $MergeFavoritesRequestModelCopyWith(MergeFavoritesRequestModel value, $Res Function(MergeFavoritesRequestModel) _then) = _$MergeFavoritesRequestModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'wallpaper_ids') List<String> wallpaperIds
});




}
/// @nodoc
class _$MergeFavoritesRequestModelCopyWithImpl<$Res>
    implements $MergeFavoritesRequestModelCopyWith<$Res> {
  _$MergeFavoritesRequestModelCopyWithImpl(this._self, this._then);

  final MergeFavoritesRequestModel _self;
  final $Res Function(MergeFavoritesRequestModel) _then;

/// Create a copy of MergeFavoritesRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wallpaperIds = null,}) {
  return _then(_self.copyWith(
wallpaperIds: null == wallpaperIds ? _self.wallpaperIds : wallpaperIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MergeFavoritesRequestModel].
extension MergeFavoritesRequestModelPatterns on MergeFavoritesRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergeFavoritesRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergeFavoritesRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergeFavoritesRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _MergeFavoritesRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergeFavoritesRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _MergeFavoritesRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_ids')  List<String> wallpaperIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergeFavoritesRequestModel() when $default != null:
return $default(_that.wallpaperIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_ids')  List<String> wallpaperIds)  $default,) {final _that = this;
switch (_that) {
case _MergeFavoritesRequestModel():
return $default(_that.wallpaperIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'wallpaper_ids')  List<String> wallpaperIds)?  $default,) {final _that = this;
switch (_that) {
case _MergeFavoritesRequestModel() when $default != null:
return $default(_that.wallpaperIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MergeFavoritesRequestModel implements MergeFavoritesRequestModel {
  const _MergeFavoritesRequestModel({@JsonKey(name: 'wallpaper_ids') required final  List<String> wallpaperIds}): _wallpaperIds = wallpaperIds;
  factory _MergeFavoritesRequestModel.fromJson(Map<String, dynamic> json) => _$MergeFavoritesRequestModelFromJson(json);

 final  List<String> _wallpaperIds;
@override@JsonKey(name: 'wallpaper_ids') List<String> get wallpaperIds {
  if (_wallpaperIds is EqualUnmodifiableListView) return _wallpaperIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallpaperIds);
}


/// Create a copy of MergeFavoritesRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergeFavoritesRequestModelCopyWith<_MergeFavoritesRequestModel> get copyWith => __$MergeFavoritesRequestModelCopyWithImpl<_MergeFavoritesRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MergeFavoritesRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergeFavoritesRequestModel&&const DeepCollectionEquality().equals(other._wallpaperIds, _wallpaperIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_wallpaperIds));

@override
String toString() {
  return 'MergeFavoritesRequestModel(wallpaperIds: $wallpaperIds)';
}


}

/// @nodoc
abstract mixin class _$MergeFavoritesRequestModelCopyWith<$Res> implements $MergeFavoritesRequestModelCopyWith<$Res> {
  factory _$MergeFavoritesRequestModelCopyWith(_MergeFavoritesRequestModel value, $Res Function(_MergeFavoritesRequestModel) _then) = __$MergeFavoritesRequestModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'wallpaper_ids') List<String> wallpaperIds
});




}
/// @nodoc
class __$MergeFavoritesRequestModelCopyWithImpl<$Res>
    implements _$MergeFavoritesRequestModelCopyWith<$Res> {
  __$MergeFavoritesRequestModelCopyWithImpl(this._self, this._then);

  final _MergeFavoritesRequestModel _self;
  final $Res Function(_MergeFavoritesRequestModel) _then;

/// Create a copy of MergeFavoritesRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wallpaperIds = null,}) {
  return _then(_MergeFavoritesRequestModel(
wallpaperIds: null == wallpaperIds ? _self._wallpaperIds : wallpaperIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
