// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_metadata_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppMetadataModel {

 String get name; String get description; String get about; String get privacyPolicy; String get termsOfUse; String get androidShareLink; String get iphoneShareLink; String get contactEmail; List<CategoryModel> get categories;
/// Create a copy of AppMetadataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppMetadataModelCopyWith<AppMetadataModel> get copyWith => _$AppMetadataModelCopyWithImpl<AppMetadataModel>(this as AppMetadataModel, _$identity);

  /// Serializes this AppMetadataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppMetadataModel&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.about, about) || other.about == about)&&(identical(other.privacyPolicy, privacyPolicy) || other.privacyPolicy == privacyPolicy)&&(identical(other.termsOfUse, termsOfUse) || other.termsOfUse == termsOfUse)&&(identical(other.androidShareLink, androidShareLink) || other.androidShareLink == androidShareLink)&&(identical(other.iphoneShareLink, iphoneShareLink) || other.iphoneShareLink == iphoneShareLink)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,about,privacyPolicy,termsOfUse,androidShareLink,iphoneShareLink,contactEmail,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'AppMetadataModel(name: $name, description: $description, about: $about, privacyPolicy: $privacyPolicy, termsOfUse: $termsOfUse, androidShareLink: $androidShareLink, iphoneShareLink: $iphoneShareLink, contactEmail: $contactEmail, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $AppMetadataModelCopyWith<$Res>  {
  factory $AppMetadataModelCopyWith(AppMetadataModel value, $Res Function(AppMetadataModel) _then) = _$AppMetadataModelCopyWithImpl;
