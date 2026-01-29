import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// This example uses the documentation: https://docs.flutter.dev/cookbook/forms/validation.
/// However, there is a possibility to use schema validation: https://pub.dev/packages/ez_validator.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const Scaffold(body: LoginScreen()),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyLoginForm(),
          MyChartSection(),
          MyNotificationSection(),
          MyCameraSection(),
        ],
      ),
    );
  }
}

class MyLoginForm extends StatefulWidget {
  const MyLoginForm({super.key});

  @override
  MyLoginFormState createState() {
    return MyLoginFormState();
  }
}

class MyLoginFormState extends State<MyLoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
              controller: _emailController,
              validator: (email) {
                if (email == null || email.isEmpty) {
                  return 'Please enter a valid email';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
              controller: _passwordController,
              validator: (password) {
                if (password == null || password.isEmpty) {
                  return 'Please enter a password';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      debugPrint('email: $email');
                      debugPrint('password: $password');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// For the charts I'm using an external package called FL Charts: https://pub.dev/packages/fl_chart
class MyChartSection extends StatelessWidget {
  const MyChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [BarChartRodData(toY: 3, color: Colors.blue)],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(toY: 5, color: Colors.blue)],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [BarChartRodData(toY: 2, color: Colors.blue)],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [BarChartRodData(toY: 8, color: Colors.blue)],
                ),
                BarChartGroupData(
                  x: 4,
                  barRods: [BarChartRodData(toY: 4, color: Colors.blue)],
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
            ),
            duration: Duration(milliseconds: 250),
            curve: Curves.linear,
          ),
        ),
      ],
    );
  }
}

/// For the notifications I'm using an external package called Local Notifications: https://pub.dev/packages/flutter_local_notifications
class MyNotificationSection extends StatefulWidget {
  const MyNotificationSection({super.key});

  @override
  MyNotificationSectionState createState() {
    return MyNotificationSectionState();
  }
}

class MyNotificationSectionState extends State<MyNotificationSection> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    initAsync();
    super.initState();
  }

  Future<void> initAsync() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: androidSettings,
          iOS: DarwinInitializationSettings(),
        );

    await notificationsPlugin.initialize(settings: initializationSettings);

    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton(
              onPressed: () async {
                await showInstantNotificationAsync(
                  id: 0,
                  title: 'Instant Notification',
                  body: 'This is an instant notification',
                );
              },
              child: Text('Instant Notification'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showInstantNotificationAsync({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
    );
  }
}

/// For the camera, I'm using an external package called Camera: https://pub.dev/packages/camera
class MyCameraSection extends StatefulWidget {
  const MyCameraSection({super.key});

  @override
  MyCameraSectionState createState() {
    return MyCameraSectionState();
  }
}

late List<CameraDescription> _cameras;

class MyCameraSectionState extends State<MyCameraSection> {
  late CameraController _cameraController;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    _cameraController
        .initialize()
        .then((_) {
          if (!mounted) {
            debugPrint('Camera controller not mounted!');
            return;
          }

          setState(() {});
        })
        .catchError((Object error) {
          if (error is CameraException) {
            debugPrint('Camera exception: $error');
          }
        });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: const Center(
          child: Text(
            "Camera not available",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FilledButton(
            onPressed: () {
              setState(() {
                _showCamera = !_showCamera;
              });
            },
            child: Text(_showCamera ? "Hide Camera" : "Show Camera"),
          ),
          const SizedBox(height: 16),
          if (_showCamera)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _cameraController.value.aspectRatio,
                child: CameraPreview(_cameraController),
              ),
            )
        ],
      ),
    );
  }
}

