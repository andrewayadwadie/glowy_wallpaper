// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallpaper_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WallpaperModel {

 String get id; String get url; String get thumbUrl; bool get isTopRated; String get mediaType; String? get classificationId; String? get classificationName; String? get classificationThumbnailUrl; String get createdAt;
/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperModelCopyWith<WallpaperModel> get copyWith => _$WallpaperModelCopyWithImpl<WallpaperModel>(this as WallpaperModel, _$identity);

  /// Serializes this WallpaperModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperModel&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.isTopRated, isTopRated) || other.isTopRated == isTopRated)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.classificationId, classificationId) || other.classificationId == classificationId)&&(identical(other.classificationName, classificationName) || other.classificationName == classificationName)&&(identical(other.classificationThumbnailUrl, classificationThumbnailUrl) || other.classificationThumbnailUrl == classificationThumbnailUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,thumbUrl,isTopRated,mediaType,classificationId,classificationName,classificationThumbnailUrl,createdAt);

@override
String toString() {
  return 'WallpaperModel(id: $id, url: $url, thumbUrl: $thumbUrl, isTopRated: $isTopRated, mediaType: $mediaType, classificationId: $classificationId, classificationName: $classificationName, classificationThumbnailUrl: $classificationThumbnailUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WallpaperModelCopyWith<$Res>  {
  factory $WallpaperModelCopyWith(WallpaperModel value, $Res Function(WallpaperModel) _then) = _$WallpaperModelCopyWithImpl;
@useResult
$Res call({
 String id, String url, String thumbUrl, bool isTopRated, String mediaType, String? classificationId, String? classificationName, String? classificationThumbnailUrl, String createdAt
});




}
/// @nodoc
class _$WallpaperModelCopyWithImpl<$Res>
    implements $WallpaperModelCopyWith<$Res> {
  _$WallpaperModelCopyWithImpl(this._self, this._then);

  final WallpaperModel _self;
  final $Res Function(WallpaperModel) _then;

/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? thumbUrl = null,Object? isTopRated = null,Object? mediaType = null,Object? classificationId = freezed,Object? classificationName = freezed,Object? classificationThumbnailUrl = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbUrl: null == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String,isTopRated: null == isTopRated ? _self.isTopRated : isTopRated // ignore: cast_nullable_to_non_nullable
as bool,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,classificationId: freezed == classificationId ? _self.classificationId : classificationId // ignore: cast_nullable_to_non_nullable
as String?,classificationName: freezed == classificationName ? _self.classificationName : classificationName // ignore: cast_nullable_to_non_nullable
as String?,classificationThumbnailUrl: freezed == classificationThumbnailUrl ? _self.classificationThumbnailUrl : classificationThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WallpaperModel].
extension WallpaperModelPatterns on WallpaperModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WallpaperModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WallpaperModel value)  $default,){
final _that = this;
switch (_that) {
case _WallpaperModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WallpaperModel value)?  $default,){
final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String thumbUrl,  bool isTopRated,  String mediaType,  String? classificationId,  String? classificationName,  String? classificationThumbnailUrl,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that.id,_that.url,_that.thumbUrl,_that.isTopRated,_that.mediaType,_that.classificationId,_that.classificationName,_that.classificationThumbnailUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String thumbUrl,  bool isTopRated,  String mediaType,  String? classificationId,  String? classificationName,  String? classificationThumbnailUrl,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _WallpaperModel():
return $default(_that.id,_that.url,_that.thumbUrl,_that.isTopRated,_that.mediaType,_that.classificationId,_that.classificationName,_that.classificationThumbnailUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String thumbUrl,  bool isTopRated,  String mediaType,  String? classificationId,  String? classificationName,  String? classificationThumbnailUrl,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that.id,_that.url,_that.thumbUrl,_that.isTopRated,_that.mediaType,_that.classificationId,_that.classificationName,_that.classificationThumbnailUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallpaperModel extends WallpaperModel {
  const _WallpaperModel({required this.id, required this.url, required this.thumbUrl, required this.isTopRated, required this.mediaType, this.classificationId, this.classificationName, this.classificationThumbnailUrl, required this.createdAt}): super._();
  factory _WallpaperModel.fromJson(Map<String, dynamic> json) => _$WallpaperModelFromJson(json);

@override final  String id;
@override final  String url;
@override final  String thumbUrl;
@override final  bool isTopRated;
@override final  String mediaType;
@override final  String? classificationId;
@override final  String? classificationName;
@override final  String? classificationThumbnailUrl;
@override final  String createdAt;

/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WallpaperModelCopyWith<_WallpaperModel> get copyWith => __$WallpaperModelCopyWithImpl<_WallpaperModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WallpaperModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperModel&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.isTopRated, isTopRated) || other.isTopRated == isTopRated)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.classificationId, classificationId) || other.classificationId == classificationId)&&(identical(other.classificationName, classificationName) || other.classificationName == classificationName)&&(identical(other.classificationThumbnailUrl, classificationThumbnailUrl) || other.classificationThumbnailUrl == classificationThumbnailUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,thumbUrl,isTopRated,mediaType,classificationId,classificationName,classificationThumbnailUrl,createdAt);

@override
String toString() {
  return 'WallpaperModel(id: $id, url: $url, thumbUrl: $thumbUrl, isTopRated: $isTopRated, mediaType: $mediaType, classificationId: $classificationId, classificationName: $classificationName, classificationThumbnailUrl: $classificationThumbnailUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WallpaperModelCopyWith<$Res> implements $WallpaperModelCopyWith<$Res> {
  factory _$WallpaperModelCopyWith(_WallpaperModel value, $Res Function(_WallpaperModel) _then) = __$WallpaperModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String thumbUrl, bool isTopRated, String mediaType, String? classificationId, String? classificationName, String? classificationThumbnailUrl, String createdAt
});




}
/// @nodoc
class __$WallpaperModelCopyWithImpl<$Res>
    implements _$WallpaperModelCopyWith<$Res> {
  __$WallpaperModelCopyWithImpl(this._self, this._then);

  final _WallpaperModel _self;
  final $Res Function(_WallpaperModel) _then;

/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? thumbUrl = null,Object? isTopRated = null,Object? mediaType = null,Object? classificationId = freezed,Object? classificationName = freezed,Object? classificationThumbnailUrl = freezed,Object? createdAt = null,}) {
  return _then(_WallpaperModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,thumbUrl: null == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String,isTopRated: null == isTopRated ? _self.isTopRated : isTopRated // ignore: cast_nullable_to_non_nullable
as bool,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,classificationId: freezed == classificationId ? _self.classificationId : classificationId // ignore: cast_nullable_to_non_nullable
as String?,classificationName: freezed == classificationName ? _self.classificationName : classificationName // ignore: cast_nullable_to_non_nullable
as String?,classificationThumbnailUrl: freezed == classificationThumbnailUrl ? _self.classificationThumbnailUrl : classificationThumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