@useResult
$Res call({
 String name, String description, String about, String privacyPolicy, String termsOfUse, String androidShareLink, String iphoneShareLink, String contactEmail, List<CategoryModel> categories
});




}
/// @nodoc
class _$AppMetadataModelCopyWithImpl<$Res>
    implements $AppMetadataModelCopyWith<$Res> {
  _$AppMetadataModelCopyWithImpl(this._self, this._then);

  final AppMetadataModel _self;
  final $Res Function(AppMetadataModel) _then;

/// Create a copy of AppMetadataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? about = null,Object? privacyPolicy = null,Object? termsOfUse = null,Object? androidShareLink = null,Object? iphoneShareLink = null,Object? contactEmail = null,Object? categories = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,about: null == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String,privacyPolicy: null == privacyPolicy ? _self.privacyPolicy : privacyPolicy // ignore: cast_nullable_to_non_nullable
as String,termsOfUse: null == termsOfUse ? _self.termsOfUse : termsOfUse // ignore: cast_nullable_to_non_nullable
as String,androidShareLink: null == androidShareLink ? _self.androidShareLink : androidShareLink // ignore: cast_nullable_to_non_nullable
as String,iphoneShareLink: null == iphoneShareLink ? _self.iphoneShareLink : iphoneShareLink // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppMetadataModel].
extension AppMetadataModelPatterns on AppMetadataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppMetadataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppMetadataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppMetadataModel value)  $default,){
final _that = this;
switch (_that) {
case _AppMetadataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppMetadataModel value)?  $default,){
final _that = this;
switch (_that) {
case _AppMetadataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  String about,  String privacyPolicy,  String termsOfUse,  String androidShareLink,  String iphoneShareLink,  String contactEmail,  List<CategoryModel> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppMetadataModel() when $default != null:
return $default(_that.name,_that.description,_that.about,_that.privacyPolicy,_that.termsOfUse,_that.androidShareLink,_that.iphoneShareLink,_that.contactEmail,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  String about,  String privacyPolicy,  String termsOfUse,  String androidShareLink,  String iphoneShareLink,  String contactEmail,  List<CategoryModel> categories)  $default,) {final _that = this;
switch (_that) {
case _AppMetadataModel():
return $default(_that.name,_that.description,_that.about,_that.privacyPolicy,_that.termsOfUse,_that.androidShareLink,_that.iphoneShareLink,_that.contactEmail,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  String about,  String privacyPolicy,  String termsOfUse,  String androidShareLink,  String iphoneShareLink,  String contactEmail,  List<CategoryModel> categories)?  $default,) {final _that = this;
switch (_that) {
case _AppMetadataModel() when $default != null:
return $default(_that.name,_that.description,_that.about,_that.privacyPolicy,_that.termsOfUse,_that.androidShareLink,_that.iphoneShareLink,_that.contactEmail,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppMetadataModel extends AppMetadataModel {
  const _AppMetadataModel({required this.name, required this.description, required this.about, required this.privacyPolicy, required this.termsOfUse, required this.androidShareLink, required this.iphoneShareLink, required this.contactEmail, final  List<CategoryModel> categories = const []}): _categories = categories,super._();
  factory _AppMetadataModel.fromJson(Map<String, dynamic> json) => _$AppMetadataModelFromJson(json);

@override final  String name;
@override final  String description;
@override final  String about;
@override final  String privacyPolicy;
@override final  String termsOfUse;
@override final  String androidShareLink;
@override final  String iphoneShareLink;
@override final  String contactEmail;
 final  List<CategoryModel> _categories;
@override@JsonKey() List<CategoryModel> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of AppMetadataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppMetadataModelCopyWith<_AppMetadataModel> get copyWith => __$AppMetadataModelCopyWithImpl<_AppMetadataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppMetadataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppMetadataModel&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.about, about) || other.about == about)&&(identical(other.privacyPolicy, privacyPolicy) || other.privacyPolicy == privacyPolicy)&&(identical(other.termsOfUse, termsOfUse) || other.termsOfUse == termsOfUse)&&(identical(other.androidShareLink, androidShareLink) || other.androidShareLink == androidShareLink)&&(identical(other.iphoneShareLink, iphoneShareLink) || other.iphoneShareLink == iphoneShareLink)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,description,about,privacyPolicy,termsOfUse,androidShareLink,iphoneShareLink,contactEmail,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'AppMetadataModel(name: $name, description: $description, about: $about, privacyPolicy: $privacyPolicy, termsOfUse: $termsOfUse, androidShareLink: $androidShareLink, iphoneShareLink: $iphoneShareLink, contactEmail: $contactEmail, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$AppMetadataModelCopyWith<$Res> implements $AppMetadataModelCopyWith<$Res> {
  factory _$AppMetadataModelCopyWith(_AppMetadataModel value, $Res Function(_AppMetadataModel) _then) = __$AppMetadataModelCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, String about, String privacyPolicy, String termsOfUse, String androidShareLink, String iphoneShareLink, String contactEmail, List<CategoryModel> categories
});




}
/// @nodoc
class __$AppMetadataModelCopyWithImpl<$Res>
    implements _$AppMetadataModelCopyWith<$Res> {
  __$AppMetadataModelCopyWithImpl(this._self, this._then);

  final _AppMetadataModel _self;
  final $Res Function(_AppMetadataModel) _then;

/// Create a copy of AppMetadataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? about = null,Object? privacyPolicy = null,Object? termsOfUse = null,Object? androidShareLink = null,Object? iphoneShareLink = null,Object? contactEmail = null,Object? categories = null,}) {
  return _then(_AppMetadataModel(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,about: null == about ? _self.about : about // ignore: cast_nullable_to_non_nullable
as String,privacyPolicy: null == privacyPolicy ? _self.privacyPolicy : privacyPolicy // ignore: cast_nullable_to_non_nullable
as String,termsOfUse: null == termsOfUse ? _self.termsOfUse : termsOfUse // ignore: cast_nullable_to_non_nullable
as String,androidShareLink: null == androidShareLink ? _self.androidShareLink : androidShareLink // ignore: cast_nullable_to_non_nullable
as String,iphoneShareLink: null == iphoneShareLink ? _self.iphoneShareLink : iphoneShareLink // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryModel>,
  ));
}


}

// dart format on
