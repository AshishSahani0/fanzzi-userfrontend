import 'package:dio/dio.dart';
import '../error/error_handler.dart';

class BaseApiService {
  static Future<T> handleRequest<T>(
      Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      if (e is DioException) {
        throw getErrorMessage(e);
      }
      throw e.toString();
    }
  }
}