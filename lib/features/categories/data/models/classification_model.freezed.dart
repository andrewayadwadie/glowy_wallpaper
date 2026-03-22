// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClassificationModel {

 String get id; String get name;@JsonKey(name: 'thumbnail_url') String get thumbnailUrl;@JsonKey(name: 'wallpaper_count') int get wallpaperCount;
/// Create a copy of ClassificationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassificationModelCopyWith<ClassificationModel> get copyWith => _$ClassificationModelCopyWithImpl<ClassificationModel>(this as ClassificationModel, _$identity);

  /// Serializes this ClassificationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.wallpaperCount, wallpaperCount) || other.wallpaperCount == wallpaperCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,thumbnailUrl,wallpaperCount);

@override
String toString() {
  return 'ClassificationModel(id: $id, name: $name, thumbnailUrl: $thumbnailUrl, wallpaperCount: $wallpaperCount)';
}


}

/// @nodoc
abstract mixin class $ClassificationModelCopyWith<$Res>  {
  factory $ClassificationModelCopyWith(ClassificationModel value, $Res Function(ClassificationModel) _then) = _$ClassificationModelCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'wallpaper_count') int wallpaperCount
});




}
/// @nodoc
class _$ClassificationModelCopyWithImpl<$Res>
    implements $ClassificationModelCopyWith<$Res> {
  _$ClassificationModelCopyWithImpl(this._self, this._then);

  final ClassificationModel _self;
  final $Res Function(ClassificationModel) _then;

/// Create a copy of ClassificationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? thumbnailUrl = null,Object? wallpaperCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,wallpaperCount: null == wallpaperCount ? _self.wallpaperCount : wallpaperCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassificationModel].
extension ClassificationModelPatterns on ClassificationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassificationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassificationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassificationModel value)  $default,){
final _that = this;
switch (_that) {
case _ClassificationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassificationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClassificationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'wallpaper_count')  int wallpaperCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassificationModel() when $default != null:
return $default(_that.id,_that.name,_that.thumbnailUrl,_that.wallpaperCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'wallpaper_count')  int wallpaperCount)  $default,) {final _that = this;
switch (_that) {
case _ClassificationModel():
return $default(_that.id,_that.name,_that.thumbnailUrl,_that.wallpaperCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'thumbnail_url')  String thumbnailUrl, @JsonKey(name: 'wallpaper_count')  int wallpaperCount)?  $default,) {final _that = this;
switch (_that) {
case _ClassificationModel() when $default != null:
return $default(_that.id,_that.name,_that.thumbnailUrl,_that.wallpaperCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClassificationModel extends ClassificationModel {
  const _ClassificationModel({required this.id, required this.name, @JsonKey(name: 'thumbnail_url') required this.thumbnailUrl, @JsonKey(name: 'wallpaper_count') required this.wallpaperCount}): super._();
  factory _ClassificationModel.fromJson(Map<String, dynamic> json) => _$ClassificationModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'thumbnail_url') final  String thumbnailUrl;
@override@JsonKey(name: 'wallpaper_count') final  int wallpaperCount;

/// Create a copy of ClassificationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassificationModelCopyWith<_ClassificationModel> get copyWith => __$ClassificationModelCopyWithImpl<_ClassificationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClassificationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassificationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.wallpaperCount, wallpaperCount) || other.wallpaperCount == wallpaperCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,thumbnailUrl,wallpaperCount);

@override
String toString() {
  return 'ClassificationModel(id: $id, name: $name, thumbnailUrl: $thumbnailUrl, wallpaperCount: $wallpaperCount)';
}


}

/// @nodoc
abstract mixin class _$ClassificationModelCopyWith<$Res> implements $ClassificationModelCopyWith<$Res> {
  factory _$ClassificationModelCopyWith(_ClassificationModel value, $Res Function(_ClassificationModel) _then) = __$ClassificationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'thumbnail_url') String thumbnailUrl,@JsonKey(name: 'wallpaper_count') int wallpaperCount
});




}
/// @nodoc
class __$ClassificationModelCopyWithImpl<$Res>
    implements _$ClassificationModelCopyWith<$Res> {
  __$ClassificationModelCopyWithImpl(this._self, this._then);

  final _ClassificationModel _self;
  final $Res Function(_ClassificationModel) _then;

/// Create a copy of ClassificationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? thumbnailUrl = null,Object? wallpaperCount = null,}) {
  return _then(_ClassificationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,wallpaperCount: null == wallpaperCount ? _self.wallpaperCount : wallpaperCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
