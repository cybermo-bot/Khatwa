// Every screen in the four languages, light and dark, on a narrow phone at
// text scale 1.3 and on a wide screen: nothing may overflow or throw.
import 'package:diabetic_foot_app/doctor/data/demo_repository.dart';
import 'package:diabetic_foot_app/doctor/screens/doctor_dashboard.dart';
import 'package:diabetic_foot_app/screens/shell.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:diabetic_foot_app/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support_screens.dart';

const _frames = [('phone', Size(360, 760), 1.3), ('wide', Size(1280, 800), 1.0)];

Widget _app(String lang, double scale, Widget home) => MaterialApp(
      theme: K.theme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true, textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection: S.isRtl(lang) ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
      ),
      home: home,
    );

Future<void> _show(WidgetTester tester, String lang, bool dark, (String, Size, double) frame, Widget page) async {
  K.setDark(dark);
  appLanguage.value = lang;
  tester.view.physicalSize = frame.$2;
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(_app(lang, frame.$3, page));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(setUpScreens);

  final pages = screens();
  for (final lang in S.languages) {
    for (final dark in [false, true]) {
      for (final frame in _frames) {
        final tag = '$lang ${dark ? 'dark' : 'light'} ${frame.$1}';

        testWidgets('pages hold: $tag', (tester) async {
          addTearDown(tester.view.reset);
          final broken = <String>[];
          for (final page in pages.entries) {
            await _show(tester, lang, dark, frame, page.value());
            final error = tester.takeException();
            if (error != null) broken.add('${page.key}: ${'$error'.split('\n').first} @ ${_where(error)}');
          }
          expect(broken, isEmpty);
        });

        testWidgets('tabs hold: $tag', (tester) async {
          addTearDown(tester.view.reset);
          await _show(tester, lang, dark, frame, const AppShell());
          final broken = <String>[];
          for (final tab in ['tab.today', 'tab.check', 'tab.journal', 'tab.learn', 'tab.me']) {
            await tester.tap(find.text(S.t(lang, tab)).last);
            await tester.pump(const Duration(milliseconds: 600));
            final error = tester.takeException();
            if (error != null) broken.add('$tab: ${'$error'.split('\n').first} @ ${_where(error)}');
          }
          expect(broken, isEmpty);
        });

        testWidgets('doctor dashboard holds: $tag', (tester) async {
          addTearDown(tester.view.reset);
          final repo = DemoDoctorRepository(now: DateTime(2026, 9, 29, 10));
          addTearDown(repo.dispose);
          await _show(tester, lang, dark, frame, DoctorDashboard(repository: repo, enable3d: false, today: DateTime(2026, 9, 29, 10)));
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

/// The line of the app's code that built the overflowing widget.
String _where(Object error) {
  if (error is FlutterError) {
    for (final node in error.diagnostics) {
      final m = RegExp(r'lib/[\w/]+\.dart:\d+').firstMatch(node.toString());
      if (m != null) return m.group(0)!;
    }
  }
  return '?';
}
