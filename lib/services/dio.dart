
import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = new Dio();
  dio.options.headers['accept'] = 'Application/Json';
  dio.options.baseUrl = "http://192.168.108.2:56/api";
  return dio;
}