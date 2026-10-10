import 'dart:convert';
import 'package:flutter/services.dart';

class Topic {
  final String id, title, english, subtitle, icon;
  Topic(Map<String, dynamic> j)
    : id = j['id'],
      title = j['title'],
      english = j['english'],
      subtitle = j['subtitle'],
      icon = j['icon'];
}

class Phrase {
  final String id, category, albanian, english, pronunciation;
  Phrase(Map<String, dynamic> j)
    : id = j['id'],
      category = j['category'] ?? '',
      albanian = j['albanian'],
      english = j['english'],
      pronunciation = j['pronunciation'];
  bool matches(String query) {
    String normalize(String s) =>
        s.toLowerCase().replaceAll('ë', 'e').replaceAll('ç', 'c');
    return normalize(
      '$albanian $english $pronunciation',
    ).contains(normalize(query.trim()));
  }
}

class Content {
  final List<Topic> topics;
  final List<Phrase> phrases, words;
  Content.fromJson(Map<String, dynamic> j)
    : topics = (j['categories'] as List).map((e) => Topic(e)).toList(),
      phrases = (j['phrases'] as List).map((e) => Phrase(e)).toList(),
      words = (j['words'] as List).map((e) => Phrase(e)).toList();
  static Future<Content> load() async => Content.fromJson(
    jsonDecode(await rootBundle.loadString('assets/data/content.json')),
  );
  List<Phrase> inTopic(String id) =>
      phrases.where((p) => p.category == id).toList();
  Phrase daily(DateTime now) =>
      phrases[DateTime.utc(
            now.year,
            now.month,
            now.day,
          ).difference(DateTime.utc(2026)).inDays.abs() %
          phrases.length];
}
