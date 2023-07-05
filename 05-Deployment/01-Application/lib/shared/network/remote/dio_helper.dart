import 'dart:io';

import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;

  //TODO :: BaseURL
  static init() {
    String baseUrl = 'https://753c-41-45-117-64.ngrok-free.app';

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        responseType: ResponseType.plain,
        headers: {
          'Content-Type': 'multipart/form-data',

        },
        validateStatus: (status) {
          return (status! <= 505);
        },
      ),
    );
  }


  static Future<Response> postData({
    required String url,
    required FormData data,
  }) {
    dio.options.headers = {
      "Content-Type": "multipart/form-data",
    };

    print(data.fields);
    print(url);

    return dio.post(url,data: data);
  }

}