import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request_model.freezed.dart';
part 'register_request_model.g.dart';

@freezed
abstract class RegisterRequestModel with _$RegisterRequestModel {
  const factory RegisterRequestModel({
    @JsonKey(name: 'display_name') required String displayName,
    required String email,
    required String password,
  }) = _RegisterRequestModel;

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => when(
    (displayName, email, password) => _$RegisterRequestModelToJson(
      _RegisterRequestModel(
        displayName: displayName,
        email: email,
        password: password,
      ),
    ),
  );
}
