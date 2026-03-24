// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallpaper_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WallpaperDetailState {

 List<WallpaperEntity> get wallpapers; int get currentIndex; bool get isFavorite; bool get isDownloading; double get downloadProgress; Status get similarWallpapersStatus; List<WallpaperEntity> get similarWallpapers; String? get errorMessage; bool get isMuted;
/// Create a copy of WallpaperDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperDetailStateCopyWith<WallpaperDetailState> get copyWith => _$WallpaperDetailStateCopyWithImpl<WallpaperDetailState>(this as WallpaperDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperDetailState&&const DeepCollectionEquality().equals(other.wallpapers, wallpapers)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.similarWallpapersStatus, similarWallpapersStatus) || other.similarWallpapersStatus == similarWallpapersStatus)&&const DeepCollectionEquality().equals(other.similarWallpapers, similarWallpapers)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(wallpapers),currentIndex,isFavorite,isDownloading,downloadProgress,similarWallpapersStatus,const DeepCollectionEquality().hash(similarWallpapers),errorMessage,isMuted);

@override
String toString() {
  return 'WallpaperDetailState(wallpapers: $wallpapers, currentIndex: $currentIndex, isFavorite: $isFavorite, isDownloading: $isDownloading, downloadProgress: $downloadProgress, similarWallpapersStatus: $similarWallpapersStatus, similarWallpapers: $similarWallpapers, errorMessage: $errorMessage, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class $WallpaperDetailStateCopyWith<$Res>  {
  factory $WallpaperDetailStateCopyWith(WallpaperDetailState value, $Res Function(WallpaperDetailState) _then) = _$WallpaperDetailStateCopyWithImpl;
@useResult
$Res call({
 List<WallpaperEntity> wallpapers, int currentIndex, bool isFavorite, bool isDownloading, double downloadProgress, Status similarWallpapersStatus, List<WallpaperEntity> similarWallpapers, String? errorMessage, bool isMuted
});




}
/// @nodoc
class _$WallpaperDetailStateCopyWithImpl<$Res>
    implements $WallpaperDetailStateCopyWith<$Res> {
  _$WallpaperDetailStateCopyWithImpl(this._self, this._then);

  final WallpaperDetailState _self;
  final $Res Function(WallpaperDetailState) _then;

/// Create a copy of WallpaperDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wallpapers = null,Object? currentIndex = null,Object? isFavorite = null,Object? isDownloading = null,Object? downloadProgress = null,Object? similarWallpapersStatus = null,Object? similarWallpapers = null,Object? errorMessage = freezed,Object? isMuted = null,}) {
  return _then(_self.copyWith(
wallpapers: null == wallpapers ? _self.wallpapers : wallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,similarWallpapersStatus: null == similarWallpapersStatus ? _self.similarWallpapersStatus : similarWallpapersStatus // ignore: cast_nullable_to_non_nullable
as Status,similarWallpapers: null == similarWallpapers ? _self.similarWallpapers : similarWallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WallpaperDetailState].
extension WallpaperDetailStatePatterns on WallpaperDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallpaperDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallpaperDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallpaperDetailState value)  $default,){
final _that = this;
switch (_that) {
case _WallpaperDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallpaperDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _WallpaperDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WallpaperEntity> wallpapers,  int currentIndex,  bool isFavorite,  bool isDownloading,  double downloadProgress,  Status similarWallpapersStatus,  List<WallpaperEntity> similarWallpapers,  String? errorMessage,  bool isMuted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperDetailState() when $default != null:
return $default(_that.wallpapers,_that.currentIndex,_that.isFavorite,_that.isDownloading,_that.downloadProgress,_that.similarWallpapersStatus,_that.similarWallpapers,_that.errorMessage,_that.isMuted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WallpaperEntity> wallpapers,  int currentIndex,  bool isFavorite,  bool isDownloading,  double downloadProgress,  Status similarWallpapersStatus,  List<WallpaperEntity> similarWallpapers,  String? errorMessage,  bool isMuted)  $default,) {final _that = this;
switch (_that) {
case _WallpaperDetailState():
return $default(_that.wallpapers,_that.currentIndex,_that.isFavorite,_that.isDownloading,_that.downloadProgress,_that.similarWallpapersStatus,_that.similarWallpapers,_that.errorMessage,_that.isMuted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WallpaperEntity> wallpapers,  int currentIndex,  bool isFavorite,  bool isDownloading,  double downloadProgress,  Status similarWallpapersStatus,  List<WallpaperEntity> similarWallpapers,  String? errorMessage,  bool isMuted)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperDetailState() when $default != null:
return $default(_that.wallpapers,_that.currentIndex,_that.isFavorite,_that.isDownloading,_that.downloadProgress,_that.similarWallpapersStatus,_that.similarWallpapers,_that.errorMessage,_that.isMuted);case _:
  return null;

}
}

}

