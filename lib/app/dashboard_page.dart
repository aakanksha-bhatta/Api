import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isDarkMode;
  List<String> _imageUrls = [];
  bool _isLoading = false;

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    debugPrint('initState: Widget has been initialized');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness = Theme.of(context).brightness;
      setState(() {
        isDarkMode = brightness == Brightness.dark;
      });
      _fetchImages(); // Fetch images after first frame
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    debugPrint('didChangeDependencies changed');
    setState(() {
      isDarkMode = brightness == Brightness.dark;
    });
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.themeNotifier != widget.themeNotifier) {
      debugPrint('ThemeNotifier instance changed - refetching images');
      _fetchImages(); // Refetch images if themeNotifier changes
    }
  }

  Future<void> _fetchImages() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _imageUrls = []; // Clear previous images
    });

    try {
      final response = await _dio.get(
        'https://newsapi.org/v2/everything?q=tesla&from=2025-08-25&sortBy=publishedAt&apiKey=c1388405f46a4cddad56cc380a96fd65',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final articles = data['articles'] as List?;

        if (articles != null) {
          // Extract only image URLs from articles
          final urls = articles
              .where((article) => article['urlToImage'] != null)
              .map((article) => article['urlToImage'].toString())
              .toList();

          setState(() {
            _imageUrls = urls;
          });
          debugPrint('Fetched ${_imageUrls.length} images');
        }
      }
    } catch (e) {
      debugPrint('Error fetching images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('My App', style: theme.textTheme.displayMedium),
      ),
      body: Column(
        children: [
          // Theme Section
          Column(
            children: [
              SizedBox(height: 20),
              Text(
                isDark ? 'This is Dark Mode' : 'This is Light Mode',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.themeNotifier.value = isDark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                    },
                    child: Text('Switch Theme'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fetchImages,
                    child: Text('Fetch Images'),
                  ),
                ],
              ),
            ],
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _imageUrls.isEmpty
                ? Center(child: Text('No images found'))
                : ListView.builder(
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(8),
                        child: Image.network(
                          _imageUrls[index],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image, size: 50),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
