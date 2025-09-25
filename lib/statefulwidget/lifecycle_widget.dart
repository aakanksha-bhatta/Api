import 'package:api/statefulwidget/second_page.dart';
import 'package:flutter/material.dart';

class LifecycleWidget extends StatefulWidget {
  //statefulwidget is blueprint which is immutable
  final String title;
  const LifecycleWidget({super.key, required this.title});

  // createState is starting point which creates the mutable State object associated with StatefulWidget.
  // It is called only once when widget is inserted into widget tree.
  // Without this we cannot manage any changes in UI.
  // It is responsible for holding the state of the widget and providing the build method to create
  @override
  State<LifecycleWidget> createState() => _LifecycleWidgetState();
}

class _LifecycleWidgetState extends State<LifecycleWidget> {
  int _counter = 0;
  String _message = 'Initial message';

  // it is first method which is called only once when the state object is created.
  // It is used for initializing data or state variables, set up one-time listeners, or perform any setup work that needs to be done only once.
  @override
  void initState() {
    super
        .initState(); // always call first. it ensure parent class is called first
    print('initState called');
    _message =
        'Widget initialized'; // here we initialize message when widget is created
  }

  // This method is called when the dependencies of the State object change.
  // it is called right after initState whenever dependencies change.
  // it can be use for theme, provider, localization changes. it can be called multiple times.
  // here it called when we need to store data or that logic depends on context/inherited widgets
  // it only use when we need to react or store theme ... logics
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //final theme = Theme.of(context); // like this we can access context(media query, provider, localization)
    print('didChangeDependencies called');
  }

  // it is responsible for constructing or rebuilding the UI of the widget tree.
  // It is called every-time whenever widget needs to be rendered or updated. it also called multiple times.
  // here we define how the UI should look based on the current state of the widget.
  // we can also call theme or media query when we only read those values.

  @override
  Widget build(BuildContext context) {
    // here we can call theme .. if we only read those values
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} - Counter: $_counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text(
              'Counter: $_counter',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateMessage,
              child: Text('Update Message'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPage()),
                );
              },
              child: Text('Go to Second Page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  // It is Called whenever the old widget configuration changes into new .
  // when a parent widget rebuild and create a new instance of the widget.
  @override
  void didUpdateWidget(LifecycleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.title != widget.title) {
      print('Title has changed from ${oldWidget.title} to ${widget.title}');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _message = 'Counter incremented to $_counter';
    });
  }

  void _updateMessage() {
    setState(() {
      _message = 'Message updated at ${DateTime.now().toString()}';
    });
  }

  // it called when widget is removed/cleanup for temporarily from widget tree . it can still be reused later
  // it can be called multiple times . it can be used in tap bar, navigator, pageview..
  @override
  void deactivate() {
    super.deactivate();
    print('deactivate called');
  }

  // it called when widget is permanently removed from widget tree
  // it is final method called in widget lifecycle
  // it can be used only one time to dispose resources like release memory, close stream,...
  @override
  void dispose() {
    super.dispose();
    print('dispose called');
  }
}
