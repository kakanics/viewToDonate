import 'package:shared_preferences/shared_preferences.dart';

class AdCounterManager {
  int adCounter = 0;

  Future<void> loadAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    adCounter = prefs.getInt('adCounter') ?? 5;
    print('Loaded ad counter: $adCounter');
  }

  Future<void> saveAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('adCounter', adCounter);
    print('Saved ad counter: $adCounter');
  }

  Future<void> checkAndResetAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString('lastResetDate') ?? '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toString();

    if (lastResetDate != today) {
      adCounter = 5;
      await prefs.setString('lastResetDate', today);
      await saveAdCounter();
      print('Ad counter reset to 5');
    }
  }

  void decrementAdCounter() {
    adCounter--;
    saveAdCounter();
  }
}
