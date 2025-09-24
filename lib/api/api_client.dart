import 'package:api/api/custom_interceptor.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final dio = Dio(
    BaseOptions(
      //BaseOption is a default configuration setting that apply to all request made through dio instance.
      // Base option provide  common properties for all instead repeating them in every request..
      baseUrl:
          'https://jsonplaceholder.typicode.com', // root url for all request
      connectTimeout: Duration(seconds: 3),
      sendTimeout: Duration(seconds: 3),
      receiveTimeout: Duration(seconds: 3),
      persistentConnection: false,
      headers: {
        'Content-Type': 'application/json', // which content type like json ...
      },
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
      // (status == 200 ||
      //     status ==
      //         500), // This tells Dio that 404 is also a valid, non-error response.
    ),
  );

  ApiClient() {
    dio.interceptors.add(CustomInterceptor());
    // we dont need to write print statement to check log  network operation.. it will give information of every request and responses
    dio.interceptors.add(
      LogInterceptor(
        // this class is used to log network request and response details in Dio package.
        request: true, // Log the request (method, URL, headers)
        requestBody: true, // Log the request body
        responseHeader: true, // Log the response headers
        responseBody: true, // Log the response body
        error: true, // Log errors
        logPrint: (object) {
          // we can specify the print state ..if we dont it will give it interceptor error
          //
          print('%%%object: $object');
        },
      ),
    );
  }
}
