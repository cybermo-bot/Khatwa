import 'package:flutter/material.dart';

import '../ui/app_state.dart';
import '../ui/app_theme.dart';
import '../ui/strings.dart';
import 'tabs/check_tab.dart';
import 'tabs/journal_tab.dart';
import 'tabs/learn_tab.dart';
import 'tabs/me_tab.dart';
import 'tabs/today_tab.dart';

/// The patient app: five destinations in a frosted navigation bar. Each tab
/// keeps its own scroll position; detail screens open above the bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Lets a tab send the patient to another tab, for example Today to Learn.
  static void goTo(BuildContext context, int index) =>
      context.findAncestorStateOfType<_AppShellState>()?._select(index);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _select(int index) {
    if (index != _index) setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLanguage.value;
    const tabs = [TodayTab(), CheckTab(), JournalTab(), LearnTab(), MeTab()];

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        backgroundColor: K.ground,
        body: KBackdrop(child: IndexedStack(index: _index, children: tabs)),
        bottomNavigationBar: KFrostedNavBar(
          selectedIndex: _index,
          onSelected: _select,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.wb_twilight_outlined),
              selectedIcon: const Icon(Icons.wb_twilight_rounded),
              label: S.t(lang, 'tab.today'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.photo_camera_outlined),
              selectedIcon: const Icon(Icons.photo_camera_rounded),
              label: S.t(lang, 'tab.check'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: S.t(lang, 'tab.journal'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_stories_outlined),
              selectedIcon: const Icon(Icons.auto_stories_rounded),
              label: S.t(lang, 'tab.learn'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: S.t(lang, 'tab.me'),
            ),
          ],
        ),
      ),
    );
  }
}
