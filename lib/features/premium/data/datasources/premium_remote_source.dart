import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:glowy_wallpaper/features/premium/data/models/subscription_status_response_model.dart';
import 'package:glowy_wallpaper/features/premium/data/models/subscription_verify_response_model.dart';

part 'premium_remote_source.g.dart';

@RestApi()
abstract class PremiumRemoteSource {
  factory PremiumRemoteSource(Dio dio, {String baseUrl}) = _PremiumRemoteSource;

  @POST('/api/v1/subscription/verify')
  Future<HttpResponse<SubscriptionVerifyResponseModel>> verifySubscription(
    @Body() Map<String, dynamic> body,
  );

  @GET('/api/v1/subscription/status')
  Future<HttpResponse<SubscriptionStatusResponseModel>> getSubscriptionStatus();

  @GET('/api/v1/subscription/refresh')
  Future<HttpResponse<SubscriptionStatusResponseModel>> refreshSubscription();
}
