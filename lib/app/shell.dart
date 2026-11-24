import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/widgets/common.dart';
import '../features/bookmarks/saved_screen.dart';
import '../features/events/events_screen.dart';
import '../features/home/home_screen.dart';
import '../features/programs/programs_screen.dart';
import '../features/speakers/speakers_screen.dart';

enum ShellTab { home, events, programs, speakers, saved }

/// The single navigation shell: one Scaffold, one NavigationBar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = ShellTab.home});

  final ShellTab initialTab;

  /// Switches tab from anywhere below the shell (e.g. "See all").
  static void goTo(BuildContext context, ShellTab tab, {String? topic}) {
    final state = context.findAncestorStateOfType<HomeShellState>();
    if (state == null) return;
    if (topic != null) state.topicRequest.value = topic;
    state.select(tab);
  }

  /// Topic requested from another tab (consumed by the Events tab).
  static ValueNotifier<String?>? topicRequestOf(BuildContext context) =>
      context.findAncestorStateOfType<HomeShellState>()?.topicRequest;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  late ShellTab _tab = widget.initialTab;

  /// Lazily built tabs, kept alive once visited.
  final Set<ShellTab> _visited = {};

  final ValueNotifier<String?> topicRequest = ValueNotifier<String?>(null);

  @override
  void dispose() {
    topicRequest.dispose();
    super.dispose();
  }

  void select(ShellTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }

  Widget _pageFor(ShellTab tab) {
    switch (tab) {
      case ShellTab.home:
        return const HomeScreen();
      case ShellTab.events:
        return const EventsScreen();
      case ShellTab.programs:
        return const ProgramsScreen();
      case ShellTab.speakers:
        return const SpeakersScreen();
      case ShellTab.saved:
        return const SavedScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    _visited.add(_tab);
    return PopScope(
      canPop: _tab == ShellTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) select(ShellTab.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tab.index,
          children: [
            for (final tab in ShellTab.values)
              _visited.contains(tab) ? _pageFor(tab) : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoStripe(height: 3, radius: 0),
            NavigationBar(
              selectedIndex: _tab.index,
              onDestinationSelected: (i) => select(ShellTab.values[i]),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: s.navHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.event_outlined),
                  selectedIcon: const Icon(Icons.event),
                  label: s.navEvents,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.school_outlined),
                  selectedIcon: const Icon(Icons.school),
                  label: s.navPrograms,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.people_outline),
                  selectedIcon: const Icon(Icons.people),
                  label: s.navSpeakers,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bookmark_border),
                  selectedIcon: const Icon(Icons.bookmark),
                  label: s.navSaved,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(),
      body: MessageView(
        icon: Icons.link_off,
        title: s.notFound,
        actionLabel: s.back,
        onAction: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
