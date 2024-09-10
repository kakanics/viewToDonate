import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'theme.dart'; // Import the theme file

class Screen1 extends StatefulWidget {
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // Expose font size and color controls in the code
  final double _fontSize = 32.0;
  final Color _fontColor = AppColors.gray100;

  int _adCounter = 5;
  Timer? _notificationTimer;

  // Initialize the FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // Initialize the banner ad with your actual Ad Unit ID
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-6158090375855987/6831552219', // Replace with your actual Ad Unit ID
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Failed to load a banner ad: ${error.message}');
        },
      ),
    )..load();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Reset the ad counter at midnight
    _resetAdCounterAtMidnight();
  }

  void _resetAdCounterAtMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = midnight.difference(now);

    Timer(durationUntilMidnight, () {
      setState(() {
        _adCounter = 5;
      });
      _resetAdCounterAtMidnight();
    });
  }

  void _showRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-6158090375855987/1542472608', // Replace with your actual Rewarded Ad Unit ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              setState(() {
                _adCounter--;
              });
              if (_adCounter == 0) {
                _sendNotification(
                    "Congratulations, you've done enough for today");
              }
            },
          );
          _startNotificationTimer();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  void _sendNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel',
      'All notifications for this app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Ad Notification',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void _startNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer(Duration(seconds: 10), () {
      if (_adCounter > 0 && _adCounter <= 5) {
        _sendNotification("Watch $_adCounter more ads to reach today's target");
      }
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Replace with your image asset
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 500, // Fixed height for the text area
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      'The primary purpose of this app is to harness the potential of ad-generated revenue to contribute to the well-being of the Palestinian people. Every ad viewed within the app translates into financial support, directly aiding those in need. By using this app, users are not only accessing valuable content but also becoming part of a larger mission to provide relief and assistance to a community that has long endured hardship.',
                      style: TextStyle(
                        fontFamily: AppFonts.pregular,
                        color: _fontColor,
                        fontSize: _fontSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showRewardedAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary, // Background color
                    foregroundColor: AppColors.primary, // Text color
                    textStyle: TextStyle(
                      fontFamily: AppFonts.pbold,
                    ),
                  ),
                  child: Text('View Ad'),
                ),
                SizedBox(height: 20),
                if (_isBannerAdReady)
                  Container(
                    height: _bannerAd.size.height.toDouble(),
                    width: _bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
