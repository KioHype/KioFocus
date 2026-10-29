import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_model.dart';

class StorageService {
  static const _blockedKey     = 'blocked_apps';
  static const _recommendedKey = 'recommended_apps';
  static const _tutorialKey    = 'tutorial_done';

  static Future<List<BlockedApp>> loadBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_blockedKey) ?? [];
    return raw
        .map((e) => BlockedApp.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> saveBlockedApps(List<BlockedApp> apps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _blockedKey,
      apps.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<List<RecommendedApp>> loadRecommendedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_recommendedKey) ?? [];
    return raw
        .map((e) => RecommendedApp.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> saveRecommendedApps(List<RecommendedApp> apps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _recommendedKey,
      apps.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<bool> isTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialKey) ?? false;
  }

  static Future<void> markTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
  }
}