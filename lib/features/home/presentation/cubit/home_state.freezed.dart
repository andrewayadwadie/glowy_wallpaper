// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 Status get categoriesStatus; List<CategoryEntity> get categories; int get selectedCategoryIndex; Status get contentStatus; List<WallpaperEntity> get wallpapers; List<ClassificationEntity> get classifications; int get currentPage; bool get hasReachedEnd; bool get isLoadingMore; AppMetadataEntity? get appMetadata; String? get errorMessage;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.categoriesStatus, categoriesStatus) || other.categoriesStatus == categoriesStatus)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.selectedCategoryIndex, selectedCategoryIndex) || other.selectedCategoryIndex == selectedCategoryIndex)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&const DeepCollectionEquality().equals(other.wallpapers, wallpapers)&&const DeepCollectionEquality().equals(other.classifications, classifications)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.appMetadata, appMetadata) || other.appMetadata == appMetadata)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,categoriesStatus,const DeepCollectionEquality().hash(categories),selectedCategoryIndex,contentStatus,const DeepCollectionEquality().hash(wallpapers),const DeepCollectionEquality().hash(classifications),currentPage,hasReachedEnd,isLoadingMore,appMetadata,errorMessage);

@override
String toString() {
  return 'HomeState(categoriesStatus: $categoriesStatus, categories: $categories, selectedCategoryIndex: $selectedCategoryIndex, contentStatus: $contentStatus, wallpapers: $wallpapers, classifications: $classifications, currentPage: $currentPage, hasReachedEnd: $hasReachedEnd, isLoadingMore: $isLoadingMore, appMetadata: $appMetadata, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 Status categoriesStatus, List<CategoryEntity> categories, int selectedCategoryIndex, Status contentStatus, List<WallpaperEntity> wallpapers, List<ClassificationEntity> classifications, int currentPage, bool hasReachedEnd, bool isLoadingMore, AppMetadataEntity? appMetadata, String? errorMessage
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoriesStatus = null,Object? categories = null,Object? selectedCategoryIndex = null,Object? contentStatus = null,Object? wallpapers = null,Object? classifications = null,Object? currentPage = null,Object? hasReachedEnd = null,Object? isLoadingMore = null,Object? appMetadata = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
categoriesStatus: null == categoriesStatus ? _self.categoriesStatus : categoriesStatus // ignore: cast_nullable_to_non_nullable
as Status,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryEntity>,selectedCategoryIndex: null == selectedCategoryIndex ? _self.selectedCategoryIndex : selectedCategoryIndex // ignore: cast_nullable_to_non_nullable
as int,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as Status,wallpapers: null == wallpapers ? _self.wallpapers : wallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,classifications: null == classifications ? _self.classifications : classifications // ignore: cast_nullable_to_non_nullable
as List<ClassificationEntity>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,appMetadata: freezed == appMetadata ? _self.appMetadata : appMetadata // ignore: cast_nullable_to_non_nullable
as AppMetadataEntity?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Status categoriesStatus,  List<CategoryEntity> categories,  int selectedCategoryIndex,  Status contentStatus,  List<WallpaperEntity> wallpapers,  List<ClassificationEntity> classifications,  int currentPage,  bool hasReachedEnd,  bool isLoadingMore,  AppMetadataEntity? appMetadata,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.categoriesStatus,_that.categories,_that.selectedCategoryIndex,_that.contentStatus,_that.wallpapers,_that.classifications,_that.currentPage,_that.hasReachedEnd,_that.isLoadingMore,_that.appMetadata,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Status categoriesStatus,  List<CategoryEntity> categories,  int selectedCategoryIndex,  Status contentStatus,  List<WallpaperEntity> wallpapers,  List<ClassificationEntity> classifications,  int currentPage,  bool hasReachedEnd,  bool isLoadingMore,  AppMetadataEntity? appMetadata,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.categoriesStatus,_that.categories,_that.selectedCategoryIndex,_that.contentStatus,_that.wallpapers,_that.classifications,_that.currentPage,_that.hasReachedEnd,_that.isLoadingMore,_that.appMetadata,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Status categoriesStatus,  List<CategoryEntity> categories,  int selectedCategoryIndex,  Status contentStatus,  List<WallpaperEntity> wallpapers,  List<ClassificationEntity> classifications,  int currentPage,  bool hasReachedEnd,  bool isLoadingMore,  AppMetadataEntity? appMetadata,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.categoriesStatus,_that.categories,_that.selectedCategoryIndex,_that.contentStatus,_that.wallpapers,_that.classifications,_that.currentPage,_that.hasReachedEnd,_that.isLoadingMore,_that.appMetadata,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.categoriesStatus = Status.loading, final  List<CategoryEntity> categories = const [], this.selectedCategoryIndex = 0, this.contentStatus = Status.loading, final  List<WallpaperEntity> wallpapers = const [], final  List<ClassificationEntity> classifications = const [], this.currentPage = 1, this.hasReachedEnd = false, this.isLoadingMore = false, this.appMetadata, this.errorMessage}): _categories = categories,_wallpapers = wallpapers,_classifications = classifications;
  

