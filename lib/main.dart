import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'store.dart';
import 'services.dart';
import 'screens.dart';
import 'ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final content = await Content.load();
  final store = AppStore(await SharedPreferences.getInstance());
  runApp(CompanionApp(content: content, store: store));
}

class CompanionApp extends StatefulWidget {
  final Content content;
  final AppStore store;
  const CompanionApp({super.key, required this.content, required this.store});
  @override
  State<CompanionApp> createState() => _CompanionAppState();
}

class _CompanionAppState extends State<CompanionApp> {
  final speech = SpeechPlayer();
  final reminders = ReminderService();
  @override
  void dispose() {
    speech.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScope(
    store: widget.store,
    content: widget.content,
    speech: speech,
    reminders: reminders,
    child: ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) => MaterialApp(
        title: 'Albania Speaking Companion',
        debugShowCheckedModeBanner: false,
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        themeMode: widget.store.themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(1) *
                  widget.store.fontScale,
            ),
          ),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: const Color(0xff151416),
            ),
            child: ColoredBox(
              color: const Color(0xff24282b),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: child!,
                ),
              ),
            ),
          ),
        ),
        home: const MainShell(),
      ),
    ),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onTopics: () => setState(() => selected = 1)),
      const TopicsPage(),
      const QuizHub(),
      const FavoritesPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: selected, children: pages),
      bottomNavigationBar: ColoredBox(
        color: const Color(0xff151416),
        child: SafeArea(
          top: false,
          child: Container(
            color: const Color(0xff151416),
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 9),
            child: Row(
              children: List.generate(5, (i) {
                const icons = [
                  Icons.home_rounded,
                  Icons.grid_view_rounded,
                  Icons.quiz_outlined,
                  Icons.favorite_border_rounded,
                  Icons.settings_outlined,
                ];
                const active = [
                  Icons.home_rounded,
                  Icons.grid_view_rounded,
                  Icons.quiz,
                  Icons.favorite_rounded,
                  Icons.settings,
                ];
                const labels = [
                  'Kreu',
                  'Temat',
                  'Kuiz',
                  'Ruajtura',
                  'Cilësime',
                ];
                return Expanded(
                  child: Semantics(
                    selected: selected == i,
                    button: true,
                    label: labels[i],
                    child: InkWell(
                      onTap: () => setState(() => selected = i),
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 58,
                            height: 31,
                            decoration: BoxDecoration(
                              color: selected == i
                                  ? const Color(0xff611b25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              selected == i ? active[i] : icons[i],
                              color: selected == i
                                  ? Colors.white
                                  : const Color(0xff99969b),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected == i
                                  ? Colors.white
                                  : const Color(0xffaaa6ad),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
