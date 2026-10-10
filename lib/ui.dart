import 'package:flutter/material.dart';
import 'data.dart';
import 'store.dart';
import 'services.dart';

const red = Color(0xffed171f);
const gold = Color(0xffc9a74e);

ThemeData appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: red,
    brightness: brightness,
    primary: red,
    surface: dark ? const Color(0xff0e0e10) : const Color(0xfffcf8f7),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    dividerColor: dark ? const Color(0xff2b2629) : const Color(0xffeee6e4),
    splashFactory: InkSparkle.splashFactory,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: red,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: red,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: red,
      thumbColor: red,
      inactiveTrackColor: dark
          ? const Color(0xff44373c)
          : const Color(0xffeadbdc),
      trackHeight: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xff252124) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class AppScope extends InheritedNotifier<AppStore> {
  final Content content;
  final SpeechPlayer speech;
  final ReminderService reminders;
  AppStore get store => notifier!;
  const AppScope({
    super.key,
    required AppStore store,
    required this.content,
    required this.speech,
    required this.reminders,
    required super.child,
  }) : super(notifier: store);
  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;
}

Color muted(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? const Color(0xffb5afb4)
    : const Color(0xff81787c);
Color panel(BuildContext c) => Theme.of(c).brightness == Brightness.dark
    ? const Color(0xff201c1f)
    : Colors.white;
void message(BuildContext c, String text) =>
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );

IconData topicIcon(String name) => switch (name) {
  'waving_hand' => Icons.waving_hand_rounded,
  'volunteer_activism' => Icons.volunteer_activism,
  'restaurant' => Icons.restaurant_rounded,
  'explore' => Icons.explore_outlined,
  'directions_bus' => Icons.directions_bus_rounded,
  'shopping_bag' => Icons.shopping_bag_outlined,
  'hotel' => Icons.hotel_rounded,
  'health_and_safety' => Icons.health_and_safety_outlined,
  _ => Icons.forum_outlined,
};

class BrandHeader extends StatelessWidget {
  final String title, subtitle;
  final Widget? bottom, trailing;
  final bool home;
  const BrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.bottom,
    this.trailing,
    this.home = false,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xfff01c25), Color(0xffcb101b), Color(0xff301316)],
      ),
      border: Border(bottom: BorderSide(color: gold, width: 3)),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -20,
          top: 8,
          child: Opacity(
            opacity: .09,
            child: Image.asset('assets/images/app_icon.png', width: 158),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (home)
                      Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset('assets/images/app_icon.png'),
                        ),
                      )
                    else
                      Container(
                        width: 3,
                        height: 44,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: home ? 23 : 25,
                              letterSpacing: -.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xfff8c8c7),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                if (bottom != null) ...[const SizedBox(height: 20), bottom!],
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      children: [
        Container(width: 3, height: 16, color: red),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: muted(context),
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class TopicTile extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;
  final Widget? trailing;
  const TopicTile({
    super.key,
    required this.topic,
    required this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: panel(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    clipBehavior: Clip.antiAlias,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 3, color: red),
              const SizedBox(width: 13),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: topic.id == 'courtesy' ? const Color(0xffb72a36) : red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  topicIcon(topic.icon),
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${topic.subtitle} · 11 phrases',
                        style: TextStyle(fontSize: 11, color: muted(context)),
                      ),
                    ],
                  ),
                ),
              ),
              trailing ??
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.chevron_right, size: 20),
                  ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ListenButton extends StatefulWidget {
  final Phrase phrase;
  final bool compact;
  const ListenButton({super.key, required this.phrase, this.compact = false});
  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton> {
  bool busy = false;
  Future<void> play() async {
    final scope = AppScope.of(context);
    setState(() => busy = true);
    try {
      await scope.speech.play(widget.phrase.id, scope.store.speed);
      scope.store.study();
    } catch (_) {
      if (mounted) message(context, 'Audio could not play. Please try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.compact
      ? IconButton(
          tooltip: 'Listen to pronunciation',
          onPressed: busy ? null : play,
          icon: const Icon(Icons.volume_up_outlined, color: red),
        )
      : FilledButton.icon(
          onPressed: busy ? null : play,
          icon: const Icon(Icons.volume_up_rounded, size: 18),
          label: const Text('Listen'),
        );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: red.withValues(alpha: .09),
            ),
            child: Icon(icon, size: 40, color: red),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: muted(context), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

void pushPage(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
