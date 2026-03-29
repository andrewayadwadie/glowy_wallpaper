// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadRecordModel {

@JsonKey(name: 'wallpaper_id') String get wallpaperId;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'thumbnail_url') String get thumbnailUrl; String get title;@JsonKey(name: 'downloaded_at') DateTime get downloadedAt;@JsonKey(name: 'file_type') String get fileType;@JsonKey(name: 'is_top_rated') bool get isTopRated;
/// Create a copy of DownloadRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadRecordModelCopyWith<DownloadRecordModel> get copyWith => _$DownloadRecordModelCopyWithImpl<DownloadRecordModel>(this as DownloadRecordModel, _$identity);

  /// Serializes this DownloadRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadRecordModel&&(identical(other.wallpaperId, wallpaperId) || other.wallpaperId == wallpaperId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.downloadedAt, downloadedAt) || other.downloadedAt == downloadedAt)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.isTopRated, isTopRated) || other.isTopRated == isTopRated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wallpaperId,imageUrl,thumbnailUrl,title,downloadedAt,fileType,isTopRated);

@override
String toString() {
  return 'DownloadRecordModel(wallpaperId: $wallpaperId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, title: $title, downloadedAt: $downloadedAt, fileType: $fileType, isTopRated: $isTopRated)';
}


}

/// @nodoc
abstract mixin class $DownloadRecordModelCopyWith<$Res>  {
  factory $DownloadRecordModelCopyWith(DownloadRecordModel value, $Res Function(DownloadRecordModel) _then) = _$DownloadRecordModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'wallpaper_id') String wallpaperId,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String thumbnailUrl, String title,@JsonKey(name: 'downloaded_at') DateTime downloadedAt,@JsonKey(name: 'file_type') String fileType,@JsonKey(name: 'is_top_rated') bool isTopRated
});




}
/// @nodoc
class _$DownloadRecordModelCopyWithImpl<$Res>
    implements $DownloadRecordModelCopyWith<$Res> {
  _$DownloadRecordModelCopyWithImpl(this._self, this._then);

  final DownloadRecordModel _self;
  final $Res Function(DownloadRecordModel) _then;

/// Create a copy of DownloadRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wallpaperId = null,Object? imageUrl = null,Object? thumbnailUrl = null,Object? title = null,Object? downloadedAt = null,Object? fileType = null,Object? isTopRated = null,}) {
  return _then(_self.copyWith(
wallpaperId: null == wallpaperId ? _self.wallpaperId : wallpaperId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,downloadedAt: null == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,isTopRated: null == isTopRated ? _self.isTopRated : isTopRated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadRecordModel].
extension DownloadRecordModelPatterns on DownloadRecordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadRecordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _DownloadRecordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadRecordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl,  String title, @JsonKey(name: 'downloaded_at')  DateTime downloadedAt, @JsonKey(name: 'file_type')  String fileType, @JsonKey(name: 'is_top_rated')  bool isTopRated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadRecordModel() when $default != null:
return $default(_that.wallpaperId,_that.imageUrl,_that.thumbnailUrl,_that.title,_that.downloadedAt,_that.fileType,_that.isTopRated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl,  String title, @JsonKey(name: 'downloaded_at')  DateTime downloadedAt, @JsonKey(name: 'file_type')  String fileType, @JsonKey(name: 'is_top_rated')  bool isTopRated)  $default,) {final _that = this;
switch (_that) {
case _DownloadRecordModel():
return $default(_that.wallpaperId,_that.imageUrl,_that.thumbnailUrl,_that.title,_that.downloadedAt,_that.fileType,_that.isTopRated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'wallpaper_id')  String wallpaperId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl,  String title, @JsonKey(name: 'downloaded_at')  DateTime downloadedAt, @JsonKey(name: 'file_type')  String fileType, @JsonKey(name: 'is_top_rated')  bool isTopRated)?  $default,) {final _that = this;
switch (_that) {
case _DownloadRecordModel() when $default != null:
return $default(_that.wallpaperId,_that.imageUrl,_that.thumbnailUrl,_that.title,_that.downloadedAt,_that.fileType,_that.isTopRated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DownloadRecordModel extends DownloadRecordModel {
  const _DownloadRecordModel({@JsonKey(name: 'wallpaper_id') required this.wallpaperId, @JsonKey(name: 'image_url') this.imageUrl = '', @JsonKey(name: 'thumbnail_url') required this.thumbnailUrl, required this.title, @JsonKey(name: 'downloaded_at') required this.downloadedAt, @JsonKey(name: 'file_type') this.fileType = 'image', @JsonKey(name: 'is_top_rated') this.isTopRated = false}): super._();
  factory _DownloadRecordModel.fromJson(Map<String, dynamic> json) => _$DownloadRecordModelFromJson(json);

@override@JsonKey(name: 'wallpaper_id') final  String wallpaperId;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'thumbnail_url') final  String thumbnailUrl;
@override final  String title;
@override@JsonKey(name: 'downloaded_at') final  DateTime downloadedAt;
@override@JsonKey(name: 'file_type') final  String fileType;
@override@JsonKey(name: 'is_top_rated') final  bool isTopRated;

/// Create a copy of DownloadRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadRecordModelCopyWith<_DownloadRecordModel> get copyWith => __$DownloadRecordModelCopyWithImpl<_DownloadRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadRecordModel&&(identical(other.wallpaperId, wallpaperId) || other.wallpaperId == wallpaperId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.downloadedAt, downloadedAt) || other.downloadedAt == downloadedAt)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.isTopRated, isTopRated) || other.isTopRated == isTopRated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,wallpaperId,imageUrl,thumbnailUrl,title,downloadedAt,fileType,isTopRated);

@override
String toString() {
  return 'DownloadRecordModel(wallpaperId: $wallpaperId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, title: $title, downloadedAt: $downloadedAt, fileType: $fileType, isTopRated: $isTopRated)';
}


}

/// @nodoc
abstract mixin class _$DownloadRecordModelCopyWith<$Res> implements $DownloadRecordModelCopyWith<$Res> {
  factory _$DownloadRecordModelCopyWith(_DownloadRecordModel value, $Res Function(_DownloadRecordModel) _then) = __$DownloadRecordModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'wallpaper_id') String wallpaperId,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String thumbnailUrl, String title,@JsonKey(name: 'downloaded_at') DateTime downloadedAt,@JsonKey(name: 'file_type') String fileType,@JsonKey(name: 'is_top_rated') bool isTopRated
});




}
/// @nodoc
class __$DownloadRecordModelCopyWithImpl<$Res>
    implements _$DownloadRecordModelCopyWith<$Res> {
  __$DownloadRecordModelCopyWithImpl(this._self, this._then);

  final _DownloadRecordModel _self;
  final $Res Function(_DownloadRecordModel) _then;

/// Create a copy of DownloadRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wallpaperId = null,Object? imageUrl = null,Object? thumbnailUrl = null,Object? title = null,Object? downloadedAt = null,Object? fileType = null,Object? isTopRated = null,}) {
  return _then(_DownloadRecordModel(
wallpaperId: null == wallpaperId ? _self.wallpaperId : wallpaperId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,downloadedAt: null == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,isTopRated: null == isTopRated ? _self.isTopRated : isTopRated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
