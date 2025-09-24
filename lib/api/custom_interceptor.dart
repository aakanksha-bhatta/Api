import 'package:dio/dio.dart';

class CustomInterceptor extends Interceptor {
  // call before request is sent
  // Here you can modify the request options, adding headers, etc.
  // we can also perform actions like logging or authentication.
  @override
  //use for reusing code, avoid repeating code, and maintain consistency across multiple requests.
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer your_access_token';
    print(options.uri);
    print(options.baseUrl);
    print(options.path);
    print(options.method);
    print(options.headers);
    options.connectTimeout = const Duration(seconds: 5);
    // Set a custom connection timeout for each request (5 seconds)
    return handler.next(options);
    // continue with the request
  }

  // This method is called when the response is received from the server before it passed to app
  // Here you can inspect or modify the response data.
  // You can also handle specific status codes or errors.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(response.statusCode);
    print(response.data);
    if (response.requestOptions.method == 'PUT') {
      print('PUT Response: ${response.data}');
    } else if (response.requestOptions.method == 'PATCH') {
      print('PATCH Response: ${response.data}');
    }

    return handler.next(response); // continue with the response
  }

  // This method is called when an error occurs during the request.
  // Here you can handle errors, log them, or perform retries.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    //dio exception is error type thrown  by dio package,
    // it provides detailed information about the error that occurred during an HTTP request.
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        print('Connection Timeout Error');
        break;
      case DioExceptionType.sendTimeout:
        print('Send Timeout Error');
        break;
      case DioExceptionType.receiveTimeout:
        print('Receive Timeout Error');
        break;
      case DioExceptionType.badResponse:
        print('Bad Response Error: ${err.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        print('Request Cancelled');
        break;
      case DioExceptionType.connectionError:
        print('Connection Error');
        break;
      case DioExceptionType.badCertificate:
        print('Bad Certificate Error');
        break;
      case DioExceptionType.unknown:
        print('Unknown Error: ${err.message}');
        break;
    }
    print(err.message);
    return handler.next(err); // continue with the error
  }
}
// CustomInterceptor class is used to intercept and modify HTTP requests and responses in a Dio instance.