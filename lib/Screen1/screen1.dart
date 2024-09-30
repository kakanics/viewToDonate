import 'package:flutter/material.dart';
import 'ad_manager.dart';
import 'notification_manager.dart';
import 'ad_counter_manager.dart';
import 'ad_widget.dart';
import '../theme.dart';

class Screen1 extends StatefulWidget {
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  late AdManager _adManager;
  late NotificationManager _notificationManager;
  late AdCounterManager _adCounterManager;

  @override
  void initState() {
    super.initState();
    _adManager = AdManager(onAdNetworkInfo: _logAdNetworkInfo);
    _notificationManager = NotificationManager();
    _adCounterManager = AdCounterManager();

    _adCounterManager.loadAdCounter().then((_) {
      _adCounterManager.checkAndResetAdCounter();
    });

    _adManager.loadBannerAd();
    _adManager.loadRewardedAd();
  }

  void _logAdNetworkInfo(String adapterClassName) {
    print('Ad served by: $adapterClassName');
  }

  @override
  void dispose() {
    _adManager.dispose();
    _adCounterManager.saveAdCounter();
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
                image: AssetImage('assets/background.jpg'),
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
                                color: AppColors.gray100,
                                fontSize: 20.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '"Your support can change lives; will you be the bridge between despair and hope?"',
                              style: TextStyle(
                                fontFamily: AppFonts.pregular,
                                color: AppColors.secondary,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '"You just have to watch 5 ads a day to support the people of Palestine"',
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
                            SizedBox(height: 20),
                            Text(
                              'The primary purpose of this app is to harness the potential of ad-generated revenue to contribute to the well-being of the Palestinian people. Every ad viewed within the app translates into financial support, directly aiding those in need. By using this app, users are not only accessing valuable content but also becoming part of a larger mission to provide relief and assistance to a community that has long endured hardship.',
                              style: TextStyle(
                                fontFamily: AppFonts.pregular,
                                color: AppColors.gray100,
                                fontSize: 20.0,
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
                AdWidgetContainer(adManager: _adManager),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _adManager.isLoadingAd = true;
                    });
                    _adManager.showRewardedAd(
                      onAdFailed: () {
                        setState(() {
                          _adManager.isLoadingAd = false;
                        });
                        _showAdFailedDialog();
                      },
                      onAdLoaded: () {
                        setState(() {
                          _adManager.isLoadingAd = false;
                        });
                      },
                      onUserEarnedReward: () {
                        setState(() {
                          _adCounterManager.decrementAdCounter();
                          if (_adCounterManager.adCounter == 0) {
                            _notificationManager.sendNotification(
                                "Congratulations, you've done enough for today");
                          } else if (_adCounterManager.adCounter > 0 &&
                              _adCounterManager.adCounter < 5) {
                            _notificationManager.sendNotification("Watch " +
                                _adCounterManager.adCounter.toString() +
                                " more ads to complete today's goal");
                          }
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.primary,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.pbold,
                    ),
                  ),
                  child: _adManager.isLoadingAd
                      ? CircularProgressIndicator()
                      : Text('View Ad'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          title: Text(
            'Ad Load Failed',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Failed to load ad. Please try again later.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blue),
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
}
