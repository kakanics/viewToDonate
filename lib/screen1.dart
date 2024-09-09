import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'theme.dart'; // Import the theme file

class Screen1 extends StatefulWidget {
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();

    // Initialize the banner ad with your actual Ad Unit ID
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6158090375855987/6831552219', // Replace with your actual Ad Unit ID
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
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Screen 1',
          style: TextStyle(
            fontFamily: AppFonts.pbold,
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Replace with your image asset
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'The primary purpose of this app is to harness the potential of ad-generated revenue to contribute to the well-being of the Palestinian people. Every ad viewed within the app translates into financial support, directly aiding those in need. By using this app, users are not only accessing valuable content but also becoming part of a larger mission to provide relief and assistance to a community that has long endured hardship.',
                  style: TextStyle(
                    fontFamily: AppFonts.pregular,
                    color: AppColors.black100,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Code to show an ad
                  InterstitialAd.load(
                    adUnitId: 'ca-app-pub-6158090375855987/6831552219', // Replace with your actual Interstitial Ad Unit ID
                    request: AdRequest(),
                    adLoadCallback: InterstitialAdLoadCallback(
                      onAdLoaded: (InterstitialAd ad) {
                        ad.show();
                      },
                      onAdFailedToLoad: (LoadAdError error) {
                        print('Failed to load an interstitial ad: ${error.message}');
                      },
                    ),
                  );
                },
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
      ),
    );
  }
}