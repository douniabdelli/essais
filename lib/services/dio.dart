
import 'package:dio/dio.dart';

Dio dio() {
  Dio dio = new Dio();

  dio.options.headers['accept'] = 'Application/Json';

  // ios
  // dio.options.baseUrl = "http://localhost:8000/api/mobile";
  // android
  dio.options.baseUrl = "http://10.0.2.2:8000/api/mobile";
 //dio.options.baseUrl = "http://192.168.15.98:8000/api/mobile";
 //dio.options.baseUrl = "http://192.168.108.2:56/api/mobile";
  return dio;
}