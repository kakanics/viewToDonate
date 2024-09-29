import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Screen1/screen1.dart';
import 'screen2.dart';
import 'theme.dart';
import 'package:gma_mediation_unity/gma_mediation_unity.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final gmaMediationUnity = GmaMediationUnity();

  // Set GDPR and CCPA statuses
  gmaMediationUnity.setGDPRConsent(true);
  gmaMediationUnity.setCCPAConsent(true);

  MobileAds.instance.initialize().then((initializationStatus) {
    initializationStatus.adapterStatuses.forEach((key, value) {
      debugPrint('Adapter status for $key: ${value.description}');
      if (value.state == AdapterInitializationState.notReady) {
        debugPrint('Adapter $key failed to initialize: ${value.description}');
      } else if (value.state == AdapterInitializationState.ready) {
        debugPrint('Adapter $key successfully initialized.');
      }
    });
  }).catchError((error) {
    debugPrint('Failed to initialize Mobile Ads: $error');
  });

  // Initialize the local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // Handle notification tapped logic here
      debugPrint('Notification tapped: ${notificationResponse.payload}');
    },
  ).catchError((error) {
    debugPrint('Failed to initialize local notifications: $error');
  });

  runApp(MyApp());

  // Set GDPR and CCPA statuses
  await setGDPRStatus(true, "v1.0.0");
  await setCCPAStatus(true);
}

Future<void> setGDPRStatus(bool status, String version) async {
  const platform = MethodChannel('com.example.view_to_donate/privacy');
  try {
    await platform
        .invokeMethod('setGDPRStatus', {'status': status, 'version': version});
    debugPrint('GDPR status set to $status with version $version.');
  } on PlatformException catch (e) {
    debugPrint("Failed to set GDPR status: '${e.message}'.");
  }
}

Future<void> setCCPAStatus(bool status) async {
  const platform = MethodChannel('com.example.view_to_donate/privacy');
  try {
    await platform.invokeMethod('setCCPAStatus', {'status': status});
    debugPrint('CCPA status set to $status.');
  } on PlatformException catch (e) {
    debugPrint("Failed to set CCPA status: '${e.message}'.");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: AppColors.primary,
        fontFamily: AppFonts.pregular,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: AppFonts.pregular),
          bodyMedium: TextStyle(fontFamily: AppFonts.plight),
          displayLarge: TextStyle(fontFamily: AppFonts.pbold),
          displayMedium: TextStyle(fontFamily: AppFonts.psemibold),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppColors.primary,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.gray100,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Article',
          ),
        ],
      ),
    );
  }
}
