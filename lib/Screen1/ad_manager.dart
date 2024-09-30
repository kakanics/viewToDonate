import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  late BannerAd _bannerAd;
  RewardedAd? _rewardedAd;
  bool isBannerAdReady = false;
  bool isBannerAdFailed = false;
  bool isLoadingAd = false;
  bool isRewardedAdReady = false;

  final Function(String) onAdNetworkInfo;

  AdManager({required this.onAdNetworkInfo});

  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6158090375855987/6831552219',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          isBannerAdReady = true;
          isBannerAdFailed = false;
          _logAdNetworkInfo(ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          isBannerAdReady = false;
          isBannerAdFailed = true;
          print('Failed to load a banner ad: ${error.message}');
        },
      ),
    )..load();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-6158090375855987/1542472608',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          isRewardedAdReady = true;
          _logAdNetworkInfo(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load a rewarded ad: ${error.message}');
        },
      ),
    );
  }

  void showRewardedAd({
    required Function onAdFailed,
    required Function onAdLoaded,
    required Function onUserEarnedReward,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onUserEarnedReward();
        },
      );
      loadRewardedAd();
    } else {
      onAdFailed();
    }
  }

  void _logAdNetworkInfo(Ad ad) {
    final responseInfo = ad.responseInfo;
    if (responseInfo != null) {
      final adapterClassName = responseInfo.mediationAdapterClassName;
      onAdNetworkInfo(adapterClassName ?? 'Unknown');
    }
  }

  BannerAd get bannerAd => _bannerAd;

  void dispose() {
    _bannerAd.dispose();
    _rewardedAd?.dispose();
  }
}
