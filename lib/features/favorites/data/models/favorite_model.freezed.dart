// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteModel {

@JsonKey(name: 'wallpaper_id') String get wallpaperId; WallpaperModel get wallpaper;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'favorited_at') DateTime get favoritedAt;@JsonKey(name: 'sync_status') String get syncStatus;
/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteModelCopyWith<FavoriteModel> get copyWith => _$FavoriteModelCopyWithImpl<FavoriteModel>(this as FavoriteModel, _$identity);

  /// Serializes this FavoriteModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteModel&&(identical(other.wallpaperId, wallpaperId) || other.wallpaperId == wallpaperId)&&(identical(other.wallpaper, wallpaper) || other.wallpaper == wallpaper)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.favoritedAt, favoritedAt) || other.favoritedAt == favoritedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wallpaperId,wallpaper,userId,favoritedAt,syncStatus);

@override
String toString() {
  return 'FavoriteModel(wallpaperId: $wallpaperId, wallpaper: $wallpaper, userId: $userId, favoritedAt: $favoritedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $FavoriteModelCopyWith<$Res>  {
  factory $FavoriteModelCopyWith(FavoriteModel value, $Res Function(FavoriteModel) _then) = _$FavoriteModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'wallpaper_id') String wallpaperId, WallpaperModel wallpaper,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'favorited_at') DateTime favoritedAt,@JsonKey(name: 'sync_status') String syncStatus
});


$WallpaperModelCopyWith<$Res> get wallpaper;

}
/// @nodoc
class _$FavoriteModelCopyWithImpl<$Res>
    implements $FavoriteModelCopyWith<$Res> {
  _$FavoriteModelCopyWithImpl(this._self, this._then);

  final FavoriteModel _self;
  final $Res Function(FavoriteModel) _then;

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wallpaperId = null,Object? wallpaper = null,Object? userId = freezed,Object? favoritedAt = null,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
wallpaperId: null == wallpaperId ? _self.wallpaperId : wallpaperId // ignore: cast_nullable_to_non_nullable
as String,wallpaper: null == wallpaper ? _self.wallpaper : wallpaper // ignore: cast_nullable_to_non_nullable
as WallpaperModel,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,favoritedAt: null == favoritedAt ? _self.favoritedAt : favoritedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WallpaperModelCopyWith<$Res> get wallpaper {
  
  return $WallpaperModelCopyWith<$Res>(_self.wallpaper, (value) {
    return _then(_self.copyWith(wallpaper: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavoriteModel].
extension FavoriteModelPatterns on FavoriteModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteModel value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteModel value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId,  WallpaperModel wallpaper, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'favorited_at')  DateTime favoritedAt, @JsonKey(name: 'sync_status')  String syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
return $default(_that.wallpaperId,_that.wallpaper,_that.userId,_that.favoritedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId,  WallpaperModel wallpaper, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'favorited_at')  DateTime favoritedAt, @JsonKey(name: 'sync_status')  String syncStatus)  $default,) {final _that = this;
switch (_that) {
case _FavoriteModel():
return $default(_that.wallpaperId,_that.wallpaper,_that.userId,_that.favoritedAt,_that.syncStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId,  WallpaperModel wallpaper, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'favorited_at')  DateTime favoritedAt, @JsonKey(name: 'sync_status')  String syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteModel() when $default != null:
return $default(_that.wallpaperId,_that.wallpaper,_that.userId,_that.favoritedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteModel extends FavoriteModel {
  const _FavoriteModel({@JsonKey(name: 'wallpaper_id') required this.wallpaperId, required this.wallpaper, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'favorited_at') required this.favoritedAt, @JsonKey(name: 'sync_status') this.syncStatus = 'synced'}): super._();
  factory _FavoriteModel.fromJson(Map<String, dynamic> json) => _$FavoriteModelFromJson(json);

@override@JsonKey(name: 'wallpaper_id') final  String wallpaperId;
@override final  WallpaperModel wallpaper;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'favorited_at') final  DateTime favoritedAt;
@override@JsonKey(name: 'sync_status') final  String syncStatus;

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteModelCopyWith<_FavoriteModel> get copyWith => __$FavoriteModelCopyWithImpl<_FavoriteModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteModel&&(identical(other.wallpaperId, wallpaperId) || other.wallpaperId == wallpaperId)&&(identical(other.wallpaper, wallpaper) || other.wallpaper == wallpaper)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.favoritedAt, favoritedAt) || other.favoritedAt == favoritedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wallpaperId,wallpaper,userId,favoritedAt,syncStatus);

@override
String toString() {
  return 'FavoriteModel(wallpaperId: $wallpaperId, wallpaper: $wallpaper, userId: $userId, favoritedAt: $favoritedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$FavoriteModelCopyWith<$Res> implements $FavoriteModelCopyWith<$Res> {
  factory _$FavoriteModelCopyWith(_FavoriteModel value, $Res Function(_FavoriteModel) _then) = __$FavoriteModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'wallpaper_id') String wallpaperId, WallpaperModel wallpaper,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'favorited_at') DateTime favoritedAt,@JsonKey(name: 'sync_status') String syncStatus
});


@override $WallpaperModelCopyWith<$Res> get wallpaper;

}
/// @nodoc
class __$FavoriteModelCopyWithImpl<$Res>
    implements _$FavoriteModelCopyWith<$Res> {
  __$FavoriteModelCopyWithImpl(this._self, this._then);

  final _FavoriteModel _self;
  final $Res Function(_FavoriteModel) _then;

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wallpaperId = null,Object? wallpaper = null,Object? userId = freezed,Object? favoritedAt = null,Object? syncStatus = null,}) {
  return _then(_FavoriteModel(
wallpaperId: null == wallpaperId ? _self.wallpaperId : wallpaperId // ignore: cast_nullable_to_non_nullable
as String,wallpaper: null == wallpaper ? _self.wallpaper : wallpaper // ignore: cast_nullable_to_non_nullable
as WallpaperModel,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,favoritedAt: null == favoritedAt ? _self.favoritedAt : favoritedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of FavoriteModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WallpaperModelCopyWith<$Res> get wallpaper {
  
  return $WallpaperModelCopyWith<$Res>(_self.wallpaper, (value) {
    return _then(_self.copyWith(wallpaper: value));
  });
}
}

// dart format on
