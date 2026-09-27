// Accessibility: every tap target has a label and is big enough, and text
// meets contrast, in light and dark.
import 'package:diabetic_foot_app/screens/shell.dart';
import 'package:diabetic_foot_app/ui/app_state.dart';
import 'package:diabetic_foot_app/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support_screens.dart';

Widget _app(Widget home) => MaterialApp(
      theme: K.theme(),
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: home,
    );

void main() {
  setUpAll(setUpScreens);
  const langs = ['Français', 'تونسي', 'English'];
  final pages = {'tabs': () => const AppShell(), ...screens()};
  for (final lang in langs) {
    for (final dark in [false, true]) {
      for (final page in pages.entries) {
        testWidgets('${page.key} is accessible ($lang, ${dark ? 'dark' : 'light'})', (tester) async {
          final handle = tester.ensureSemantics();
          K.setDark(dark);
          appLanguage.value = lang;
          tester.view.physicalSize = const Size(412, 915);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(_app(page.value()));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
          await tester.pump(const Duration(milliseconds: 300));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          // The test font has no Arabic glyphs, so contrast is measured on
          // the Latin-script pages; the colours are the same in every language.
          if (lang == 'Français') await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    }
  }
}
