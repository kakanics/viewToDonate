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
  RewardedAd? _rewardedAd;
  bool _isBannerAdReady = false;
  bool _isBannerAdFailed = false;
  bool _isLoadingAd = false;
  bool _isRewardedAdReady = false;

  int _adCounter = 0;
  Timer? _notificationTimer;
  Timer? _adLoadTimer;

  // Initialize the FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final double _fontSize = 20.0;
  final Color _fontColor = AppColors.gray100;

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
            _isBannerAdFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerAdReady = false;
            _isBannerAdFailed = true;
          });
          print('Failed to load a banner ad: ${error.message}');
        },
      ),
    )..load();

    // Prefetch the rewarded ad
    _loadRewardedAd();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Check if the ad counter needs to be reset
    _checkAndResetAdCounter();
  }

  Future<void> _loadAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAdCounter =
        prefs.getInt('adCounter') ?? 5; // Default to 0 if not found
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

  Future<void> _checkAndResetAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('lastResetDate') ?? '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toString();

    if (lastResetDate != today) {
      setState(() {
        _adCounter = 0;
      });
      await prefs.setString('lastResetDate', today);
      await _saveAdCounter();
      print('Ad counter reset to 0');
    }
  }

  void _loadRewardedAd() {
    _adLoadTimer?.cancel();
    _adLoadTimer = Timer(Duration(seconds: 5), () {
      if (!_isRewardedAdReady) {
        setState(() {
          _isLoadingAd = false;
        });
        _showAdFailedDialog();
      }
    });

    RewardedAd.load(
      adUnitId:
          'ca-app-pub-6158090375855987/1542472608', // Replace with your actual Rewarded Ad Unit ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _adLoadTimer?.cancel();
          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
          });
          if (_isLoadingAd) {
            _showRewardedAd();
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _adLoadTimer?.cancel();
          print('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          setState(() {
            _adCounter--;
            _saveAdCounter();
            if (_adCounter == 0) {
              _sendNotification(
                  "Congratulations, you've done enough for today");
            } else if (_adCounter < 0) {
              _adCounter = -1; // Ensure it only goes to -1 once
            }
          });
        },
      );
      _startNotificationTimer();
      // Prefetch the next rewarded ad
      _loadRewardedAd();
    } else {
      _showAdFailedDialog();
    }
    setState(() {
      _isLoadingAd = false;
    });
  }

  void _showAdFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary, // Set dialog background color
          title: Text(
            'Ad Load Failed',
            style: TextStyle(color: Colors.white), // Set title text color
          ),
          content: Text(
            'Failed to load ad. Please try again later.',
            style: TextStyle(color: Colors.white), // Set content text color
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue), // Set button text color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
    _notificationTimer = Timer(Duration(seconds: 30), () {
      if (_adCounter > 0 && _adCounter < 5) {
        _sendNotification("Watch $_adCounter more ads to reach today's target");
      } else if (_adCounter == 5) {}
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _rewardedAd?.dispose();
    _adLoadTimer?.cancel();
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
                  )
                else if (_isBannerAdFailed)
                  Text(
                    'Failed to load banner ad',
                    style: TextStyle(
                      fontFamily: AppFonts.pregular,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                SizedBox(height: 15),
                _isLoadingAd
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoadingAd = true;
                          });
                          if (_isRewardedAdReady) {
                            _showRewardedAd();
                          } else {
                            _loadRewardedAd();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.secondary, // Background color
                          foregroundColor: AppColors.primary, // Text color
                          textStyle: TextStyle(
                            fontFamily: AppFonts.pbold,
                          ),
                        ),
                        child: Text('View Ad'),
                      ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
