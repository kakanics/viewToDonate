import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'theme.dart'; // Import the theme file

class Screen1 extends StatefulWidget {
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  //Functions Related to Storage of Ad Counter
  Future<void> _loadAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAdCounter =
        prefs.getInt('adCounter') ?? 5; // Default to 5 if not found
    print('Loaded ad counter: $savedAdCounter'); // Debugging line
    setState(() {
      _adCounter = savedAdCounter;
    });
  }

  Future<void> _saveAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('adCounter', _adCounter);
    print('Saved ad counter: $_adCounter'); // Debugging line
  }

  // Expose font size and color controls in the code
  final double _fontSize = 20.0;
  final Color _fontColor = AppColors.gray100;

  int _adCounter = 5;
  Timer? _notificationTimer;

  // Initialize the FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadAdCounter(); // Load the ad counter from local storage

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
    _saveAdCounter(); // Save the ad counter to local storage before disposing
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
    _notificationTimer = Timer(Duration(seconds: 30), () {
      if (_adCounter > 0 && _adCounter <= 5) {
        _sendNotification("Watch $_adCounter more ads to reach today's target");
      } else {
        _sendNotification("Extra ad watched");
      }
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    // _notificationTimer?.cancel();
    _saveAdCounter(); // Save the ad counter to local storage before disposing
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25.0),
                    child: Container(
                      // height: 600, // Fixed height for the text area
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'View To Donate',
                              style: TextStyle(
                                fontFamily: AppFonts.pextrabold,
                                color: AppColors.white,
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              '  We proudly presents a groundbreaking app designed to bring together the power of technology and community to support a greater cause. Our app is a unique platform that channels its advertising revenue to make a meaningful impact on the world. By leveraging the high CPM (Cost Per Mille) from ads, we aim to create a steady stream of income dedicated to supporting humanitarian efforts in Palestine.',
                              style: TextStyle(
                                fontFamily: AppFonts.pregular,
                                color: _fontColor,
                                fontSize: _fontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '"5 ads a day,\n small steps today, a better tomorrow"',
                              style: TextStyle(
                                fontFamily: AppFonts.pregular,
                                color: AppColors.secondary,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Purpose',
                              style: TextStyle(
                                fontFamily: AppFonts.pextrabold,
                                color: AppColors.white,
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                height:
                                    20), // Optional spacing between the two Text widgets
                            Text(
                              'The primary purpose of this app is to harness the potential of ad-generated revenue to contribute to the well-being of the Palestinian people. Every ad viewed within the app translates into financial support, directly aiding those in need. By using this app, users are not only accessing valuable content but also becoming part of a larger mission to provide relief and assistance to a community that has long endured hardship.',
                              style: TextStyle(
                                fontFamily: AppFonts.pregular,
                                color: _fontColor,
                                fontSize: _fontSize,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isBannerAdReady)
                  Container(
                    height: _bannerAd.size.height.toDouble(),
                    width: _bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd),
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
                SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
