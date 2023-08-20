
import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = new Dio();

  dio.options.headers['accept'] = 'Application/Json';

  // ios
  // dio.options.baseUrl = "http://localhost:8000/api";
  // android
  //dio.options.baseUrl = "http://10.0.2.2:8000/api";

  //dio.options.baseUrl = "http://192.168.15.96:8000/api";
  dio.options.baseUrl = "http://192.168.108.2:96/api";

  return dio;
}