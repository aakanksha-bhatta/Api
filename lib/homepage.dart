import 'package:api/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // we need to createPost to add this in post list ..
  List<Map<String, dynamic>> createdPost = [];
  // It create an instance of Dio for making HTTP requests
  // final Dio dio = Dio();
  final ApiClient apiClient = ApiClient();

  // it cancel ongoing request
  CancelToken cancelToken = CancelToken();

  // store the item
  List<Map> user = [];
  String errorMessage = ''; //store error
  bool isLoading = false;

  //it is used to retrieve data from a specified resource.
  // it is idempotent method because multiple identical requests will have the same effect as a single request.
  // it means that no matter how many times you apply the same GET request, the result will be the same.
  Future<void> getHttp() async {
    // set loading state and clear previous error
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      //make request with get method
      final response = await apiClient.dio.get(
        '/posts', // this is path or endpoint of url
        // it help dio how to handle http request..it is a configuration obj
        options: Options(
          // Set headers if needed (authentication tokens, etc.)
          headers: {'content-type': 'application/json', 'api-key': ''},
          receiveTimeout: const Duration(seconds: 10),
          // reponses type:- json , plain, bytes, stream,  which format ..
          //
          method: 'GET',
          receiveDataWhenStatusError:
              true, // data should be retrieve or not the if status code indicates a failed request.
        ),
        cancelToken: cancelToken, //it cancel ongoing request
      );

      // Update state with the received data

      // The API returns a list of articles directly in response.data
      setState(() {
        user = (response.data as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      });
    } on DioException catch (e) {
      // Handle Dio-specific errors
      setState(() {
        errorMessage = 'Failed to load news: ${e.message}';
      });
      print('Dio Error: $e');
    } catch (e) {
      // Handle any other errors
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
      print('Error: $e');
    } finally {
      // Always set loading to false when the request completes
      setState(() {
        isLoading = false;
      });
    }
  }

  //it is used to create a new resource or replace an existing one within a collection.
  // it is not idempotent method because multiple identical requests will create multiple resources with different IDs.
  //it can  be used as update if the resource already exists. it will create multiple resources with different IDs.
  Future<void> postHttp() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    //  here create a post data
    final postsToCreate = [
      {
        'title': 'First parallel post',
        'body': 'Body of first parallel post',
        'userId': 1,
      },
      {
        'title': 'Second parallel post',
        'body': 'Body of second parallel post',
        'userId': 2,
      },
    ];

    try {
      //here we have  create all the request of upside data
      final request = postsToCreate
          .map(
            (postData) => apiClient.dio.post(
              '/posts',
              data: postData,

              options: Options(
                receiveTimeout: Duration(seconds: 3),
                sendTimeout: Duration(seconds: 5),
                validateStatus: (status) => status! < 500,
                method: "POST",
              ),
              cancelToken: cancelToken,
              onSendProgress: (count, total) {
                double progress = (count / total);
              },
            ),
          )
          .toList();
      final responses = await Future.wait(
        // it allow you to wait the muliple future api
        request,
      ); //here wait for all the request and capture responsess

      final newposts = responses
          .map((response) => response.data as Map<String, dynamic>)
          .toList();

      setState(() {
        createdPost = newposts;
      });
    } on DioException catch (e) {
      errorMessage = 'Failed to load news: ${e.message}';
      if (e.type == DioExceptionType.sendTimeout) {
        print('Send timeout occurred');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        print('Receive timeout occurred');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // it can be used to create a new resource or replace an existing one within a id.

  Future<void> putHttp() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await apiClient.dio.put(
        '/posts/1',
        data: {
          'id': 1,
          'title': 'Updated Title via PUT',
          'body': 'This is the completely updated body content via PUT method',
          'userId': 1,
        },
        options: Options(
          // use for override the default option of dio instance
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
        ),
        cancelToken: cancelToken,
      );

      print('PUT Response: ${response.data}');
    } on DioException catch (e) {
      setState(() {
        errorMessage = 'PUT failed: ${e.message}';
      });
      print('PUT Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // it update only specific field
  //it is idempotent method because multiple identical requests will have the same effect as a single request.
  // it means that no matter how many times you apply the same PATCH request,
  // the resource will remain in the same state after the first application.
  Future<void> patchHttp() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await apiClient.dio.patch(
        'https://jsonplaceholder.typicode.com/posts/1',
        data: {'title': 'Partially Updated Title via PATCH'},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 10),
        ),
        cancelToken: cancelToken,
      );

      print('PATCH Response: ${response.data}');
    } on DioException catch (e) {
      setState(() {
        errorMessage = 'PATCH failed: ${e.message}';
      });
      print('PATCH Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is first created
    getHttp();
    postHttp();
    putHttp();
  }

  @override
  void dispose() {
    // Cancel any ongoing requests when the widget is disposed
    cancelToken.cancel('Widget disposed');
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Api Demo'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          ...createdPost.map(
            (post) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ' ${post['id']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ' ${post['title']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(' ${post['body']}'),
                ],
              ),
            ),
          ),
          if (isLoading) const CircularProgressIndicator(),

          Expanded(
            child: user.isEmpty && !isLoading
                ? const Center()
                : ListView.builder(
                    itemCount: user.length,
                    itemBuilder: (context, index) {
                      final post = user[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            post['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          leading: Text(
                            '${post['id']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: getHttp,
            tooltip: 'Create New Post',
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          // FloatingActionButton(
          //   onPressed: cancelToken.cancel,
          //   tooltip: 'Create New Post',
          //   backgroundColor: Colors.blue,
          // ),
        ],
      ),
    );
  }
}
