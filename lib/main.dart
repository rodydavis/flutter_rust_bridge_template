import 'package:flutter/material.dart';
import 'ffi_web.dart' if (dart.library.ffi) 'ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Platform> platform;
  late Future<bool> isRelease;

  @override
  void initState() {
    super.initState();
    platform = api.platform();
    isRelease = api.rustReleaseMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("You're running on"),
            FutureBuilder<List<dynamic>>(
              future: Future.wait([platform, isRelease]),
              builder: (context, snap) {
                final style = Theme.of(context).textTheme.headline4;
                if (snap.error != null) {
                  debugPrint(snap.error.toString());
                  return Tooltip(
                    message: snap.error.toString(),
                    child: Text('Unknown OS', style: style),
                  );
                }

                final data = snap.data;
                if (data == null) return const CircularProgressIndicator();

                final Platform platform = data[0];
                final release = data[1] ? 'Release' : 'Debug';

                return Text('${platform.name} ($release)', style: style);
              },
            )
          ],
        ),
      ),
    );
  }
}

extension on Platform {
  String get name {
    switch (this) {
      case Platform.Android:
        return 'Android';
      case Platform.Ios:
        return 'iOS';
      case Platform.MacApple:
        return 'MacOS with Apple Silicon';
      case Platform.MacIntel:
        return 'MacOS';
      case Platform.Windows:
        return 'Windows';
      case Platform.Unix:
        return 'Unix';
      case Platform.Wasm:
        return 'the Web';
      default:
        return 'Unknown OS';
    }
  }
}
