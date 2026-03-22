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

 String get id; String get title;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'thumbnail_url') String get thumbnailUrl;@JsonKey(name: 'video_url') String? get videoUrl;@JsonKey(name: 'is_premium') bool get isPremium;@JsonKey(name: 'category_id') String get categoryId;@JsonKey(name: 'classification_ids') List<String> get classificationIds;
/// Create a copy of WallpaperModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WallpaperModelCopyWith<WallpaperModel> get copyWith => _$WallpaperModelCopyWithImpl<WallpaperModel>(this as WallpaperModel, _$identity);

  /// Serializes this WallpaperModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WallpaperModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.classificationIds, classificationIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,thumbnailUrl,videoUrl,isPremium,categoryId,const DeepCollectionEquality().hash(classificationIds));

@override
String toString() {
  return 'WallpaperModel(id: $id, title: $title, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, isPremium: $isPremium, categoryId: $categoryId, classificationIds: $classificationIds)';
}


}

/// @nodoc
abstract mixin class $WallpaperModelCopyWith<$Res>  {
  factory $WallpaperModelCopyWith(WallpaperModel value, $Res Function(WallpaperModel) _then) = _$WallpaperModelCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'video_url') String? videoUrl,@JsonKey(name: 'is_premium') bool isPremium,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'classification_ids') List<String> classificationIds
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? imageUrl = null,Object? thumbnailUrl = null,Object? videoUrl = freezed,Object? isPremium = null,Object? categoryId = null,Object? classificationIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,classificationIds: null == classificationIds ? _self.classificationIds : classificationIds // ignore: cast_nullable_to_non_nullable
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'video_url')  String? videoUrl, @JsonKey(name: 'is_premium')  bool isPremium, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'classification_ids')  List<String> classificationIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.thumbnailUrl,_that.videoUrl,_that.isPremium,_that.categoryId,_that.classificationIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'video_url')  String? videoUrl, @JsonKey(name: 'is_premium')  bool isPremium, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'classification_ids')  List<String> classificationIds)  $default,) {final _that = this;
switch (_that) {
case _WallpaperModel():
return $default(_that.id,_that.title,_that.imageUrl,_that.thumbnailUrl,_that.videoUrl,_that.isPremium,_that.categoryId,_that.classificationIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'video_url')  String? videoUrl, @JsonKey(name: 'is_premium')  bool isPremium, @JsonKey(name: 'category_id')  String categoryId, @JsonKey(name: 'classification_ids')  List<String> classificationIds)?  $default,) {final _that = this;
switch (_that) {
case _WallpaperModel() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.thumbnailUrl,_that.videoUrl,_that.isPremium,_that.categoryId,_that.classificationIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WallpaperModel extends WallpaperModel {
  const _WallpaperModel({required this.id, required this.title, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'thumbnail_url') required this.thumbnailUrl, @JsonKey(name: 'video_url') this.videoUrl, @JsonKey(name: 'is_premium') required this.isPremium, @JsonKey(name: 'category_id') required this.categoryId, @JsonKey(name: 'classification_ids') final  List<String> classificationIds = const []}): _classificationIds = classificationIds,super._();
  factory _WallpaperModel.fromJson(Map<String, dynamic> json) => _$WallpaperModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'thumbnail_url') final  String thumbnailUrl;
@override@JsonKey(name: 'video_url') final  String? videoUrl;
@override@JsonKey(name: 'is_premium') final  bool isPremium;
@override@JsonKey(name: 'category_id') final  String categoryId;
 final  List<String> _classificationIds;
@override@JsonKey(name: 'classification_ids') List<String> get classificationIds {
  if (_classificationIds is EqualUnmodifiableListView) return _classificationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classificationIds);
}


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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WallpaperModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._classificationIds, _classificationIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,thumbnailUrl,videoUrl,isPremium,categoryId,const DeepCollectionEquality().hash(_classificationIds));

@override
String toString() {
  return 'WallpaperModel(id: $id, title: $title, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, isPremium: $isPremium, categoryId: $categoryId, classificationIds: $classificationIds)';
}


}

/// @nodoc
abstract mixin class _$WallpaperModelCopyWith<$Res> implements $WallpaperModelCopyWith<$Res> {
  factory _$WallpaperModelCopyWith(_WallpaperModel value, $Res Function(_WallpaperModel) _then) = __$WallpaperModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'video_url') String? videoUrl,@JsonKey(name: 'is_premium') bool isPremium,@JsonKey(name: 'category_id') String categoryId,@JsonKey(name: 'classification_ids') List<String> classificationIds
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? imageUrl = null,Object? thumbnailUrl = null,Object? videoUrl = freezed,Object? isPremium = null,Object? categoryId = null,Object? classificationIds = null,}) {
  return _then(_WallpaperModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,videoUrl: freezed == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String?,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,classificationIds: null == classificationIds ? _self._classificationIds : classificationIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