@override@JsonKey() final  Status categoriesStatus;
 final  List<CategoryEntity> _categories;
@override@JsonKey() List<CategoryEntity> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  int selectedCategoryIndex;
@override@JsonKey() final  Status contentStatus;
 final  List<WallpaperEntity> _wallpapers;
@override@JsonKey() List<WallpaperEntity> get wallpapers {
  if (_wallpapers is EqualUnmodifiableListView) return _wallpapers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallpapers);
}

 final  List<ClassificationEntity> _classifications;
@override@JsonKey() List<ClassificationEntity> get classifications {
  if (_classifications is EqualUnmodifiableListView) return _classifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_classifications);
}

@override@JsonKey() final  int currentPage;
@override@JsonKey() final  bool hasReachedEnd;
@override@JsonKey() final  bool isLoadingMore;
@override final  AppMetadataEntity? appMetadata;
@override final  String? errorMessage;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.categoriesStatus, categoriesStatus) || other.categoriesStatus == categoriesStatus)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.selectedCategoryIndex, selectedCategoryIndex) || other.selectedCategoryIndex == selectedCategoryIndex)&&(identical(other.contentStatus, contentStatus) || other.contentStatus == contentStatus)&&const DeepCollectionEquality().equals(other._wallpapers, _wallpapers)&&const DeepCollectionEquality().equals(other._classifications, _classifications)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.appMetadata, appMetadata) || other.appMetadata == appMetadata)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,categoriesStatus,const DeepCollectionEquality().hash(_categories),selectedCategoryIndex,contentStatus,const DeepCollectionEquality().hash(_wallpapers),const DeepCollectionEquality().hash(_classifications),currentPage,hasReachedEnd,isLoadingMore,appMetadata,errorMessage);

@override
String toString() {
  return 'HomeState(categoriesStatus: $categoriesStatus, categories: $categories, selectedCategoryIndex: $selectedCategoryIndex, contentStatus: $contentStatus, wallpapers: $wallpapers, classifications: $classifications, currentPage: $currentPage, hasReachedEnd: $hasReachedEnd, isLoadingMore: $isLoadingMore, appMetadata: $appMetadata, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 Status categoriesStatus, List<CategoryEntity> categories, int selectedCategoryIndex, Status contentStatus, List<WallpaperEntity> wallpapers, List<ClassificationEntity> classifications, int currentPage, bool hasReachedEnd, bool isLoadingMore, AppMetadataEntity? appMetadata, String? errorMessage
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoriesStatus = null,Object? categories = null,Object? selectedCategoryIndex = null,Object? contentStatus = null,Object? wallpapers = null,Object? classifications = null,Object? currentPage = null,Object? hasReachedEnd = null,Object? isLoadingMore = null,Object? appMetadata = freezed,Object? errorMessage = freezed,}) {
  return _then(_HomeState(
categoriesStatus: null == categoriesStatus ? _self.categoriesStatus : categoriesStatus // ignore: cast_nullable_to_non_nullable
as Status,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<CategoryEntity>,selectedCategoryIndex: null == selectedCategoryIndex ? _self.selectedCategoryIndex : selectedCategoryIndex // ignore: cast_nullable_to_non_nullable
as int,contentStatus: null == contentStatus ? _self.contentStatus : contentStatus // ignore: cast_nullable_to_non_nullable
as Status,wallpapers: null == wallpapers ? _self._wallpapers : wallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,classifications: null == classifications ? _self._classifications : classifications // ignore: cast_nullable_to_non_nullable
as List<ClassificationEntity>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,appMetadata: freezed == appMetadata ? _self.appMetadata : appMetadata // ignore: cast_nullable_to_non_nullable
as AppMetadataEntity?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
