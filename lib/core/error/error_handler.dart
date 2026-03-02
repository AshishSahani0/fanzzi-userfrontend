import 'package:dio/dio.dart';

String getErrorMessage(DioException e) {
  final data = e.response?.data;

  if (data is Map<String, dynamic>) {
    return data["message"] ?? "Something went wrong";
  }

  if (data is String) {
    return data;
  }

  if (e.type == DioExceptionType.connectionTimeout) {
    return "Connection timeout";
  }

  if (e.type == DioExceptionType.receiveTimeout) {
    return "Server not responding";
  }

  return "Server error. Please try again.";
}