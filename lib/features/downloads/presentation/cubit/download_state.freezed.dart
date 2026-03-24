// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DownloadState {

 Status get historyStatus; List<DownloadRecordEntity> get history; bool get isDownloading; double get downloadProgress; String? get errorMessage; String? get successMessage;
/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadStateCopyWith<DownloadState> get copyWith => _$DownloadStateCopyWithImpl<DownloadState>(this as DownloadState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadState&&(identical(other.historyStatus, historyStatus) || other.historyStatus == historyStatus)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,historyStatus,const DeepCollectionEquality().hash(history),isDownloading,downloadProgress,errorMessage,successMessage);

@override
String toString() {
  return 'DownloadState(historyStatus: $historyStatus, history: $history, isDownloading: $isDownloading, downloadProgress: $downloadProgress, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class $DownloadStateCopyWith<$Res>  {
  factory $DownloadStateCopyWith(DownloadState value, $Res Function(DownloadState) _then) = _$DownloadStateCopyWithImpl;
@useResult
$Res call({
 Status historyStatus, List<DownloadRecordEntity> history, bool isDownloading, double downloadProgress, String? errorMessage, String? successMessage
});




}
/// @nodoc
class _$DownloadStateCopyWithImpl<$Res>
    implements $DownloadStateCopyWith<$Res> {
  _$DownloadStateCopyWithImpl(this._self, this._then);

  final DownloadState _self;
  final $Res Function(DownloadState) _then;

/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? historyStatus = null,Object? history = null,Object? isDownloading = null,Object? downloadProgress = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_self.copyWith(
historyStatus: null == historyStatus ? _self.historyStatus : historyStatus // ignore: cast_nullable_to_non_nullable
as Status,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<DownloadRecordEntity>,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadState].
extension DownloadStatePatterns on DownloadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadState value)  $default,){
final _that = this;
switch (_that) {
case _DownloadState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadState value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Status historyStatus,  List<DownloadRecordEntity> history,  bool isDownloading,  double downloadProgress,  String? errorMessage,  String? successMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
return $default(_that.historyStatus,_that.history,_that.isDownloading,_that.downloadProgress,_that.errorMessage,_that.successMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Status historyStatus,  List<DownloadRecordEntity> history,  bool isDownloading,  double downloadProgress,  String? errorMessage,  String? successMessage)  $default,) {final _that = this;
switch (_that) {
case _DownloadState():
return $default(_that.historyStatus,_that.history,_that.isDownloading,_that.downloadProgress,_that.errorMessage,_that.successMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Status historyStatus,  List<DownloadRecordEntity> history,  bool isDownloading,  double downloadProgress,  String? errorMessage,  String? successMessage)?  $default,) {final _that = this;
switch (_that) {
case _DownloadState() when $default != null:
return $default(_that.historyStatus,_that.history,_that.isDownloading,_that.downloadProgress,_that.errorMessage,_that.successMessage);case _:
  return null;

}
}

}

/// @nodoc


class _DownloadState implements DownloadState {
  const _DownloadState({this.historyStatus = Status.loading, final  List<DownloadRecordEntity> history = const [], this.isDownloading = false, this.downloadProgress = 0.0, this.errorMessage, this.successMessage}): _history = history;
  

@override@JsonKey() final  Status historyStatus;
 final  List<DownloadRecordEntity> _history;
@override@JsonKey() List<DownloadRecordEntity> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  bool isDownloading;
@override@JsonKey() final  double downloadProgress;
@override final  String? errorMessage;
@override final  String? successMessage;

/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadStateCopyWith<_DownloadState> get copyWith => __$DownloadStateCopyWithImpl<_DownloadState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadState&&(identical(other.historyStatus, historyStatus) || other.historyStatus == historyStatus)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.isDownloading, isDownloading) || other.isDownloading == isDownloading)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.successMessage, successMessage) || other.successMessage == successMessage));
}


@override
int get hashCode => Object.hash(runtimeType,historyStatus,const DeepCollectionEquality().hash(_history),isDownloading,downloadProgress,errorMessage,successMessage);

@override
String toString() {
  return 'DownloadState(historyStatus: $historyStatus, history: $history, isDownloading: $isDownloading, downloadProgress: $downloadProgress, errorMessage: $errorMessage, successMessage: $successMessage)';
}


}

/// @nodoc
abstract mixin class _$DownloadStateCopyWith<$Res> implements $DownloadStateCopyWith<$Res> {
  factory _$DownloadStateCopyWith(_DownloadState value, $Res Function(_DownloadState) _then) = __$DownloadStateCopyWithImpl;
@override @useResult
$Res call({
 Status historyStatus, List<DownloadRecordEntity> history, bool isDownloading, double downloadProgress, String? errorMessage, String? successMessage
});




}
/// @nodoc
class __$DownloadStateCopyWithImpl<$Res>
    implements _$DownloadStateCopyWith<$Res> {
  __$DownloadStateCopyWithImpl(this._self, this._then);

  final _DownloadState _self;
  final $Res Function(_DownloadState) _then;

/// Create a copy of DownloadState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? historyStatus = null,Object? history = null,Object? isDownloading = null,Object? downloadProgress = null,Object? errorMessage = freezed,Object? successMessage = freezed,}) {
  return _then(_DownloadState(
historyStatus: null == historyStatus ? _self.historyStatus : historyStatus // ignore: cast_nullable_to_non_nullable
as Status,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<DownloadRecordEntity>,isDownloading: null == isDownloading ? _self.isDownloading : isDownloading // ignore: cast_nullable_to_non_nullable
as bool,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,successMessage: freezed == successMessage ? _self.successMessage : successMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
