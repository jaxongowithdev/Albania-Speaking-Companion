import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:albania_speaking_companion/main.dart';
import 'package:albania_speaking_companion/data.dart';
import 'package:albania_speaking_companion/store.dart';
import 'package:albania_speaking_companion/quiz.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Content content;
  late AppStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = AppStore(await SharedPreferences.getInstance());
    content = await Content.load();
  });
  test('Every lesson and vocabulary item has bundled audio', () {
    expect(content.phrases.length, 99);
    expect(content.topics.length, 9);
    expect(content.words.length, 30);
    final items = [...content.phrases, ...content.words];
    expect(items.map((p) => p.id).toSet().length, 129);
    for (final t in content.topics) {
      expect(content.inTopic(t.id).length, 11);
    }
    for (final p in items) {
      expect(
        File('assets/audio/${p.id}.mp3').lengthSync(),
        greaterThan(1000),
        reason: p.id,
      );
    }
    expect(content.phrases.where((p) => p.matches('pershendetje')), isNotEmpty);
  });
  test('Favorites, learning and settings survive a fresh store', () async {
    store.toggle('favorites', store.favorites, 'food_01');
    store.toggle('favoriteWords', store.favoriteWords, 'word_01');
    store.toggle('favoriteTopics', store.favoriteTopics, 'food');
    store.markLearned('food_01');
    store.markLearned('food_01');
    store.setTheme(ThemeMode.dark);
    store.setSpeed(.75);
    store.setScale(1.2);
    store.finishQuiz(8);
    final restored = AppStore(await SharedPreferences.getInstance());
    expect(restored.favorites, {'food_01'});
    expect(restored.favoriteWords, {'word_01'});
    expect(restored.favoriteTopics, {'food'});
    expect(restored.learned, {'food_01'});
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.speed, .75);
    expect(restored.bestScore, 8);
    await restored.resetProgress();
    expect(restored.favorites, {'food_01'});
    expect(restored.learned, isEmpty);
    expect(restored.quizzes, 0);
  });
  test('Streak permits yesterday but resets after a missed day', () {
    store.studyDays = {'2026-10-07', '2026-10-08', '2026-10-09'};
    expect(store.streakAt(DateTime(2026, 10, 9)), 3);
    expect(store.streakAt(DateTime(2026, 10, 10)), 3);
    expect(store.streakAt(DateTime(2026, 10, 11)), 0);
  });
  test('Quiz has ten unique questions and one correct option each', () {
    for (final pool in [content.phrases, content.inTopic('food')]) {
      final questions = buildQuestions(pool, random: Random(12));
      expect(questions.length, 10);
      expect(questions.map((q) => q.phrase.id).toSet().length, 10);
      for (final q in questions) {
        expect(q.options.length, 4);
        expect(q.options.map((p) => p.id).toSet().length, 4);
        expect(q.options.where((p) => p.id == q.phrase.id).length, 1);
      }
    }
  });
  testWidgets('Navigate, search, save, learn and switch appearance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(CompanionApp(content: content, store: store));
    await tester.pumpAndSettle();
    expect(find.text('Mirëdita 🇦🇱'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'The menu');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menunë, ju lutem.'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save favorite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as learned'));
    await tester.pumpAndSettle();
    expect(store.favorites.contains('food_01'), isTrue);
    expect(store.learned.contains('food_01'), isTrue);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ruajtura'));
    await tester.pumpAndSettle();
    expect(find.text('Menunë, ju lutem.'), findsOneWidget);
    await tester.tap(find.text('Cilësime'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(store.themeMode, ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Quiz locks answers, advances and records completion once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(CompanionApp(content: content, store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Phrase meanings'));
    await tester.pumpAndSettle();
    final next = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Next question'),
    );
    expect(next.onPressed, isNull);
    for (var i = 0; i < 10; i++) {
      final question = content.phrases.firstWhere(
        (p) => find.text(p.albanian).evaluate().isNotEmpty,
      );
      await tester.tap(find.text(question.english));
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == 9 ? 'See results' : 'Next question'));
      await tester.pumpAndSettle();
    }
    expect(find.text('10 / 10'), findsOneWidget);
    expect(store.quizzes, 1);
    expect(store.bestScore, 10);
  });
  testWidgets('Small screen with larger type has no overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    store.setScale(1.3);
    await tester.pumpWidget(CompanionApp(content: content, store: store));
    await tester.pumpAndSettle();
    for (final label in ['Temat', 'Kuiz', 'Ruajtura', 'Cilësime', 'Kreu']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }
  });
}