/// @nodoc


class _WallpaperDetailState implements WallpaperDetailState {
  const _WallpaperDetailState({final  List<WallpaperEntity> wallpapers = const [], this.currentIndex = 0, this.isFavorite = false, this.isDownloading = false, this.downloadProgress = 0.0, this.similarWallpapersStatus = Status.loading, final  List<WallpaperEntity> similarWallpapers = const [], this.errorMessage, this.isMuted = false}): _wallpapers = wallpapers,_similarWallpapers = similarWallpapers;
  

 final  List<WallpaperEntity> _wallpapers;
@override@JsonKey() List<WallpaperEntity> get wallpapers {
  if (_wallpapers is EqualUnmodifiableListView) return _wallpapers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallpapers);
}

@override@JsonKey() final  int currentIndex;
@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isDownloading;
@override@JsonKey() final  double downloadProgress;
@override@JsonKey() final  Status similarWallpapersStatus;
 final  List<WallpaperEntity> _similarWallpapers;
@override@JsonKey() List<WallpaperEntity> get similarWallpapers {
  if (_similarWallpapers is EqualUnmodifiableListView) return _similarWallpapers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_similarWallpapers);
}

@override final  String? errorMessage;
@override@JsonKey() final  bool isMuted;

/// Create a copy of WallpaperDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallpaperDetailStateCopyWith<_WallpaperDetailState> get copyWith => __$WallpaperDetailStateCopyWithImpl<_WallpaperDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperDetailState&&const DeepCollectionEquality().equals(other._wallpapers, _wallpapers)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.similarWallpapersStatus, similarWallpapersStatus) || other.similarWallpapersStatus == similarWallpapersStatus)&&const DeepCollectionEquality().equals(other._similarWallpapers, _similarWallpapers)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_wallpapers),currentIndex,isFavorite,isDownloading,downloadProgress,similarWallpapersStatus,const DeepCollectionEquality().hash(_similarWallpapers),errorMessage,isMuted);

@override
String toString() {
  return 'WallpaperDetailState(wallpapers: $wallpapers, currentIndex: $currentIndex, isFavorite: $isFavorite, isDownloading: $isDownloading, downloadProgress: $downloadProgress, similarWallpapersStatus: $similarWallpapersStatus, similarWallpapers: $similarWallpapers, errorMessage: $errorMessage, isMuted: $isMuted)';
}


}

/// @nodoc
abstract mixin class _$WallpaperDetailStateCopyWith<$Res> implements $WallpaperDetailStateCopyWith<$Res> {
  factory _$WallpaperDetailStateCopyWith(_WallpaperDetailState value, $Res Function(_WallpaperDetailState) _then) = __$WallpaperDetailStateCopyWithImpl;
@override @useResult
$Res call({
 List<WallpaperEntity> wallpapers, int currentIndex, bool isFavorite, bool isDownloading, double downloadProgress, Status similarWallpapersStatus, List<WallpaperEntity> similarWallpapers, String? errorMessage, bool isMuted
});




}
/// @nodoc
class __$WallpaperDetailStateCopyWithImpl<$Res>
    implements _$WallpaperDetailStateCopyWith<$Res> {
  __$WallpaperDetailStateCopyWithImpl(this._self, this._then);

  final _WallpaperDetailState _self;
  final $Res Function(_WallpaperDetailState) _then;

/// Create a copy of WallpaperDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wallpapers = null,Object? currentIndex = null,Object? isFavorite = null,Object? isDownloading = null,Object? downloadProgress = null,Object? similarWallpapersStatus = null,Object? similarWallpapers = null,Object? errorMessage = freezed,Object? isMuted = null,}) {
  return _then(_WallpaperDetailState(
wallpapers: null == wallpapers ? _self._wallpapers : wallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,similarWallpapersStatus: null == similarWallpapersStatus ? _self.similarWallpapersStatus : similarWallpapersStatus // ignore: cast_nullable_to_non_nullable
as Status,similarWallpapers: null == similarWallpapers ? _self._similarWallpapers : similarWallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
