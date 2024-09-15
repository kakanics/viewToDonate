import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';

class AdWidgetContainer extends StatelessWidget {
  final AdManager adManager;

  AdWidgetContainer({required this.adManager});

  @override
  Widget build(BuildContext context) {
    return adManager.isBannerAdReady
        ? Container(
            height: adManager.bannerAd.size.height.toDouble(),
            width: adManager.bannerAd.size.width.toDouble(),
            child: AdWidget(ad: adManager.bannerAd),
          )
        : adManager.isBannerAdFailed
            ? Text(
                'Failed to load banner ad',
                style: TextStyle(
                  fontFamily: 'PRegular',
                  color: Colors.red,
                  fontSize: 16,
                ),
              )
            : Container();
  }
}
