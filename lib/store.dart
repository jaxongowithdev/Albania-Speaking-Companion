import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore extends ChangeNotifier {
  final SharedPreferences prefs;
  late Set<String> favorites, favoriteTopics, favoriteWords, learned, studyDays;
  late ThemeMode themeMode;
  late double fontScale, speed;
  late bool autoplay, reminder;
  late int quizzes, bestScore;
  AppStore(this.prefs) {
    favorites = _set('favorites');
    favoriteTopics = _set('favoriteTopics');
    favoriteWords = _set('favoriteWords');
    learned = _set('learned');
    studyDays = _set('studyDays');
    themeMode = ThemeMode.values[(prefs.getInt('theme') ?? 0).clamp(0, 2)];
    fontScale = (prefs.getDouble('fontScale') ?? 1).clamp(0.85, 1.3);
    speed = (prefs.getDouble('speed') ?? 1).clamp(0.5, 1.5);
    autoplay = prefs.getBool('autoplay') ?? false;
    reminder = prefs.getBool('reminder') ?? false;
    quizzes = prefs.getInt('quizzes') ?? 0;
    bestScore = prefs.getInt('bestScore') ?? 0;
  }
  Set<String> _set(String key) => (prefs.getStringList(key) ?? []).toSet();
  void toggle(String key, Set<String> set, String id) {
    set.contains(id) ? set.remove(id) : set.add(id);
    unawaited(prefs.setStringList(key, set.toList()));
    notifyListeners();
  }

  void markLearned(String id) {
    learned.add(id);
    unawaited(prefs.setStringList('learned', learned.toList()));
    study();
  }

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  void study() {
    studyDays.add(dateKey(DateTime.now()));
    unawaited(prefs.setStringList('studyDays', studyDays.toList()));
    notifyListeners();
  }

  int streakAt(DateTime now) {
    var date = DateTime(now.year, now.month, now.day);
    if (!studyDays.contains(dateKey(date))) {
      date = DateTime(date.year, date.month, date.day - 1);
    }
    var count = 0;
    while (studyDays.contains(dateKey(date))) {
      count++;
      date = DateTime(date.year, date.month, date.day - 1);
    }
    return count;
  }

  int get streak => streakAt(DateTime.now());
  void finishQuiz(int score) {
    quizzes++;
    if (score > bestScore) bestScore = score;
    unawaited(prefs.setInt('quizzes', quizzes));
    unawaited(prefs.setInt('bestScore', bestScore));
    study();
  }

  void setTheme(ThemeMode value) {
    themeMode = value;
    unawaited(prefs.setInt('theme', value.index));
    notifyListeners();
  }

  void setScale(double value) {
    fontScale = value;
    unawaited(prefs.setDouble('fontScale', value));
    notifyListeners();
  }

  void setSpeed(double value) {
    speed = value;
    unawaited(prefs.setDouble('speed', value));
    notifyListeners();
  }

  void setAutoplay(bool value) {
    autoplay = value;
    unawaited(prefs.setBool('autoplay', value));
    notifyListeners();
  }

  Future<void> setReminder(bool value) async {
    reminder = value;
    await prefs.setBool('reminder', value);
    notifyListeners();
  }

  Future<void> resetProgress() async {
    learned.clear();
    studyDays.clear();
    quizzes = 0;
    bestScore = 0;
    for (final key in ['learned', 'studyDays', 'quizzes', 'bestScore']) {
      await prefs.remove(key);
    }
    notifyListeners();
  }
}
