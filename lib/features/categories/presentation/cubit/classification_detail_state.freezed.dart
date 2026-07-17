// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classification_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClassificationDetailState {

 ClassificationEntity get classification; Status get status; List<WallpaperEntity> get wallpapers; int get currentPage; bool get hasReachedEnd; bool get isLoadingMore; String? get errorMessage;
/// Create a copy of ClassificationDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassificationDetailStateCopyWith<ClassificationDetailState> get copyWith => _$ClassificationDetailStateCopyWithImpl<ClassificationDetailState>(this as ClassificationDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassificationDetailState&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.wallpapers, wallpapers)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,classification,status,const DeepCollectionEquality().hash(wallpapers),currentPage,hasReachedEnd,isLoadingMore,errorMessage);

@override
String toString() {
  return 'ClassificationDetailState(classification: $classification, status: $status, wallpapers: $wallpapers, currentPage: $currentPage, hasReachedEnd: $hasReachedEnd, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $ClassificationDetailStateCopyWith<$Res>  {
  factory $ClassificationDetailStateCopyWith(ClassificationDetailState value, $Res Function(ClassificationDetailState) _then) = _$ClassificationDetailStateCopyWithImpl;
@useResult
$Res call({
 ClassificationEntity classification, Status status, List<WallpaperEntity> wallpapers, int currentPage, bool hasReachedEnd, bool isLoadingMore, String? errorMessage
});




}
/// @nodoc
class _$ClassificationDetailStateCopyWithImpl<$Res>
    implements $ClassificationDetailStateCopyWith<$Res> {
  _$ClassificationDetailStateCopyWithImpl(this._self, this._then);

  final ClassificationDetailState _self;
  final $Res Function(ClassificationDetailState) _then;

/// Create a copy of ClassificationDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? classification = null,Object? status = null,Object? wallpapers = null,Object? currentPage = null,Object? hasReachedEnd = null,Object? isLoadingMore = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as ClassificationEntity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,wallpapers: null == wallpapers ? _self.wallpapers : wallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassificationDetailState].
extension ClassificationDetailStatePatterns on ClassificationDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassificationDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassificationDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassificationDetailState value)  $default,){
final _that = this;
switch (_that) {
case _ClassificationDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassificationDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _ClassificationDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ClassificationEntity classification,  Status status,  List<WallpaperEntity> wallpapers,  int currentPage,  bool hasReachedEnd,  bool isLoadingMore,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassificationDetailState() when $default != null:
return $default(_that.classification,_that.status,_that.wallpapers,_that.currentPage,_that.hasReachedEnd,_that.isLoadingMore,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ClassificationEntity classification,  Status status,  List<WallpaperEntity> wallpapers,  int currentPage,  bool hasReachedEnd,  bool isLoadingMore,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _ClassificationDetailState():
return $default(_that.classification,_that.status,_that.wallpapers,_that.currentPage,_that.hasReachedEnd,_that.isLoadingMore,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ClassificationEntity classification,  Status status,  List<WallpaperEntity> wallpapers,  int currentPage,  bool hasReachedEnd,  bool isLoadingMore,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _ClassificationDetailState() when $default != null:
return $default(_that.classification,_that.status,_that.wallpapers,_that.currentPage,_that.hasReachedEnd,_that.isLoadingMore,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _ClassificationDetailState implements ClassificationDetailState {
  const _ClassificationDetailState({required this.classification, this.status = Status.loading, final  List<WallpaperEntity> wallpapers = const [], this.currentPage = 1, this.hasReachedEnd = false, this.isLoadingMore = false, this.errorMessage}): _wallpapers = wallpapers;
  

@override final  ClassificationEntity classification;
@override@JsonKey() final  Status status;
 final  List<WallpaperEntity> _wallpapers;
@override@JsonKey() List<WallpaperEntity> get wallpapers {
  if (_wallpapers is EqualUnmodifiableListView) return _wallpapers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wallpapers);
}

@override@JsonKey() final  int currentPage;
@override@JsonKey() final  bool hasReachedEnd;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? errorMessage;

/// Create a copy of ClassificationDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassificationDetailStateCopyWith<_ClassificationDetailState> get copyWith => __$ClassificationDetailStateCopyWithImpl<_ClassificationDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassificationDetailState&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._wallpapers, _wallpapers)&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.hasReachedEnd, hasReachedEnd) || other.hasReachedEnd == hasReachedEnd)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,classification,status,const DeepCollectionEquality().hash(_wallpapers),currentPage,hasReachedEnd,isLoadingMore,errorMessage);

@override
String toString() {
  return 'ClassificationDetailState(classification: $classification, status: $status, wallpapers: $wallpapers, currentPage: $currentPage, hasReachedEnd: $hasReachedEnd, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ClassificationDetailStateCopyWith<$Res> implements $ClassificationDetailStateCopyWith<$Res> {
  factory _$ClassificationDetailStateCopyWith(_ClassificationDetailState value, $Res Function(_ClassificationDetailState) _then) = __$ClassificationDetailStateCopyWithImpl;
@override @useResult
$Res call({
 ClassificationEntity classification, Status status, List<WallpaperEntity> wallpapers, int currentPage, bool hasReachedEnd, bool isLoadingMore, String? errorMessage
});




}
/// @nodoc
class __$ClassificationDetailStateCopyWithImpl<$Res>
    implements _$ClassificationDetailStateCopyWith<$Res> {
  __$ClassificationDetailStateCopyWithImpl(this._self, this._then);

  final _ClassificationDetailState _self;
  final $Res Function(_ClassificationDetailState) _then;

/// Create a copy of ClassificationDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? classification = null,Object? status = null,Object? wallpapers = null,Object? currentPage = null,Object? hasReachedEnd = null,Object? isLoadingMore = null,Object? errorMessage = freezed,}) {
  return _then(_ClassificationDetailState(
classification: null == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as ClassificationEntity,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Status,wallpapers: null == wallpapers ? _self._wallpapers : wallpapers // ignore: cast_nullable_to_non_nullable
as List<WallpaperEntity>,currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as int,hasReachedEnd: null == hasReachedEnd ? _self.hasReachedEnd : hasReachedEnd // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
