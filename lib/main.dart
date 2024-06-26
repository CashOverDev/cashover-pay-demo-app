import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashOver E-commerce Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Products'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void openApp() async {
    try {
      const platform = MethodChannel('app_open_channel');
      final Map<String, String> params = <String, String>{
        'androidPackageName': 'com.cashover.crypto.stg',
        'iosBundleId': "com.cashover.crypto.stg",
      };
      final String result = await platform.invokeMethod('openApp', params);
      if (result == "error") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App is not available')),
        );
      }
    } on PlatformException catch (e) {
      print("Failed to open app: '${e.message}'.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Demo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openApp,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
