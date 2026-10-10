import 'dart:math';
import 'package:flutter/material.dart';
import 'data.dart';
import 'ui.dart';

enum QuizMode { meaning, pronunciation, listening }

class QuizHub extends StatelessWidget {
  const QuizHub({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    Widget card(IconData icon, String title, String subtitle, QuizMode mode) =>
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: panel(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => pushPage(
              context,
              QuizPage(pool: scope.content.phrases, mode: mode, title: title),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: red.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: red),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: muted(context),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
        );
    return Column(
      children: [
        const BrandHeader(
          title: 'A little practice',
          subtitle: 'Build confidence, one question at a time',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xff161416),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: gold,
                      size: 30,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'From knowing to speaking.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '10 questions. A few minutes.\nA little closer to your next conversation.',
                      style: TextStyle(
                        color: Color(0xffb8b0b5),
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'PERSONAL BEST   ${scope.store.bestScore}/10',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 10,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SectionLabel('CHOOSE YOUR PRACTICE'),
              card(
                Icons.translate_rounded,
                'Phrase meanings',
                'Find the right English translation',
                QuizMode.meaning,
              ),
              card(
                Icons.record_voice_over_outlined,
                'Conversation practice',
                'Match phrases to their pronunciation',
                QuizMode.pronunciation,
              ),
              card(
                Icons.headphones_rounded,
                'Listening challenge',
                'Listen in Albanian. Choose the meaning.',
                QuizMode.listening,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuizQuestion {
  final Phrase phrase;
  final List<Phrase> options;
  QuizQuestion(this.phrase, this.options);
}

List<QuizQuestion> buildQuestions(List<Phrase> pool, {Random? random}) {
  final rng = random ?? Random();
  final shuffled = List<Phrase>.from(pool)..shuffle(rng);
  return shuffled.take(10).map((p) {
    final others =
        pool
            .where(
              (o) =>
                  o.id != p.id &&
                  o.english != p.english &&
                  o.pronunciation != p.pronunciation,
            )
            .toList()
          ..shuffle(rng);
    final options = [p, ...others.take(3)]..shuffle(rng);
    return QuizQuestion(p, options);
  }).toList();
}

class QuizPage extends StatefulWidget {
  final List<Phrase> pool;
  final QuizMode mode;
  final String title;
  const QuizPage({
    super.key,
    required this.pool,
    required this.mode,
    required this.title,
  });
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<QuizQuestion> questions;
  int index = 0, score = 0;
  String? selected;
  bool finished = false;
  @override
  void initState() {
    super.initState();
    questions = buildQuestions(widget.pool);
  }

  void answer(Phrase answer) {
    if (selected != null) return;
    final correct = answer.id == questions[index].phrase.id;
    setState(() {
      selected = answer.id;
      if (correct) score++;
    });
    if (correct) AppScope.of(context).store.markLearned(answer.id);
  }

  void next() {
    if (selected == null) return;
    AppScope.of(context).speech.stop();
    if (index == questions.length - 1) {
      AppScope.of(context).store.finishQuiz(score);
      setState(() => finished = true);
    } else {
      setState(() {
        index++;
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice complete')),
        body: ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const SizedBox(height: 44),
            const Icon(Icons.emoji_events_rounded, color: gold, size: 82),
            const SizedBox(height: 24),
            Text(
              score >= 7 ? 'Shumë mirë!' : 'Keep going!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              '$score / ${questions.length}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: red,
                fontSize: 46,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              score >= 7
                  ? 'Your Albanian is growing, one phrase at a time.'
                  : 'Every attempt helps. A little practice goes a long way.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted(context), height: 1.5),
            ),
            const SizedBox(height: 36),
            FilledButton(
              onPressed: () => setState(() {
                questions = buildQuestions(widget.pool);
                index = 0;
                score = 0;
                selected = null;
                finished = false;
              }),
              child: const Text('Practice again'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to learning'),
            ),
          ],
        ),
      );
    }
    final q = questions[index];
    final correct = selected == q.phrase.id;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.title} · ${index + 1}/${questions.length}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: index / questions.length,
            minHeight: 4,
            color: red,
            backgroundColor: red.withValues(alpha: .15),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 25, 18, 20),
              children: [
                if (widget.mode == QuizMode.listening) ...[
                  const Text(
                    'What did you hear?',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Listen, then choose the meaning.',
                    style: TextStyle(color: muted(context)),
                  ),
                  const SizedBox(height: 20),
                  ListenButton(phrase: q.phrase),
                ] else ...[
                  Text(
                    q.phrase.albanian,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.mode == QuizMode.pronunciation
                        ? q.phrase.english
                        : 'Choose the correct meaning.',
                    style: TextStyle(fontSize: 15, color: muted(context)),
                  ),
                ],
                const SizedBox(height: 26),
                ...q.options.map((p) {
                  final isCorrect = selected != null && p.id == q.phrase.id;
                  final isWrong = selected == p.id && !isCorrect;
                  final color = isCorrect
                      ? const Color(0xff248867)
                      : isWrong
                      ? red
                      : Colors.transparent;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: isCorrect || isWrong
                          ? color.withValues(alpha: .14)
                          : panel(context),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: selected == null ? () => answer(p) : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.mode == QuizMode.pronunciation
                                      ? p.pronunciation
                                      : p.english,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (isCorrect || isWrong)
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: color,
                                  size: 21,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (selected != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      correct
                          ? 'Saktë! That’s right.'
                          : 'Keep learning. The correct answer is highlighted.',
                      style: TextStyle(
                        color: correct ? const Color(0xff248867) : red,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                if (selected != null && widget.mode == QuizMode.listening)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      q.phrase.albanian,
                      style: TextStyle(color: muted(context)),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selected == null ? null : next,
                  child: Text(
                    index == questions.length - 1
                        ? 'See results'
                        : 'Next question',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
