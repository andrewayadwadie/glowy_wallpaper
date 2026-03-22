import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/subscription_status_model.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) =
      _AuthRemoteDataSource;

  @POST('/auth/login')
  Future<AuthResponseModel> login(@Body() LoginRequestModel request);

  @POST('/auth/register')
  Future<AuthResponseModel> register(@Body() RegisterRequestModel request);

  @POST('/auth/logout')
  Future<void> logout();

  @GET('/subscription/status')
  Future<SubscriptionStatusModel> getSubscriptionStatus();

  @POST('/subscription/unsubscribe')
  Future<void> unsubscribe();
}
