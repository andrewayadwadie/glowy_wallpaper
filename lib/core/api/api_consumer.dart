import 'package:dio/dio.dart';
import '../config/env.dart';

class DioConsumer {
  final Dio dio;

  DioConsumer(this.dio) {
    dio.options.baseUrl = Env.apiBaseUrl;
    dio.options.responseType = ResponseType.json;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }
}
