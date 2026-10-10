import 'package:flutter/material.dart';
import 'data.dart';
import 'store.dart';
import 'ui.dart';
import 'quiz.dart';
export 'quiz.dart' show QuizHub;

class HomePage extends StatefulWidget {
  final VoidCallback onTopics;
  const HomePage({super.key, required this.onTopics});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context), store = scope.store;
    final daily = scope.content.daily(DateTime.now());
    final results = scope.content.phrases
        .where((p) => p.matches(query))
        .toList();
    return Column(
      children: [
        BrandHeader(
          home: true,
          title: 'Mirëdita 🇦🇱',
          subtitle: 'Albania Speaking Companion',
          trailing: IconButton(
            tooltip: 'View progress',
            onPressed: () => pushPage(context, const ProgressPage()),
            icon: const Icon(Icons.insights_rounded, color: Colors.white),
          ),
          bottom: TextField(
            onChanged: (v) => setState(() => query = v),
            style: const TextStyle(color: Color(0xff222025), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search phrases…',
              hintStyle: const TextStyle(
                color: Color(0xff969096),
                fontSize: 14,
              ),
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xff999299),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 14,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 3, 16, 22),
            children: query.trim().isNotEmpty
                ? [
                    SectionLabel('${results.length} PHRASES FOUND'),
                    if (results.isEmpty)
                      const EmptyState(
                        icon: Icons.search_off,
                        title: 'No phrases found',
                        subtitle: 'Try a word in English or Albanian.',
                      ),
                    ...results.map((p) => PhraseTile(phrase: p)),
                  ]
                : [
                    const SectionLabel('FJALA E DITËS'),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xff141414),
                        border: Border.all(
                          color: const Color(0xffba333a),
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            daily.albanian,
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: -.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            daily.pronunciation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: gold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            daily.english,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xffbdb9bd),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ListenButton(phrase: daily),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.local_fire_department_rounded,
                            value: '${store.streak}',
                            label: 'Day streak',
                            color: red,
                            onTap: () =>
                                pushPage(context, const ProgressPage()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.menu_book_rounded,
                            value: '${store.learned.length}',
                            label: 'Learned',
                            color: gold,
                            onTap: () =>
                                pushPage(context, const ProgressPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SectionLabel(
                      'TEMAT',
                      trailing: TextButton(
                        onPressed: widget.onTopics,
                        child: const Text(
                          'See all',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    ...scope.content.topics
                        .take(3)
                        .map(
                          (t) => TopicTile(
                            topic: t,
                            onTap: () => pushPage(context, TopicPage(topic: t)),
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.offline_bolt_outlined,
                            size: 15,
                            color: muted(context),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '99 phrases. Yours, even offline.',
                            style: TextStyle(
                              color: muted(context),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final VoidCallback? onTap;
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? .12 : .10,
    ),
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            Text(label, style: TextStyle(color: muted(context), fontSize: 11)),
          ],
        ),
      ),
    ),
  );
}

class TopicsPage extends StatelessWidget {
  const TopicsPage({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const BrandHeader(
        title: 'Explore topics',
        subtitle: 'Small phrases. Real conversations.',
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionLabel('9 TOPICS · 99 EVERYDAY PHRASES'),
            ...AppScope.of(context).content.topics.map(
              (t) => TopicTile(
                topic: t,
                onTap: () => pushPage(context, TopicPage(topic: t)),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class TopicPage extends StatelessWidget {
  final Topic topic;
  const TopicPage({super.key, required this.topic});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context), s = scope.store;
    final list = scope.content.inTopic(topic.id);
    final learned = list.where((p) => s.learned.contains(p.id)).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
        actions: [
          IconButton(
            tooltip: 'Save category',
            onPressed: () =>
                s.toggle('favoriteTopics', s.favoriteTopics, topic.id),
            icon: Icon(
              s.favoriteTopics.contains(topic.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: red,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            topic.english,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(topic.subtitle, style: TextStyle(color: muted(context))),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: learned / list.length,
              color: red,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$learned of 11 phrases learned',
            style: TextStyle(fontSize: 12, color: muted(context)),
          ),
          const SizedBox(height: 20),
          ...list.map((p) => PhraseTile(phrase: p)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => pushPage(
              context,
              QuizPage(
                pool: list,
                mode: QuizMode.meaning,
                title: topic.english,
              ),
            ),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('Practice this topic'),
          ),
        ],
      ),
    );
  }
}

class PhraseTile extends StatelessWidget {
  final Phrase phrase;
  final bool word;
  const PhraseTile({super.key, required this.phrase, this.word = false});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).store;
    final favorites = word ? s.favoriteWords : s.favorites;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: panel(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 6, 8),
          onTap: () =>
              pushPage(context, PhrasePage(phrase: phrase, word: word)),
          title: Text(
            phrase.albanian,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              phrase.english,
              style: TextStyle(fontSize: 12, color: muted(context)),
            ),
          ),
          leading: s.learned.contains(phrase.id) && !word
              ? const Icon(Icons.check_circle, color: gold, size: 20)
              : null,
          trailing: IconButton(
            tooltip: favorites.contains(phrase.id)
                ? 'Remove favorite'
                : 'Save phrase',
            onPressed: () => s.toggle(
              word ? 'favoriteWords' : 'favorites',
              favorites,
              phrase.id,
            ),
            icon: Icon(
              favorites.contains(phrase.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favorites.contains(phrase.id) ? red : muted(context),
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class PhrasePage extends StatefulWidget {
  final Phrase phrase;
  final bool word;
  const PhrasePage({super.key, required this.phrase, this.word = false});
  @override
  State<PhrasePage> createState() => _PhrasePageState();
}

class _PhrasePageState extends State<PhrasePage> {
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    initialized = true;
    final scope = AppScope.of(context);
    if (scope.store.autoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          await scope.speech.play(widget.phrase.id, scope.store.speed);
          scope.store.study();
        } catch (_) {
          if (mounted) message(context, 'Tap Listen to play pronunciation.');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).store, p = widget.phrase;
    final favorites = widget.word ? s.favoriteWords : s.favorites;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word ? 'Vocabulary' : 'Everyday Albanian'),
        actions: [
          IconButton(
            tooltip: 'Save favorite',
            onPressed: () => s.toggle(
              widget.word ? 'favoriteWords' : 'favorites',
              favorites,
              p.id,
            ),
            icon: Icon(
              favorites.contains(p.id) ? Icons.favorite : Icons.favorite_border,
              color: red,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 35),
          const SectionLabel('SAY IT IN ALBANIAN'),
          Text(
            p.albanian,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -.8,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            p.english,
            style: TextStyle(fontSize: 20, height: 1.5, color: muted(context)),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRONUNCIATION',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  p.pronunciation,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'CAPITAL letters show the stressed syllable.',
                  style: TextStyle(fontSize: 11, color: muted(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListenButton(phrase: p),
          const SizedBox(height: 12),
          if (!widget.word)
            OutlinedButton.icon(
              onPressed: s.learned.contains(p.id)
                  ? null
                  : () {
                      s.markLearned(p.id);
                      message(context, 'Nice work! Phrase marked as learned.');
                    },
              icon: Icon(
                s.learned.contains(p.id) ? Icons.check_circle : Icons.check,
              ),
              label: Text(
                s.learned.contains(p.id) ? 'Learned' : 'Mark as learned',
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Listen. Repeat. Make it yours.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: muted(context)),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context), s = scope.store;
    final phrases = scope.content.phrases
        .where((p) => s.favorites.contains(p.id))
        .toList();
    final words = scope.content.words
        .where((p) => s.favoriteWords.contains(p.id))
        .toList();
    final topics = scope.content.topics
        .where((p) => s.favoriteTopics.contains(p.id))
        .toList();
    Widget list(List<Phrase> items, String type, bool word) => items.isEmpty
        ? EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No favourite $type',
            subtitle: 'Tap a heart to keep your favourite $type here.',
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map((p) => PhraseTile(phrase: p, word: word))
                .toList(),
          );
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const BrandHeader(
            title: 'Favorites',
            subtitle: 'Everything you saved, in one place',
          ),
          TabBar(
            labelColor: red,
            unselectedLabelColor: muted(context),
            indicatorColor: red,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Phrases'),
              Tab(text: 'Words'),
              Tab(text: 'Categories'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                list(phrases, 'phrases', false),
                list(words, 'words', true),
                topics.isEmpty
                    ? const EmptyState(
                        icon: Icons.favorite_border_rounded,
                        title: 'No favourite categories',
                        subtitle: 'Save a category to jump back in quickly.',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: topics
                            .map(
                              (t) => TopicTile(
                                topic: t,
                                onTap: () =>
                                    pushPage(context, TopicPage(topic: t)),
                              ),
                            )
                            .toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool reminderBusy = false;
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context), s = scope.store;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 26, 0, 14),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xffbf3641),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
    Widget control(IconData icon, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 17),
            child: Icon(icon, color: muted(context), size: 22),
          ),
          Expanded(child: child),
        ],
      ),
    );
    return Column(
      children: [
        const BrandHeader(
          title: 'Settings',
          subtitle: 'Customise your experience',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            children: [
              label('APPEARANCE'),
              control(
                Icons.dark_mode_outlined,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme', style: TextStyle(fontSize: 15)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(
                              'System',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(
                              'Light',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                        selected: {s.themeMode},
                        onSelectionChanged: (v) => s.setTheme(v.first),
                      ),
                    ),
                  ],
                ),
              ),
              control(
                Icons.text_fields_rounded,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Font size')),
                        Text(
                          '${(s.fontScale * 100).round()}%',
                          style: TextStyle(fontSize: 11, color: muted(context)),
                        ),
                      ],
                    ),
                    Slider(
                      value: s.fontScale,
                      min: .85,
                      max: 1.3,
                      divisions: 9,
                      label: '${(s.fontScale * 100).round()}%',
                      onChanged: s.setScale,
                    ),
                  ],
                ),
              ),
              label('AUDIO'),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.play_circle_outline),
                title: const Text(
                  'Auto-play audio',
                  style: TextStyle(fontSize: 15),
                ),
                subtitle: const Text(
                  'Speak a phrase when you open it',
                  style: TextStyle(fontSize: 12),
                ),
                value: s.autoplay,
                activeThumbColor: red,
                onChanged: s.setAutoplay,
              ),
              const SizedBox(height: 16),
              control(
                Icons.speed_rounded,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Playback speed')),
                        Text(
                          '${s.speed.toStringAsFixed(2)}×',
                          style: TextStyle(fontSize: 11, color: muted(context)),
                        ),
                      ],
                    ),
                    Slider(
                      value: s.speed,
                      min: .5,
                      max: 1.5,
                      divisions: 4,
                      onChanged: s.setSpeed,
                    ),
                  ],
                ),
              ),
              label('NOTIFICATIONS'),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text(
                  'Daily reminder',
                  style: TextStyle(fontSize: 15),
                ),
                subtitle: Text(
                  scope.reminders.supported
                      ? 'A little Albanian at 7:00 PM'
                      : 'Available in the iOS and Android app',
                  style: const TextStyle(fontSize: 12),
                ),
                value: s.reminder,
                activeThumbColor: red,
                onChanged: reminderBusy || !scope.reminders.supported
                    ? null
                    : (v) async {
                        setState(() => reminderBusy = true);
                        try {
                          final allowed = await scope.reminders.setEnabled(v);
                          if (allowed) {
                            await s.setReminder(v);
                          } else if (context.mounted) {
                            message(
                              context,
                              'Enable notifications in your device settings to receive reminders.',
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            message(
                              context,
                              'Could not update your reminder. Please try again.',
                            );
                          }
                        } finally {
                          if (mounted) setState(() => reminderBusy = false);
                        }
                      },
              ),
              label('DATA'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.insights_rounded),
                title: const Text(
                  'View progress',
                  style: TextStyle(fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => pushPage(context, const ProgressPage()),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.translate_rounded),
                title: const Text(
                  'Vocabulary list',
                  style: TextStyle(fontSize: 15),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => pushPage(context, const VocabularyPage()),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt, color: red),
                title: const Text(
                  'Reset learning progress',
                  style: TextStyle(fontSize: 15, color: red),
                ),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Start fresh?'),
                      content: const Text(
                        'This resets learned phrases, streaks and quiz scores. Your favourites and settings stay saved.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Keep progress'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) await s.resetProgress();
                },
              ),
              label('ABOUT'),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: panel(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 62,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Albania Speaking Companion',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Speak real, everyday Albanian from day one. 99 practical phrases with pronunciation, audio and quizzes — fully offline, no account needed. Mirë se erdhe!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted(context),
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Version 1.0.0 · Made for everyday moments',
                      style: TextStyle(color: muted(context), fontSize: 10),
                    ),
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text('Your learning stays yours'),
                          content: const Text(
                            'No account, analytics or ads. Your progress, favourites and preferences are stored on this device. Audio and lessons are bundled in the app. Deleting the app may remove saved data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(c),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text(
                        'Privacy',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});
  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final words = AppScope.of(
      context,
    ).content.words.where((p) => p.matches(query)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search words…',
              ),
            ),
          ),
          Expanded(
            child: words.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'No words found',
                    subtitle: 'Try another search.',
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: words
                        .map((p) => PhraseTile(phrase: p, word: true))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context), s = scope.store;
    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'A little, every day.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Every phrase is a step toward a real conversation.',
            style: TextStyle(color: muted(context), height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department,
                  value: '${s.streak}',
                  label: 'Day streak',
                  color: red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.menu_book,
                  value: '${s.learned.length}/99',
                  label: 'Phrases learned',
                  color: gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.quiz,
                  value: '${s.quizzes}',
                  label: 'Quizzes completed',
                  color: gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.emoji_events_outlined,
                  value: '${s.bestScore}/10',
                  label: 'Best quiz score',
                  color: red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('YOUR LAST 7 DAYS'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final now = DateTime.now();
              final day = DateTime(now.year, now.month, now.day - 6 + i);
              final done = s.studyDays.contains(AppStore.dateKey(day));
              return Column(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: done ? red : panel(context),
                    child: Icon(
                      done ? Icons.check : Icons.circle_outlined,
                      color: done ? Colors.white : muted(context),
                      size: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${day.day}/${day.month}',
                    style: TextStyle(fontSize: 10, color: muted(context)),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          const SectionLabel('BY TOPIC'),
          ...scope.content.topics.map((t) {
            final learned = scope.content
                .inTopic(t.id)
                .where((p) => s.learned.contains(p.id))
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '$learned/11',
                        style: TextStyle(color: muted(context), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: learned / 11,
                    color: red,
                    borderRadius: BorderRadius.circular(5),
                    minHeight: 5,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
